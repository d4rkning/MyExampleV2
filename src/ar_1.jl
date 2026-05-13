T = 200
x = zeros(T)
for t = 2:T
    x[t] = x[t-1]*alpha + randn()
end