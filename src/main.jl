include("JAST.jl")

using .JAST

if abspath(PROGRAM_FILE) == @__FILE__
    JAST.run_compiler()
end
