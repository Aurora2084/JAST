# 语法分析器

mutable struct Parser
    tokens::Vector{Token}
    pos::Int
end

Parser(tokens::Vector{Token}) = Parser(tokens, 1)

function peek(parser::Parser)::Token
    return parser.tokens[parser.pos]
end

function advance!(parser::Parser)::Token
    token = peek(parser)
    parser.pos += 1
    return token
end

function expect(parser::Parser, kind::Symbol)::Token
    token = peek(parser)
    if token.kind != kind
        error("Expected $kind, got $(token.kind) at line $(token.line), column $(token.col)")
    end
    return advance!(parser)
end

function parse(tokens::Vector{Token})::Program
    parser = Parser(tokens)
    return parse_program(parser)
end

function parse_program(parser::Parser)::Program
    statements = ASTNode[]
    
    while peek(parser).kind != :eof
        push!(statements, parse_statement(parser))
    end
    
    return Program(statements)
end

function parse_statement(parser::Parser)::ASTNode
    token = peek(parser)
    
    if token.kind == :int
        # 检查是否是函数定义（后面跟着标识符和左括号）
        if parser.pos + 1 <= length(parser.tokens) && parser.tokens[parser.pos + 1].kind == :identifier
            if parser.pos + 2 <= length(parser.tokens) && parser.tokens[parser.pos + 2].kind == :lparen
                return parse_function_def(parser)
            end
        end
        # 否则是变量声明
        return parse_declaration(parser)
    elseif token.kind == :return
        return parse_return_stmt(parser)
    elseif token.kind == :identifier
        return parse_assign_stmt(parser)
    else
        error("Unexpected token: $(token.kind) at line $(token.line), column $(token.col)")
    end
end

function parse_declaration(parser::Parser)::ASTNode
    expect(parser, :int)
    var = expect(parser, :identifier).value
    
    # 检查是否有初始化
    if peek(parser).kind == :assign
        advance!(parser)
        expr = parse_expression(parser)
        expect(parser, :semicolon)
        return AssignStmt(var, expr)
    else
        expect(parser, :semicolon)
        # 对于简单的变量声明，我们也使用 AssignStmt 来表示
        return AssignStmt(var, Literal("0", "int"))
    end
end

function parse_function_def(parser::Parser)::FunctionDef
    expect(parser, :int)
    name = expect(parser, :identifier).value
    expect(parser, :lparen)
    
    params = Tuple{String, String}[]
    if peek(parser).kind != :rparen
        while true
            type = expect(parser, :int).value
            param_name = expect(parser, :identifier).value
            push!(params, (type, param_name))
            
            if peek(parser).kind != :comma
                break
            end
            advance!(parser)
        end
    end
    
    expect(parser, :rparen)
    expect(parser, :lbrace)
    
    body = ASTNode[]
    while peek(parser).kind != :rbrace
        push!(body, parse_statement(parser))
    end
    
    expect(parser, :rbrace)
    
    return FunctionDef(name, params, "int", body)
end

function parse_return_stmt(parser::Parser)::ReturnStmt
    expect(parser, :return)
    expr = parse_expression(parser)
    expect(parser, :semicolon)
    return ReturnStmt(expr)
end

function parse_assign_stmt(parser::Parser)::AssignStmt
    var = expect(parser, :identifier).value
    expect(parser, :assign)
    expr = parse_expression(parser)
    expect(parser, :semicolon)
    return AssignStmt(var, expr)
end

function parse_expression(parser::Parser)::ASTNode
    return parse_binary_op(parser, 0)
end

function parse_binary_op(parser::Parser, precedence::Int)::ASTNode
    left = parse_primary(parser)
    
    while true
        token = peek(parser)
        op_prec = get_precedence(token.kind)
        
        if op_prec <= precedence
            break
        end
        
        op = token.kind
        advance!(parser)
        right = parse_binary_op(parser, op_prec)
        left = BinaryOp(op, left, right)
    end
    
    return left
end

function get_precedence(op::Symbol)::Int
    if op in [:plus, :minus]
        return 1
    elseif op in [:times, :divide]
        return 2
    else
        return 0
    end
end

function parse_primary(parser::Parser)::ASTNode
    token = peek(parser)
    
    if token.kind == :number
        advance!(parser)
        return Literal(token.value, "int")
    elseif token.kind == :identifier
        advance!(parser)
        # 检查是否是函数调用
        if peek(parser).kind == :lparen
            return parse_function_call(token.value, parser)
        end
        return Identifier(token.value)
    elseif token.kind == :lparen
        advance!(parser)
        expr = parse_expression(parser)
        expect(parser, :rparen)
        return ParenExpr(expr)
    else
        error("Unexpected token: $(token.kind) at line $(token.line), column $(token.col)")
    end
end

function parse_function_call(name::String, parser::Parser)::ASTNode
    expect(parser, :lparen)
    
    args = ASTNode[]
    if peek(parser).kind != :rparen
        while true
            arg = parse_expression(parser)
            push!(args, arg)
            
            if peek(parser).kind != :comma
                break
            end
            advance!(parser)
        end
    end
    
    expect(parser, :rparen)
    
    # 对于简单的函数调用，我们使用 BinaryOp 来表示，因为我们还没有实现函数调用的 AST 节点
    # 这里我们假设函数调用返回一个值，并且我们可以直接使用它
    return Identifier(name)
end
