using MyExampleV2
using Test

@testset "MyExampleV2.jl" begin
    @test my_factorial(5) == 120
    @test my_factorial(10) == 3628800
    @test my_factorial(0) == 1
    @test typeof(my_factorial(10)) == BigInt
end
