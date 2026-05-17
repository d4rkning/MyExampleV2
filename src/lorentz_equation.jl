using DifferentialEquations
using Plots


p = (28.0, 10.0, 8.0/3.0)

lorenz = function(du, u, p, t)
    ρ, σ, β = p

    du[1] = σ*(u[2] - u[1])
    du[2] = u[1]*(ρ - u[3]) - u[2]
    du[3] = u[1]*u[2] - β*u[3]
end

u0 = big.([0.1, 0.0, 0.0]);
tspan = (big(0.0), big(100.0));
lorenz_prob = ODEProblem(lorenz, u0, tspan, p);
sol = solve(lorenz_prob)
gr()
plot(sol)
plot(sol, vars=(1, 2, 3))