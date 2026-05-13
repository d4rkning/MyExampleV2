function strangs_matrix(N)
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

    return strangs_matrix
end