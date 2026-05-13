using MyExampleV2
using Test

@testset "MyExampleV2.jl" begin
    @test my_f(2, 1) == 7
    @test my_f(3, 2) == 12
    @test my_f(3, 2) == 13
end
