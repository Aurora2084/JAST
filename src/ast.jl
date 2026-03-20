# AST 节点类型

abstract type ASTNode end

struct Program <: ASTNode
    statements::Vector{ASTNode}
end

struct FunctionDef <: ASTNode
    name::String
    params::Vector{Tuple{String, String}}  # (type, name)
    return_type::String
    body::Vector{ASTNode}
end

struct ReturnStmt <: ASTNode
    expr::ASTNode
end

struct AssignStmt <: ASTNode
    var::String
    expr::ASTNode
end

struct BinaryOp <: ASTNode
    op::Symbol
    left::ASTNode
    right::ASTNode
end

struct Literal <: ASTNode
    value::String
    type::String
end

struct Identifier <: ASTNode
    name::String
end

struct ParenExpr <: ASTNode
    expr::ASTNode
end
