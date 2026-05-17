macro my_time(ex)
    return quote
        local t0 = time()
        local val = $ex
        local t1 = time()
        println("Elapsed time: ", t1-t0, " seconds")
        val
    end
end

macro myevalpoly(x, p...)
    ex = :($(p[end]))
    for i=1:length(p)-1
        ex = :($ex * $(x) + $(p[length(p)-i]))
    end
    return ex
end

function math_expr(op, op1, op2)
    expr = Expr(:call, op, op1, op2)
    return expr
end

ex = math_expr(:+, 1, Expr(:call, :*,4, 5))

function make_expr2(op, opr1, opr2)
    opr1f, opr2f = map(x -> isa(x, Number) ? 2*x : x, (opr1, opr2))
    retexpr = Expr(:call, op, opr1f, opr2f)
    return retexpr
end
make_expr2(:+, 1,2 )

macro sayhello()
    return :( println("Hello world!"))
end
@sayhello()

macro sayhello(name)
    return :( println("Hello, ", $name))
end

macro twostep(arg)
    println("I execute at parse time. The argument is: ", arg)
    return :(println("I execute at runtime. The argument is: ", $arg))
end

macro showarg(x)
    show(x)
end

macro assert(ex)
    return :($ex ? nothing : throw(AssertionError($(string(ex)))))
end

macro inspect(expr)
    expr_str = string(expr)
    return quote
        println("Inspecting: ", $expr_str)
        local val = $(esc(expr))
        println("   Result: ", val)
        val
    end
end

x = 10
y = 20
result = @inspect x + y * 2

macro retry(n, expr)
    return quote
        local max_attempts = $(esc(n))
        local val
        
        for i in 1:max_attempts
            try
                val = $(esc(expr))
                break
            catch e
                if i == max_attempts
                    rethrow(e)
                else
                    local msg = isa(e, ErrorException) ? e.msg : e
                    println("Attempt ", i, " failed: ", msg, " Retrying...")
                end
            end
        end
        val 
    end
end
