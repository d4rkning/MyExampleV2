using Plots
function ss_logistic_regression(r, b0)
    bn = b0
    for i = 1:400
        bn = r*bn*(1-bn)
    end
    ys = zeros(150)
    for i = 1:150
        bn = r*bn*(1-bn)
        ys[i] = bn
    end
    return ys
end

rs =  range(2.9, 4.0, step=0.001)
ys = zeros(size(rs)[1], 150)
for (i, r) in enumerate(rs)
    y = ss_logistic_regression(r, 0.25)
    ys[i, :] = y
end

plot(rs, ys, label=false, lc=:black)