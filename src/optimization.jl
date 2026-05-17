using Optim
f(x) = sin(x)+cos(x)
Optim.optimize(f, 0.0, 2π)

f(x) = sin(x[1])+cos(x[1]+x[2])
Optim.optimize(f, zeros(2))
Optim.optimize(f, zeros(2), BFGS())

f(x) = (1 - 8*x[1] + 7*x[1]^2-(7/3)*x[1]^3+(1/4)*x[1]^4)*x[2]^2*exp(-1*x[2])
Optim.optimize(f, [2.0, 2.0])