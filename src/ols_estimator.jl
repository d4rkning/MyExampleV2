using Plots

X = rand(1000, 3)
a0 = rand(3)
y = X * a0 + 0.1 * randn(1000);
println(size(y))
Xpred = hcat(ones(1000), X)
β = (Xpred'*Xpred)\Xpred'*y
sum(((Xpred*β -  y).^2))/1000

p = scatter()
scatter!(X, y)


