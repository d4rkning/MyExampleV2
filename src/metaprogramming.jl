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