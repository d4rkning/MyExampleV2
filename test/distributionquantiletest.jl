using MyExampleV2
using Test
using Distributions

@testset "distribution quantile test" begin
    dist = Normal(0.0, 1.0)
    
    @test find_quantile(dist, 0.1) ≈ quantile(dist, 0.1) atol=1e-5
    @test find_quantile(dist, 0.5) ≈ quantile(dist, 0.5) atol=1e-5
    @test find_quantile(dist, 0.9) ≈ quantile(dist, 0.9) atol=1e-5
end
