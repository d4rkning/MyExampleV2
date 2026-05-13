using Random

function binomial_rv(n, p)
    s = 0
    for i=1:n
        if rand(Float64) < p
            s += 1
        end
    end
    return s
end