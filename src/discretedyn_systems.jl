using Plots, BenchmarkTools, StaticArrays
"""
`solve_system(f, u0, p, n)`
Solves teh dynamical system
``u_{n+1} = f(u_n)``

for N steps. Returns the solution at step `n` with parameters `p`.
"""
function solve_system(f, u0, p,n )
    u = u0
    for i in 1:n-1
        u = f(u, p)
    end
    u
end

function solve_system_save(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  u[1] = u0
  for i in 1:n-1
    u[i+1] = f(u[i],p)
  end
  u
end

function solve_system_save!(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  du = similar(u0)
  u[1] = u0
  for i in 1:n-1
    f(du, u[i], p)
    u[i+1] = du
  end
  u
end

function solve_system_save_push(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,1)
  u[1] = u0
  for i in 1:n-1
    push!(u,f(u[i],p))
  end
  u
end

function solve_system_save_matrix(f,u0,p,n)
  u = Matrix{eltype(u0)}(undef,length(u0),n)
  u[:,1] = u0
  for i in 1:n-1
    u[:,i+1] = f(@view(u[:,i]),p)
  end
  u
end

function solve_system_save_matrix_resize(f, u0, p, n)
    u = Matrix{eltype(u0)}(undef, length(u0), 1)
    u[:, 1] = u0
    for i in 1:n-1
        u = hcat(u, f(@view(u[:, i]), p))
    end
    u
end

function solve_system_save_copy(f, u0, p, n)
    u = Vector{typeof(u0)}(undef, n)
    du = similar(u0)
    u[1] = u0
    for i in 1:n-1
        f(du, u[i], p)
        u[i+1] = copy(du)
    end
end

function solve_system_mutate(f, u0, p, n)
    du = similar(u0); u = copy(u0);
    for i in 1:n-1
        f(du, u, p)
        u .= du
    end
end

function solve_system_save_static(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  @inbounds u[1] = u0
  @inbounds for i in 1:n-1
    u[i+1] = f(u[i],p)
  end
  u
end
function solve_system_save!(u,f,u0,p,n)
  @inbounds u[1] = u0
  @inbounds for i in 1:length(u)-1
    u[i+1] = f(u[i],p)
  end
  u
end

function lorenz(u,p)
  α,σ,ρ,β = p
  du1 = u[1] + α*(σ*(u[2]-u[1]))
  du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
  du3 = u[3] + α*(u[1]*u[2] - β*u[3])
  [du1,du2,du3]
end

function lorenz!(du, u, p)
  α,σ,ρ,β = p
  du[1] = u[1] + α*(σ*(u[2]-u[1]))
  du[2] = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
  du[3] = u[3] + α*(u[1]*u[2] - β*u[3])
end

function lorenz_static(u,p)
  α,σ,ρ,β = p
  @inbounds begin
    du1 = u[1] + α*(σ*(u[2]-u[1]))
    du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du3 = u[3] + α*(u[1]*u[2] - β*u[3])
  end
  @SVector [du1,du2,du3]
end

f(u, p) = u^2 - p*u
typeof(f)

solve_system(f, 1.0, 0.25, 1000)
solve_system(f, 1.22, 0.25, 1000)
solve_system(f, 1.25, 0.25, 1000)
solve_system(f, 1.251, 0.25, 1000)
solve_system(f, 1.251, 0.25, 100)
solve_system(f, 1.251, 0.25, 10)

p = (0.02, 10.0, 28.0, 8/3)
solve_system(lorenz, [1.0, 0.0, 0.0], p, 1000)
to_plot = solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
x = [to_plot[i][1] for i in 1:length(to_plot)]
y = [to_plot[i][2] for i in 1:length(to_plot)]
z = [to_plot[i][3] for i in 1:length(to_plot)]
plot(x,y,z)
@btime solve_system_save(lorenz,[1.0,0.0,0.0],p,1000);
@btime solve_system_save_push(lorenz,[1.0,0.0,0.0],p,1000);
@btime solve_system_save_matrix(lorenz,[1.0,0.0,0.0],p,1000);
@btime solve_system_save_matrix_resize(lorenz,[1.0,0.0,0.0],p,1000);
@btime solve_system_save!(lorenz!, [1.0, 0.0, 0.0], p, 1000);
@btime solve_system_save_copy(lorenz!, [1.0, 0.0, 0.0], p, 1000);
@btime solve_system_mutate(lorenz!, [1.0, 0.0, 0.0], p, 1000);
@btime solve_system_save_static(lorenz_static, @SVector[1.0, 0.0, 0.0], p, 1000);
u = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,1000);
@btime solve_system_save!(u,lorenz_static,@SVector([1.0,0.0,0.0]),p,1000);