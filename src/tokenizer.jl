# 词法分析器

struct Token
    kind::Symbol
    value::String
    line::Int
    col::Int
end

function tokenize(code::String)::Vector{Token}
    tokens = Token[]
    i = 1
    line = 1
    col = 1
    n = length(code)
    
    while i ≤ n
        c = code[i]
        
        # 跳过空白字符
        if c in [' ', '\t', '\n', '\r']
            if c == '\n'
                line += 1
                col = 1
            else
                col += 1
            end
            i += 1
        # 数字
        elseif isdigit(c)
            start = i
            while i ≤ n && isdigit(code[i])
                i += 1
            end
            value = code[start:i-1]
            push!(tokens, Token(:number, value, line, col))
            col += length(value)
        # 标识符
        elseif isletter(c) || c == '_'
            start = i
            while i ≤ n && (isletter(code[i]) || isdigit(code[i]) || code[i] == '_')
                i += 1
            end
            value = code[start:i-1]
            # 检查关键字
            if value in ["int", "return", "if", "else", "while", "for"]
                push!(tokens, Token(Symbol(value), value, line, col))
            else
                push!(tokens, Token(:identifier, value, line, col))
            end
            col += length(value)
        # 操作符和标点符号
        elseif c == '+'
            push!(tokens, Token(:plus, "+", line, col))
            i += 1
            col += 1
        elseif c == '-'
            push!(tokens, Token(:minus, "-", line, col))
            i += 1
            col += 1
        elseif c == '*'
            push!(tokens, Token(:times, "*", line, col))
            i += 1
            col += 1
        elseif c == '/'
            push!(tokens, Token(:divide, "/", line, col))
            i += 1
            col += 1
        elseif c == '='
            push!(tokens, Token(:assign, "=", line, col))
            i += 1
            col += 1
        elseif c == ';'
            push!(tokens, Token(:semicolon, ";", line, col))
            i += 1
            col += 1
        elseif c == '('
            push!(tokens, Token(:lparen, "(", line, col))
            i += 1
            col += 1
        elseif c == ')'
            push!(tokens, Token(:rparen, ")", line, col))
            i += 1
            col += 1
        elseif c == '{'
            push!(tokens, Token(:lbrace, "{", line, col))
            i += 1
            col += 1
        elseif c == '}'
            push!(tokens, Token(:rbrace, "}", line, col))
            i += 1
            col += 1
        elseif c == ','
            push!(tokens, Token(:comma, ",", line, col))
            i += 1
            col += 1
        else
            error("Unexpected character: $c at line $line, column $col")
        end
    end
    
    # 添加结束标记
    push!(tokens, Token(:eof, "", line, col))
    
    return tokens
end
