struct StrangsMatrix
    mat::Matrix{Float64}
 end

struct LazyStrangsMatrix
    N::Int
end

function strangs_matrix(N)::StrangsMatrix
    strangs_matrix = Matrix{Float64}(undef, N, N)
    strangs_matrix = zero(strangs_matrix)
    for i = 1:N
        strangs_matrix[i, i] = -2;
        if i-1 > 0
            strangs_matrix[i, i-1] = 1
        end
        if i+1 <= N
            strangs_matrix[i, i+1] = 1
        end
    end

    return StrangsMatrix(strangs_matrix)
end

Base.size(mat::StrangsMatrix) = size(mat.mat)
Base.getindex(mat::StrangsMatrix, i::Int, j::Int) = mat.mat[i, j]
Base.getindex(mat::StrangsMatrix, i::Int, j::Colon) = mat.mat[i, :]
Base.getindex(mat::StrangsMatrix, i::Colon, j::Int) = mat.mat[:, j]

Base.size(mat::LazyStrangsMatrix) = (mat.N, mat.N)

# 1. Define the scalar case FIRST (The most fundamental)
function Base.getindex(mat::LazyStrangsMatrix, i::Int, j::Int)
    # Bounds check (optional but recommended)
    if !(1 <= i <= mat.N && 1 <= j <= mat.N)
        throw(BoundsError(mat, (i, j)))
    end

    if i == j
        return -2.0
    elseif abs(i - j) == 1
        return 1.0
    else
        return 0.0
    end
end

# 2. Define the Column Slice [:, j]
function Base.getindex(mat::LazyStrangsMatrix, ::Colon, j::Int)
    # We return a vector representing the j-th column
    # In a Strang matrix, column j has values at j-1, j, j+1
    d = zeros(mat.N)
    d[j] = -2.0
    if j > 1
        d[j-1] = 1.0
    end
    if j < mat.N
        d[j+1] = 1.0
    end
    return d
end

# 3. Define the Row Slice [i, :]
function Base.getindex(mat::LazyStrangsMatrix, i::Int, ::Colon)
    # For a symmetric Strang matrix, row i is the same logic as column j
    # We can just call the column slice logic or repeat it
    return mat[:, i] 
end
  
function _MulLazyStrangsMatrix(A::LazyStrangsMatrix, b::Vector{Float64})::Vector{Float64}
    n = A.N
    out = zeros(n)
    
    for i in 1:n
        val = -2.0 * b[i]
        if i > 1
            val += 1.0 * b[i-1]
        end
        if i < n
            val += 1.0 * b[i+1]
        end
        out[i] = val
    end
    return out
end

Base.:*(A::LazyStrangsMatrix, b::Vector{Float64}) = _MulLazyStrangsMatrix(A, b)
