include("src/JAST.jl")

using .JAST

# 读取测试文件
code = read("test.cpp", String)

# 编译代码
ir = JAST.compile(code)

# 输出生成的 LLVM IR
println("Generated LLVM IR:")
println(ir)
