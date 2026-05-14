using MyExampleV2
using Test

function test_strangs_matrix(matrix)
    N = size(matrix)
    if N[1] != N[2]
        return false 
    end
    for i=N
        if matrix[i, i] != -2
            return false
        end
        if i-1 > 0 && matrix[i, i-1] != 1
            return false
        end
        if i+1 <= N[1] && matrix[i, i+1] != 1
            return false
        end
    end
    return true
end


@testset "Test strangs structure" begin
    @test test_strangs_matrix(strangs_matrix(5)) == true
    @test test_strangs_matrix(strangs_matrix(10)) == true
end

@testset "Test strangs lazy multiply" begin
    A = LazyStrangsMatrix(4)
    b = [1., 2., 3., 4.]    
    @test A*b == [0.0, 0.0, 0.0, -5.0]
end
