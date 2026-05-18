using Flux
using CUDA
using Statistics
using Plots
using DifferentialEquations
device = gpu_device()


NNODE = Chain(x -> [x],
    Dense(1 => 32, tanh),
    Dense(32 => 1),
    first 
)

# Explicitly pass the model `m` to avoid variable shadowing
g(t, m) = t*m(t) + 1f0

ϵ = sqrt(eps(Float32))
# Use an array comprehension [...] to ensure Zygote compatibility
loss(m) = mean([abs2(((g(t+ϵ, m)-g(t, m))/ϵ) - cos(2π*t)) for t in 0:1f-2:1f0])

opt_state = Flux.setup(Flux.Descent(0.01), NNODE)

# An explicit training loop replaces `Flux.train!` and the unused `cb`
for epoch in 1:5000
    val, grads = Flux.withgradient(loss, NNODE)
    Flux.update!(opt_state, NNODE, grads[1])
    if epoch % 500 == 0 
        println("Epoch: $epoch, Loss: $val")
    end
end

t = 0:0.001:1.0;
plot(t, g.(t, Ref(NNODE)), label="NN")
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

# Generate the dataset
t = 0:3.3:10
dataset = sol(t)
position_data = [state[2] for state in dataset.u]
force_data = [force(state[1],state[2],k,current_t) for (state, current_t) in zip(dataset.u, t)]

plot(plot_t,force_plot,xlabel="t",label="True Force")
scatter!(t,force_data,label="Force Measurements")

NNForce = Chain(x -> [x],
    Dense(1 => 32, tanh),
    Dense(32 => 1),
    first 
)
random_positions = [2rand()- 1 for i in 1:100]
loss_ode(m) = sum(abs2, m(x) - (-k*x) for x in random_positions)
loss_ode(NNForce)
λ = 0.1
composed_loss(m) = loss(m) + λ*loss_ode(m)
opt_state = Flux.setup(Flux.Descent(0.01), NNForce)

for epoch in 1:5000
    val, grads = Flux.withgradient(composed_loss, NNForce)
    Flux.update!(opt_state, NNForce, grads[1])
    if epoch % 500 == 0 
        println("Epoch: $epoch, Loss: $val")
    end
end
composed_loss(NNForce)
learned_force_plot = NNForce.(positions_plot)
plot(plot_t, force_plot, xlabel="t", label="True force")
plot!(plot_t, learned_force_plot, label="Predicted Force")
scatter!(t, force_data, label="Force Measurements")
