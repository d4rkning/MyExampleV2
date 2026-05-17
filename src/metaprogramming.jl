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

prog = "1 + 1"
ex1 = Meta.parse(prog)
typeof(ex1)
ex1.head
ex1.args
ex2 = Expr(:call, :+, 1, 1)
dump(ex2)
ex3 = Meta.parse("(4 + 4) / 2")
Meta.show_sexpr(ex3)

s = :foo
typeof(s)
:foo === Symbol("foo")

Symbol("1foo")
Symbol("func", 10)
Symbol(:var, '-', "sym")
ex = :(a+b*c+1)
typepof(ex)
ex.head
ex.args
dump(ex)
Meta.@dump(ex)
ex = quote
    x = 1
    y = 2
    x + y
end
quote
    #= none:2 =#
    x = 1
    #= none:3 =#
    y = 2
    #= none:4 =#
    x + y
end

a= 1;
ex = :($a + b)

ex = :(a in $:((1, 2, 3)))
dump(ex)
args = [:x, :y, :z, :a]
:(f(1, $(args...)))
x = :(1+2);
e = quote quote $x end end
e = quote quote $$x end end
eval(e)
dump(Meta.parse(":(1+2)"))

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

@sayhello("Chris")
ex = macroexpand(Main, :(@sayhello("Chris")))

macro twostep(arg)
    println("I execute at parse time. The argument is: ", arg)
    return :(println("I execute at runtime. The argument is: ", $arg))
end

ex = macroexpand(Main, :(@twostep :(1, 2, 3)));
macro showarg(x)
    show(x)
end
@showarg(a)

macro assert(ex)
    return :($ex ? nothing : throw(AssertionError($(string(ex)))))
end
@assert 1.0 == 1

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
attempts = 0

function flaky_connection()
    global attempts += 1
    if attempts < 3
        error("🌐 Network timeout error!")
    else
        return "Connected successfully!"
    end
end

@retry(2, flaky_connection())

macro unless(expr, block)
    if block.head != :block
        error("Formatting error: @unless requires a begin .. end block.")
    end
    quote
        if !($(esc(expr)))
            $(esc(block))
        end
    end
end

x = 5;
@unless x > 10 begin
    println("Not greater than 10")
end

function test_hygiene()
    local_x = 5
    @unless local_x > 10 begin
        println("Not greater than 10")
    end
end
test_hygiene()
    