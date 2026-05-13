using Plots
T = 200
alphas = [0 0.5 0.99]
alphas_count = size(alphas)[2]
xs = zeros(T, alphas_count)

for alpha_i = 1:alphas_count
    alpha = alphas[alpha_i]
    for t = 2:T
        xs[t, alpha_i] = xs[t-1, alpha_i]*alpha + randn()
    end
end

labels = ["Alpha = $a" for a in alphas]
plot(xs, title="AR1 plot under different values of alpha", label=labels)