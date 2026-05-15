import Distributions
using LinearAlgebra
using Plots

function pascals_row_fast(row_index::Int64)::Vector{Int64}
    row = zeros(Int64, row_index+1)
    row[1] = 1
    row[end] = 1
    for i = 1:row_index>>1
        x = row[i] * (row_index - i + 1) ÷ i
        row[i+1] = x
        row[row_index - i + 1] = x
    end
    return row
end

function shift_left!(array::AbstractVector)
    for i= 1:length(array)-1
        array[i] = array[i+1]
    end
end

function polynomial_finder(roots::Vector{Float64})
    n = length(roots)
    p = zeros(Float64, n + 1)
    p[1] = 1.0  # Represents the coefficient of the highest power x^n

    for (k, r) in enumerate(roots)
        # We only iterate up to k+1 because at step k, 
        # the polynomial only has a degree of k.
        for i = (k + 1):-1:2
            p[i] = p[i] - r * p[i-1]
        end
    end
    return p
end

function make_companion_matrix(coefficients)
    M = zeros(length(coefficients)-1, length(coefficients)-1)
    n = length(coefficients)-1
    for i = 2:n
        M[i, i-1] = 1
    end
    for i = 1:n
        M[i, end] = -1*coefficients[end-i+1]
    end
    println(M)
    return M 
end

function pertubate_coefficients(matrix::Matrix{Float64}, ϵ::Float64)::Matrix{Float64}
    r_matrix = deepcopy(matrix)
    rk = Distributions.Normal()
    rows = size(r_matrix)[1]
    r_matrix[:, end]= r_matrix[:, end].*(1.0.+ϵ.*rand(rk, rows))
    return r_matrix
end

function analyze_coefficients_pertubations()
    coefficients = polynomial_finder(collect(1.:1.:20.))
    companion_matrix = make_companion_matrix(coefficients)
    pert_companion_matrix = pertubate_coefficients(companion_matrix, 1e-10)
    norm(companion_matrix - pert_companion_matrix)

    roots = LinearAlgebra.eigen(companion_matrix)
    pert_roots = LinearAlgebra.eigen(pert_companion_matrix)

    scatter(real.(roots.values), imag.(roots.values), label="Original roots")
    scatter!(real.(pert_roots.values), imag.(pert_roots.values), label="Perturbed roots")
end