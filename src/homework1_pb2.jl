using Distributions
"""
Find the quantile of a cdf by iterating through newtons method.
Using x_{n+1} = x_n + \frac{g(x_n)}{g'(x_n)}
Let F(x) be the cdf then F'(x) = f(x) = pdf(x)
x_{n+1} = x_n + \frac{F(x_n)}{f(x_n)}
To find the yth quantile we get
x_{n+1} = x_n + \frac{cdf(x)-y}{pdf(x)}
"""

function quantile_newton(d, y, x0,
                         tol=1e-10,
                         maxiter=100)
    x = x0
    for i in 1:maxiter
        step = (cdf(d, x) - y) / pdf(d, x)
        x_new = x - step

        if abs(x_new - x) < tol
            return x_new
        end

        x = x_new
    end

    error("did not converge")
end

d = Beta(2, 4)
quantile_newton(d, 0.99, mean(d))