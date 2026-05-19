using Plots, BenchmarkTools, StaticArrays
function calc_attractor_matrix!(out_matrix, rs; warmup=400, x0=0.5f0)
    num_attract, num_rs = size(out_matrix)
    
    # Initialize a state vector for all r values
    x = fill(x0, num_rs)
    
    # Warmup
    for _ in 1:warmup
        x .= rs .* x .* (1.0f0 .- x)
    end
    
    # Attractor
    @inbounds for i in 1:num_attract
        x .= rs .* x .* (1.0f0 .- x)
        out_matrix[i, :] .= x
    end
    
    return out_matrix
end
function calc_attractor_matrix_fast!(out_matrix, rs; warmup=400, x0=0.5f0)
    num_attract, num_rs = size(out_matrix)
    
    # We can use a StaticArray or a standard Vector for the local state.
    # A standard vector allocated once at the start is fine.
    x = fill(x0, num_rs)
    
    # Warmup phase
    for _ in 1:warmup
        @inbounds @simd for j in 1:num_rs
            x[j] = rs[j] * x[j] * (1.0f0 - x[j])
        end
    end
    
    # Attractor phase
    for i in 1:num_attract
        @inbounds @simd for j in 1:num_rs
            x[j] = rs[j] * x[j] * (1.0f0 - x[j])
            out_matrix[i, j] = x[j]
        end
    end
    
    return out_matrix
end

function calc_attractor_matrix_faster!(out_matrix, x_cache, rs; warmup=400)
    num_attract, num_rs = size(out_matrix)
    
    # Warmup phase
    for _ in 1:warmup
        @inbounds @simd for j in 1:num_rs
            x_cache[j] = rs[j] * x_cache[j] * (1.0f0 - x_cache[j])
        end
    end
    
    # Attractor phase
    for i in 1:num_attract
        @inbounds @simd for j in 1:num_rs
            x_cache[j] = rs[j] * x_cache[j] * (1.0f0 - x_cache[j])
            out_matrix[i, j] = x_cache[j]
        end
    end
    
    return out_matrix
end
# Setup
rs = 2.9f0:0.0001f0:4.0f0;
num_attract = 150;
out_matrix = zeros(Float32, num_attract, length(rs));
x_cache = fill(0.25f0, length(rs));

# Execution
@btime calc_attractor_matrix_fast!(out_matrix, rs; warmup=400);
# Create an array of r values matching the dimensions of 'out'
r_matrix = repeat(rs', num_attract, 1);

# Plot as small, transparent scatter points
scatter(r_matrix, out_matrix, 
    legend=false, 
    markersize=1, 
    markerstrokewidth=0, 
    alpha=0.2, 
    color=:black,
    xlabel="r", 
    ylabel="X")