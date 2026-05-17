using DifferentialEquations
using Plots

p = (1.0, 2.0, 1.5, 1.25)
f = function (du, u, p, t)
    a, b, c, d = p
    du[1] = a*u[1] - b*u[1]*u[2]
    du[2] = -c*u[2] + d * u[1] * u[2]
end
u0 = [1.0; 1.0]
tspan = (0.0, 10.0)
prob = ODEProblem(f, u0, tspan, p);
sol = solve(prob)

gr()
plot(sol, title="All plots.jl Attributes are Available")
plot(sol, title="Phase diagram", vars=(1,2))

@show sol.t[3]
@show sol[3]
@show sol(5)

