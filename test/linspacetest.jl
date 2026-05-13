using MyExampleV2
using Test

@testset "LinSpace Tests" begin
    @testset "LinSpace vs Base.range" begin
        # Standard positive range
        ls1 = LinSpace(0.0, 1.0, 11)
        rg1 = range(0.0, 1.0, length=11)
        for i in 1:11
            @test ls1[i] ≈ rg1[i]
        end
        @test_throws BoundsError ls1[12]

        # Range crossing zero with negative start
        ls2 = LinSpace(-5.0, 5.0, 21)
        rg2 = range(-5.0, 5.0, length=21)
        for i in 1:21
            @test ls2[i] ≈ rg2[i]
        end

        # Descending range
        ls3 = LinSpace(10.0, 0.0, 5)
        rg3 = range(10.0, 0.0, length=5)
        for i in 1:5
            @test ls3[i] ≈ rg3[i]
        end
    end
    @testset "Matches end index" begin
        ls1 = LinSpace(0.0, 1.0, 11)
        ls1[11] ≈ 1.0
    end
end
