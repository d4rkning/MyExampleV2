using BenchmarkTools, LinearAlgebra, DifferentialEquations, Plots
n = 100
GlbM = zeros(Float64, n, n);
GlbK = zeros(Float64, n, n);


function assemble!(M::Matrix{Float64}, K::Matrix{Float64}, α::Float64, h::Float64, N::Int64)
    Me = (h/6.0)*[2 1; 1 2]
    Ke = (α/h) * [1 -1; -1 1];
    @inbounds for i in 1:N-1
        @view(M[i:i+1, i:i+1]) .+= Me;
        @view(K[i:i+1, i:i+1]) .+= Ke;
    end
end

function bench_assemble(n)
    M = zeros(n, n)
    K = zeros(n, n)
    assemble!(M, K, 1.0, 0.01, n)
    return M, K;
end

assemble!(GlbM, GlbK, 1.0, 0.01, n)

upd = GlbM \ GlbK
function heat_equation!(du, u, p, t)
    du .= -(upd) * u
end

tspan = (0.0, 1.0);
u0 = fill(20.0, n);

prob = ODEProblem(heat_equation!, u0, tspan);
sol = solve(prob, Tsit5())

gr()
@userplot TempPlot
@recipe function f(tp::TempPlot)
    temp_profile = tp.args[1]
    n = size(temp_profile)[1]
    temp_profile
end

size(sol)
anim = @animate for i ∈ 1:size(sol)[2]-30000
    tempplot(sol[:, i]) end
gif(anim, "anim_fps15.gif", fps = 15)