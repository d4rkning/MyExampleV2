using Lux, Optimisers, Enzyme, ComponentArrays, Random, InteractiveUtils, Statistics, Plots, DifferentialEquations
NN = Chain(Dense(10 => 32,tanh),
           Dense(32 => 32,tanh),
           Dense(32 => 5))
ps, st = Lux.setup(Xoshiro(0), NN)
loss(p) = sum(abs2, sum(abs2, NN(rand(Float32, 10), p, st)[1] .- 1f0) for i in 1:100)
loss(ps)

tstate = Lux.Training.TrainState(NN, ps, st, Adam(0.1f0))
function opt_loss(model, p, st, x)
    pred, st_new = model(x, p, st)
    return sum(abs2, pred.- 1f0), st_new, ()
end

for epoch in 1:10_000
    global tstate
    x = rand(Float32, 10, 128)
    _, _, _, tstate = Lux.Training.single_train_step!(
        AutoEnzyme(), opt_loss, x, tstate
    )
end

loss(tstate.parameters)

scalar_to_vector(x::Number) = reshape([x], 1, 1)
scalar_to_vector(x::AbstractVector) = reshape(x, 1, length(x))
scalar_to_vector(x::AbstractMatrix) = x

NNODE = Chain(
    WrappedFunction(scalar_to_vector),
    Dense(1 => 32, tanh),
    Dense(32 => 1))
ps, st = Lux.setup(Xoshiro(0), NNODE)
NNODE(1.0f0, ps, st)[1]

struct ModelWrapper{M} <: AbstractLuxWrapperLayer{:model}
    model::M
end

function(m::ModelWrapper)(t, p, st)
    y, st = m.model(t, p, st)
    return scalar_to_vector(t) .* y .+ 1.f0, st
end

model = ModelWrapper(NNODE)
ps, st = Lux.setup(Xoshiro(0), model)
model(1.0f0, ps, st)[1]


tstate = Lux.Training.TrainState(model, ps, st, Descent(0.01f0))

function opt_loss(model, p, st, ts)
    ϵ = sqrt(eps(Float32))
    ts_plus_ϵ = ts .+ ϵ

    y, st = model(ts, p, st)
    y_plus_ϵ, st = model(ts_plus_ϵ, p, st)

    diff = (y_plus_ϵ .- y) ./ ϵ
    return MSELoss()(diff, cos.(Float32(2π) .* ts)), st, (;)
end

for epoch in 1:5000
    global tstate
    _, loss, _, tstate = Lux.Training.single_train_step!(
      AutoEnzyme(), opt_loss, reshape(collect(0f0:1f-2:1f0), 1, :), tstate
    )
    if epoch % 500 == 0 || epoch == 1
        @info "Training" epoch loss
    end
end

t = 0f0:0.001f0:1f0
g(t, p) = model(t, p, tstate.states)[1]
plot(t, vec(g(t, tstate.parameters)), label="NN")
plot!(t, 1.0 .+ sin.(2π.*t)/2π, label="True solution")

k = 1.0
force(dx, x, k, t) = -k*x + 0.1sin(x)
prob = SecondOrderODEProblem(force, 1.0, 0.0, (0.0, 10.0), k)
sol = solve(prob)
plot(sol, label=["Velocity", "Position"])

plot_t = 0:0.01:10
data_plot = sol(plot_t)
positions_plot = [state[2] for state in data_plot.u]
force_plot = [force(state[1],state[2],k,current_t) for (state, current_t) in zip(data_plot.u, plot_t)]

t = 0:3.3:10
dataset = sol(t)
position_data = [state[2] for state in dataset.u]
force_data = [force(state[1],state[2],k,current_t) for (state, current_t) in zip(dataset.u, t)]

plot(plot_t,force_plot,xlabel="t",label="True Force")
scatter!(t,force_data,label="Force Measurements")

NNForce = Chain(
    WrappedFunction(scalar_to_vector),
    Dense(1 => 32, tanh),
    Dense(32 => 1))
ps2, st2 = Lux.setup(Xoshiro(0), NNForce)
tstate2 = Lux.Training.TrainState(NNForce, ps2, st2, Descent(0.1f0))

function opt_loss_force(model, p, s, (position_data, force_data))
    pos = Float32.(position_data)
    force = scalar_to_vector(Float32.(force_data))
    force_pred, st = model(pos, p, s)
    return MSELoss()(force_pred, force), st, ()
end

for epoch in 1:5000
    global tstate2
    _, loss_val, _, tstate2 = Lux.Training.single_train_step!(
        AutoEnzyme(), opt_loss_force, (position_data, force_data), tstate2
    )
    if epoch % 500 == 0
        @info "Training" epoch loss_val
    end
end

learned_force_plot = vec(
    NNForce(Float32.(positions_plot), tstate2.parameters, tstate2.states)[1]
)

plot(plot_t, force_plot, xlabel="t", label="True force")
plot!(plot_t, learned_force_plot, label="Predicted Force")
scatter!(t, force_data, label="Force Measurements")

force2(dx, x, k, t) = -k*x
prob_simplified = SecondOrderODEProblem(force2, 1.0, 0.0, (0.0, 10.0), k)
sol_simplified = solve(prob_simplified)
plot(sol, label=["Velocity" "Position"])
plot!(sol_simplified, label=["Velocity simplified" "Position simplified"], ls=:dash)

tstate2 = Lux.Training.TrainState(NNForce, Lux.setup(Xoshiro(0), NNForce)..., Descent(0.01f0))
λ = 0.1f0
function opt_composed_loss(model, p, s, (pos, force, rand_pos))
    loss_force_val, s, _ = opt_loss_force(model, p, s, (pos, force, rand_pos))
    positions = scalar_to_vector(Float32.(rand_pos))
    force_pred, s = model(positions, p, s)
    loss_ode_val = MSELoss()(force_pred, Float32.(-k * positions))
    return (
        loss_force_val + λ * loss_ode_val,
        s,
        (; loss_force=loss_force_val, loss_ode=loss_ode_val)
    )
end

for epoch in 1:5000
    global tstate2
    rand_pos = 2 .* rand(Float32, 100) .- 1
    _, loss, stats, tstate2 = Lux.Training.single_train_step!(
        AutoEnzyme(), opt_composed_loss, (position_data, force_data, rand_pos), tstate2)
    if epoch % 500 == 0
        @info "Training" epoch loss stats.loss_force stats.loss_ode
    end
end

learned_force_plot = vec(
    NNForce(Float32.(positions_plot), tstate2.parameters, tstate2.states)[1]
)

plot(plot_t, force_plot, xlabel="t", label="True force")
plot!(plot_t, learned_force_plot, label="predicted force")
scatter!(t, force_data, label="Force measurements")