using Distributed
using Plots


@everywhere function simulate_stock_price(S::Float64, T::Float64, n::Int64, σ::Float64, r::Float64)::Vector{Float64}
    h = T/n
    u = exp(r*h + σ*sqrt(h))
    d = exp(r*h - σ*sqrt(h))
    p = (exp(r*h)-d)/(u-d)

    deltas = [d; u];

    
    S_path = [S]
    for movement in (map((x) -> deltas[x+1], rand(n).> p))
        S = S * movement
        push!(S_path, S)    
    end
    return S_path
end

n = 10000
paths_to_generate = 1000 
Spaths = zeros(n+1, paths_to_generate)
println(Threads.nthreads())
Threads.@threads for i in 1:paths_to_generate
    Spaths[:, i] =simulate_stock_price(
        100.0,
        1.0,
        n,
        0.3,
        0.08
    )
end

nbins = 10
bin_range = (max(Spaths[end, :]) - min(Spaths[end, :]))/nbins

scatter(Spaths[end, :])