using MyExampleV2
using Test

@testset "My eval poly test" begin
    @test @myevalpoly(0.5, 2., 3., 4., 5.) ≈ @evalpoly(0.5, 2., 3., 4., 5.)
    @test @myevalpoly(2.0, 1.0, 2.0, 3.0) ≈ @evalpoly(2.0, 1.0, 2.0, 3.0)
    @test @myevalpoly(-1.5, 5.0, -2.0, 0.5, 1.0) ≈ @evalpoly(-1.5, 5.0, -2.0, 0.5, 1.0)
end
