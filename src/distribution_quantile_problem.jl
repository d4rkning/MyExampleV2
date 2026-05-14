using Distributions

θ = 0
q = 0.9
normal = Distributions.Normal(0, 1)

function find_quantile(univariate_distribution::Distributions.UnivariateDistribution, q::Float64)::Float64
    θ = 0
    for i = 1:10
        θ = θ - (Distributions.cdf(univariate_distribution, θ)-q)/Distributions.pdf(univariate_distribution, θ)
    end
    return θ
end

θ = find_quantile(normal, 0.9)
print(θ)