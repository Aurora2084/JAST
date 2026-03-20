include("src/JAST.jl")

using .JAST

# 读取测试文件
code = read("test.cpp", String)

# 编译代码生成 LLVM IR
ir = JAST.compile(code)

# 输出生成的 LLVM IR
println("Generated LLVM IR:")
println(ir)

# 编译为二进制文件
output_file = Sys.iswindows() ? "add.exe" : "add"
JAST.compile_to_binary(ir, output_file)
