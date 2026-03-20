module JAST

include("tokenizer.jl")
include("parser.jl")
include("ast.jl")
include("codegen.jl")
include("utils.jl")

function compile(cpp_code::String)::String
    # 词法分析
    tokens = tokenize(cpp_code)
    
    # 语法分析
    ast = parse(tokens)
    
    # LLVM 代码生成
    ir = codegen(ast)
    
    return ir
end

function run_compiler()
    println("JAST C++ Compiler")
    println("Enter C++ code (type 'exit' to quit):")
    
    while true
        print("> ")
        code = readline()
        
        if code == "exit"
            break
        end
        
        try
            ir = compile(code)
            println("Generated LLVM IR:")
            println(ir)
        catch e
            println("Error: ", e)
        end
    end
end

end # module JAST
