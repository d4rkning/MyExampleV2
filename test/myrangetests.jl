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

    @testset "Edge Cases and Invalid Ranges" begin
        r3 = MyRange(5, 1, 1) # start > stop with positive step
        @test_throws BoundsError r3[1]

        r4 = MyRange(1, 0, 5) # zero step
        @test r4[1] == 1
        @test r4[100] == 1 # Never exceeds stop, so any positive index works
        @test r4[-10] == 1 # Even negative indices work since the value remains 1

        r5 = MyRange(5, -1, 1) # negative step
        @test_throws BoundsError r5[1] # Fails because 5 > 1 (a.stop) evaluates to true
    end

    @testset "Linear interpolation test" begin
        r4 = MyRange(1, 2, 20)
        r4[1.1] ≈ 1.2
    end
end