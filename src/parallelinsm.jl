using Distributed, StaticArryas, BenchmarkTools, Statistics
@time sleep(2)

@time @sync for i in 1:10
    @async sleep(2)
end

function lorenz(u, p)
    α, σ, ρ, β = p
    @inbounds begin
        du1 = u[1] + α * (σ * (u[2] - u[1]))
        du2 = u[2] + α * (u[1] * (ρ - u[3]) - u[2])
        du3 = u[3] + α * (u[1] * u[2] - β * u[3])
    end
    @SVector[du1, du2, du3]
end

function solve_system_save!(u, f, u0, p, n)
    @inbounds u[1] = u0
    @inbounds for i in 1:length(u) - 1
        u[i+1] = f(u[i], p)
    end
    u
end

p = (0.02, 10.0, 28.0, 8/3)
u = Vector{typeof(@SVector([1.0, 0.0, 0.0]))}(undef, 1000)
@btime solve_system_save!(u, lorenz, @SVector([1.0, 0.0, 0.0]), p, 1000)

function lorenz_mt!(du, u, p)
    α, σ, ρ, β = p
    let du=du, u=u, p=p
        Threads.@threads for i in 1:3
            @inbounds begin
                if i == 1
                    du[1] = u[1] + α * (σ * (u[2] - u[1]))
                elseif i == 2
                    du[2] = u[2] + α * (u[1] * (ρ - u[3]) - u[2])
                else
                    du[3] = u[3] + α * (u[1] * u[2] - β * u[3])
                end
                nothing
            end
        end
    end
end

function solve_system_save_iip!(u, f, u0, p, n)
    @inbounds u[1] = u0
    @inbounds for i in 1:length(u)-1
        f(u[i+1], u[i], p)
    end
    u
end

p = (0.02, 10.0, 28.0, 8/3)
u = [Vector{Float64}(undef, 3) for i in 1:1000]
@btime solve_system_save_iip!(u, lorenz_mt!,[1.0, 0.0, 0.0], p, 1000)

function compute_trajectory_mean(u0, p)
    u = Vector{typeof(@SVector([1.0, 0.0, 0.0]))}(undef, 1000);
    solve_system_save!(u, lorenz, u0, p, 1000);
    mean(u)
end

@btime compute_trajectory_mean(@SVector([1.0, 0.0, 0.0]), p )

u = Vector{typeof(@SVector([1.0, 0.0, 0.0]))}(undef, 1000);
function compute_trajectory_mean2(u0, p)
    solve_system_save!(u, lorenz, u0, p, 1000);
    mean(u)
end

@btime compute_trajectory_mean2(@SVector([1.0, 0.0, 0.0]), p )