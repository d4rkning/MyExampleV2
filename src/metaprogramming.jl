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