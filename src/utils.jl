# 辅助功能

function print_ast(node::ASTNode, indent::Int=0)
    prefix = "  " ^ indent
    
    if node isa Program
        println("$(prefix)Program")
        for stmt in node.statements
            print_ast(stmt, indent + 1)
        end
    elseif node isa FunctionDef
        println("$(prefix)FunctionDef: $(node.name) -> $(node.return_type)")
        for (type, name) in node.params
            println("$(prefix)  Param: $type $name")
        end
        for stmt in node.body
            print_ast(stmt, indent + 1)
        end
    elseif node isa ReturnStmt
        println("$(prefix)ReturnStmt")
        print_ast(node.expr, indent + 1)
    elseif node isa AssignStmt
        println("$(prefix)AssignStmt: $(node.var)")
        print_ast(node.expr, indent + 1)
    elseif node isa BinaryOp
        println("$(prefix)BinaryOp: $(node.op)")
        print_ast(node.left, indent + 1)
        print_ast(node.right, indent + 1)
    elseif node isa Literal
        println("$(prefix)Literal: $(node.value) ($(node.type))")
    elseif node isa Identifier
        println("$(prefix)Identifier: $(node.name)")
    elseif node isa ParenExpr
        println("$(prefix)ParenExpr")
        print_ast(node.expr, indent + 1)
    end
end
