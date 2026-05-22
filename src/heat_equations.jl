using LinearAlgebra, DifferentialEquations, Plots, BenchmarkTools

struct HeatEquationParameters
    α::Float64
    h::Float64
    N::Int64
end

L = 1.0;
n = 100;
x = range(0, L, length=n);
h = L/(n-1);
α = 1.0;
heat_eq_parameters = HeatEquationParameters(α, h, n);

GlbM = zeros(Float64, n, n);
GlbK = zeros(Float64, n, n);

function assemble_heat_equation!(
    M::Matrix{Float64}, 
    K::Matrix{Float64}, 
    p::HeatEquationParameters
    )
    Me = (p.h/6.0) * [2 1; 1 2]
    Ke = (p.α/p.h)   * [1 -1; -1 1]
    @inbounds for i in 1:heat_eq_parameters.N-1
        @view(M[i:i+1, i:i+1]) .+= Me
        @view(K[i:i+1, i:i+1]) .+= Ke
    end
end

assemble_heat_equation!(GlbM, GlbK, heat_eq_parameters);
F = zeros(Float64, n);

# 1. Classical Initial Condition: A pure sine wave
u0 = sin.(π .* x ./ L)

# 2. Lock Left Boundary to 0 (Node 1)
GlbK[1, :] .= 0.0
GlbM[1, :] .= 0.0
GlbM[1, 1] = 1.0
u0[1] = 0.0         

# 3. Lock Right Boundary to 0 (Node n)
GlbK[end, :] .= 0.0
GlbM[end, :] .= 0.0
GlbM[end, end] = 1.0
u0[end] = 0.0      

# 4. Precompute inverse
Minv = inv(GlbM)

function heat_equation!(du, u, p, t)
    # p[1] is Minv, p[2] is GlbK, p[3] is F
    du .= p[1] * (-p[2] * u .+ p[3])
end

tspan = (0.0, 0.5)
p = (Minv, GlbK, F)

prob = ODEProblem(heat_equation!, u0, tspan, p)
sol = solve(prob, Tsit5(), saveat=0.01)

# ==========================================
# ANALYTICAL SOLUTION & PLOTTING
# ==========================================
gr()

# The exact mathematical solution to compare against
analytical(x, t, α, L) = sin.(π .* x ./ L) .* exp(-α * π^2 * t / L^2)

# Create animation comparing FEM to Analytical
anim = @animate for i ∈ 1:length(sol.t)
    t_current = sol.t[i]
    
    # Plot numerical FEM solution (thick red line)
    plot(x, sol.u[i], ylim=(0, 1.1), 
         ylabel="Temperature", xlabel="x (Position)", 
         title="Time: $(round(t_current, digits=2))s",
         label="FEM Numerical", color=:red, linewidth=4, alpha=0.5)
         
    # Overlay the exact analytical solution (dashed black line)
    plot!(x, analytical(x, t_current, α, L), 
          label="Exact Analytical", color=:black, linestyle=:dash, linewidth=2)
end

gif(anim, "classical_heat_equation.gif", fps = 15)