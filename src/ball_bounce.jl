using DifferentialEquations
using Plots

function ball(du, u, p, t)
    du[1] = u[2]
    du[2] = -9.81
end

u0 = [50.0, 0.0]
tspan = (0.0, 15.0)
condtion = function(u, t, integrator)
    u[1]
end
affect! = nothing
affect_neg!(integrator) = integrator.u[2] *= -0.8
cb = DifferentialEquations.ContinuousCallback(condtion, affect!, affect_neg!, interp_points=100)
prob = ODEProblem(ball, u0, tspan, callback = cb, adaptive = false, dt=1/4)
sol = solve(prob)

plot(sol)