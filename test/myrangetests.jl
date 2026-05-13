using MyExampleV2
using Test

@testset "MyRange Tests" begin
    r1 = MyRange(1, 1, 9)
    @test r1[1] == 1
    @test r1[5] == 5
    @test r1[9] == 9
    @test_throws BoundsError r1[10]
    @test_throws BoundsError r1[0]
    @test_throws BoundsError r1[-1]

    r2 = MyRange(1.0, 0.5, 5.0)
    @test r2[1] == 1.0
    @test r2[3] == 2.0
    @test r2[9] == 5.0
    @test_throws BoundsError r2[10]
end
