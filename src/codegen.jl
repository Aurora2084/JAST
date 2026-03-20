# LLVM 代码生成

using LLVM

function codegen(ast::Program)::String
    ir = ""
    
    for stmt in ast.statements
        if stmt isa FunctionDef
            ir *= codegen_function(stmt)
        end
    end
    
    return ir
end

function compile_to_binary(ir::String, output_file::String)
    # 写入 LLVM IR 文件
    ir_file = output_file * ".ll"
    write(ir_file, ir)
    
    println("LLVM IR file generated: $ir_file")
    println("To compile to binary, you can use:")
    println("1. llc $ir_file -o $output_file.s")
    println("2. gcc $output_file.s -o $output_file")
    
    # 尝试使用系统命令编译
    try
        # 使用 gcc 直接编译 LLVM IR
        run(`gcc $ir_file -o $output_file`)
        
        # 清理临时文件
        rm(ir_file)
        
        println("\nBinary file generated: $output_file")
    catch e
        println("\nAutomatic compilation failed. Please compile manually using the commands above.")
        println("Error: $e")
    end
end

# 全局寄存器计数器
register_counter = 0

function reset_register_counter()
    global register_counter = 0
end

function get_next_register()::String
    global register_counter
    register_counter += 1
    return "%" * string(register_counter)
end

function codegen_function(func::FunctionDef)::String
    # 重置寄存器计数器
    reset_register_counter()
    
    # 生成函数签名
    params_str = join(["i32 %" * name for (_, name) in func.params], ", ")
    ir = "define i32 @" * func.name * "(" * params_str * ") {\n"
    
    # 生成函数体
    for stmt in func.body
        ir *= codegen_statement(stmt, func.params)
    end
    
    ir *= "}\n"
    return ir
end

function codegen_statement(stmt::ReturnStmt, params::Vector{Tuple{String, String}})::String
    # 生成表达式的 IR
    expr_ir, result_reg = codegen_expression(stmt.expr, params)
    return expr_ir * "  ret i32 " * result_reg * "\n"
end

function codegen_statement(stmt::AssignStmt, params::Vector{Tuple{String, String}})::String
    # 生成表达式的 IR
    expr_ir, result_reg = codegen_expression(stmt.expr, params)
    return expr_ir * "  store i32 " * result_reg * ", i32* %" * stmt.var * "\n"
end

function codegen_expression(expr::BinaryOp, params::Vector{Tuple{String, String}})::Tuple{String, String}
    # 生成左右操作数的 IR
    left_ir, left_reg = codegen_expression(expr.left, params)
    right_ir, right_reg = codegen_expression(expr.right, params)
    
    if expr.op == :plus
        op = "add"
    elseif expr.op == :minus
        op = "sub"
    elseif expr.op == :times
        op = "mul"
    elseif expr.op == :divide
        op = "sdiv"
    else
        error("Unknown operator: $(expr.op)")
    end
    
    # 生成临时寄存器
    result_reg = get_next_register()
    
    # 生成 IR
    ir = left_ir * right_ir * "  " * result_reg * " = " * op * " i32 " * left_reg * ", " * right_reg * "\n"
    
    return (ir, result_reg)
end

function codegen_expression(expr::Literal, params::Vector{Tuple{String, String}})::Tuple{String, String}
    return ("", expr.value)
end

function codegen_expression(expr::Identifier, params::Vector{Tuple{String, String}})::Tuple{String, String}
    # 生成临时寄存器
    result_reg = get_next_register()
    
    # 生成 IR
    ir = "  " * result_reg * " = load i32, i32* %" * expr.name * "\n"
    
    return (ir, result_reg)
end

function codegen_expression(expr::ParenExpr, params::Vector{Tuple{String, String}})::Tuple{String, String}
    return codegen_expression(expr.expr, params)
end
