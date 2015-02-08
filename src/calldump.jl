
const CALL_DUMP = {}


function dump_wrapper(f)
    function warped(args...)
        println("$f: $args")
        return f(args...)
    end
    return warped
end

macro calldump(expr::Expr)
    if expr.head == :call
        return :(dump_wrapper($(expr.args[1]), $(expr.args[2:end]...)))
    else
        return expr
    end
end


bar(x) = x - 4
foo(x) = 42 * bar(x)


macro traverse(e::Expr, f::Function)
    if e.head == :call
        f(e.args[1])
        e
    else
        e
    end
end
