using LLVM

# 检查 LLVM 中与参数相关的函数
println("LLVM API related to arguments:")
for name in names(LLVM)
    if occursin("arg", lowercase(string(name)))
        println(name)
    end
end

# 检查 Function 类型的方法
println("\nMethods for Function type:")
func = LLVM.Function
println(methods(func))
