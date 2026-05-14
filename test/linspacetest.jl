using MyExampleV2
using Unitful
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
    @testset "Unitful tests" begin
        ls1 = LinSpace(0.0u"N", 1.0u"N", 11)
        @test ls1[11] ≈ 1.0u"N"
        @test ls1[11] ≈ 0.001u"kN"
        @test_throws BoundsError ls1[12]
        @test_throws BoundsError ls1[0]
        @test_throws BoundsError ls1[-1]

        ls2 = LinSpace(-5.0u"N", 5.0u"N", 21)
        @test ls2[1] ≈ -5.0u"N"
        @test ls2[21] ≈ 5.0u"N"
        @test_throws BoundsError ls2[22]    
        ls3 = LinSpace(10.0u"N", 0.0u"N", 5)
        @test ls3[1] ≈ 10.0u"N"
        @test ls3[5] ≈ 0.0u"N"
        @test_throws BoundsError ls3[6]
    end
end
