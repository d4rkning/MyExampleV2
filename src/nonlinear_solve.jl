using Roots
using NLsolve

e = 1
f(x) = 10 - x + e*sin(x)
find_zero(f, -2)

function f(x)
    [(x[1]+3)*(x[2]^3-7)+18,
     sin(x[2]*exp(x[1])-1)
    ]
end

sol = nlsolve(f, [0.1, 1.2])
sol.zero

function f!(F, x)
    F[1] = x[1] + x[2] + x[3]^2 - 12
    F[2] = x[1]^2 - x[2] + x[3] - 2
    F[3] = 2*x[1] - x[2]^2 + x[3] - 1
end

sol = nlsolve(f!, [1.0, 1.0, 1.0], autodiff=:forward)
sol.zero