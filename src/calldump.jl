
const CALL_DUMP = {}

macro calldump(expr)
    if expr.head == :call
        push!(CALL_DUMP, expr)
    end
    return expr    
end
