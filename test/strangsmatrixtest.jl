using MyExampleV2
using Test

function test_strangs_matrix(matrix)
    N = size(matrix)
    if N[1] != N[2]
        return false 
    end
    for i=1:N[1]
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
    c = [1., 2., 3.]
    @test_throws BoundsError A*c

    A = LazyStrangsMatrix(1)
    b = [1.]
    @test A*b == [-2.0]
    
end

@testset "Test LazyStrangsMatrix indexing and properties" begin
    A = LazyStrangsMatrix(5)
    
    @testset "Size" begin
        @test size(A) == (5, 5)
    end
    
    @testset "Scalar Indexing" begin
        # Diagonal
        @test A[1, 1] == -2.0
        @test A[3, 3] == -2.0
        @test A[5, 5] == -2.0
        
        # Off-diagonal
        @test A[1, 2] == 1.0
        @test A[2, 1] == 1.0
        @test A[4, 5] == 1.0
        
        # Far off-diagonal
        @test A[1, 5] == 0.0
        @test A[5, 1] == 0.0
        @test A[2, 4] == 0.0
        
        # Bounds Errors
        @test_throws BoundsError A[0, 1]
        @test_throws BoundsError A[1, 0]
        @test_throws BoundsError A[-1, -1]
        @test_throws BoundsError A[6, 5]
        @test_throws BoundsError A[5, 6]
    end
    
    @testset "Slice Indexing" begin
        # Column slice
        @test A[:, 1] == [-2.0, 1.0, 0.0, 0.0, 0.0]
        @test A[:, 3] == [0.0, 1.0, -2.0, 1.0, 0.0]
        @test A[:, 5] == [0.0, 0.0, 0.0, 1.0, -2.0]
        
        # Row slice
        @test A[1, :] == [-2.0, 1.0, 0.0, 0.0, 0.0]
        @test A[3, :] == [0.0, 1.0, -2.0, 1.0, 0.0]
        @test A[5, :] == [0.0, 0.0, 0.0, 1.0, -2.0]
        
        # Bounds Errors on slices
        @test_throws BoundsError A[:, 0]
        @test_throws BoundsError A[:, 6]
        @test_throws BoundsError A[0, :]
        @test_throws BoundsError A[6, :]
    end
end
