using LinearAlgebra, DifferentialEquations, Plots, SparseArrays

Base.@kwdef struct HeatEquationParameters{T<:Real, I<:Integer}
    α::T = 1.0        # Default value provided
    h::T              # No default, must be specified
    N::I = 100        # Default integer value
end

function assemble_sparse_matrices(p::HeatEquationParameters)
    Me = (p.h / 6.0) * [2.0 1.0; 1.0 2.0]
    Ke = (p.α / p.h) * [1.0 -1.0; -1.0 1.0]
    
    num_entries = 4 * (p.N - 1)
    I = zeros(Int, num_entries)
    J = zeros(Int, num_entries)
    
    # FIX: Use the exact type (T) from the parameter struct for type stability
    T_val = typeof(p.α) 
    V_M = zeros(T_val, num_entries)
    V_K = zeros(T_val, num_entries)
    
    idx = 1
    @inbounds for e in 1:(p.N - 1)
        nodes = (e, e+1)
        
        for local_i in 1:2, local_j in 1:2
            I[idx] = nodes[local_i]
            J[idx] = nodes[local_j]
            V_M[idx] = Me[local_i, local_j]
            V_K[idx] = Ke[local_i, local_j]
            idx += 1
        end
    end
    
    return sparse(I, J, V_M, p.N, p.N), sparse(I, J, V_K, p.N, p.N)
end

function apply_boundary_conditions_penalty!(M::SparseMatrixCSC, K::SparseMatrixCSC, F::Vector)
    # The penalty method applies BCs without destroying the sparse matrix structure
    penalty = 1e10
    
    # Lock Left Boundary to 0 (Node 1)
    K[1, 1] += penalty
    F[1] = 0.0 * penalty
    M[1, 1] = 1.0

    # Lock Right Boundary to 0 (Node n)
    K[end, end] += penalty
    F[end] = 0.0 * penalty
    M[end, end] = 1.0
end

# Non-allocating, in-place ODE function
function heat_equation!(du, u, p, t)
    K, F = p
    mul!(du, K, u)
    du .= F .- du 
end

function main()
    L = 1.0
    n = 100
    x = range(0, L, length=n)
    
    # Keeping everything Float64 to match the initial conditions and SciML tolerances
    h_val = L / (n - 1)
    α_val = 1.0
    params = HeatEquationParameters(N=n, h=h_val, α=α_val)

    # FIX: Assemble directly into sparse matrices. No zeros(n, n) dense matrices used!
    GlbM, GlbK = assemble_sparse_matrices(params)
    
    F = zeros(typeof(α_val), n)

    # Apply Penalty Boundary Conditions
    apply_boundary_conditions_penalty!(GlbM, GlbK, F)

    # Initial Condition
    u0 = sin.(π .* x ./ L)
    u0[1] = 0.0         
    u0[end] = 0.0      

    # Parameter tuple
    p = (GlbK, F)

    # Define the ODE function with the Mass Matrix AND Analytic Jacobian
    func = ODEFunction(
        heat_equation!, 
        mass_matrix=GlbM,
        jac_prototype=-GlbK # FIX: Speeds up the implicit solver significantly
    )

    tspan = (0.0, 0.5)
    prob = ODEProblem(func, u0, tspan, p)
    
    # Solve
    sol = solve(prob, Rodas5P(), saveat=0.01)

    # ==========================================
    # ANALYTICAL SOLUTION & PLOTTING
    # ==========================================
    gr()

    analytical(x, t, α, L) = sin.(π .* x ./ L) .* exp(-α * π^2 * t / L^2)

    # Reduced fps to 15 so the 50 frames play at a reasonable speed
    anim = @animate for i ∈ 1:length(sol.t)
        t_current = sol.t[i]
        
        plot(x, sol.u[i], ylim=(0, 1.1), 
             ylabel="Temperature", xlabel="x (Position)", 
             title="Time: $(round(t_current, digits=2))s",
             label="FEM Numerical", color=:red, linewidth=4, alpha=0.5)
             
        plot!(x, analytical(x, t_current, α_val, L), 
              label="Exact Analytical", color=:black, linestyle=:dash, linewidth=2)
    end

    gif(anim, "classical_heat_equation.gif", fps=15)
end

main()