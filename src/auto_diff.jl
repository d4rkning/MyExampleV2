using LinearAlgebra
using ForwardDiff
using Plots 

f(x) = x^5 + 3*x^2
dfdx(x) = 5*x^4 + 6*x


xs = LinRange(0, 1, 100)
auto_derivs = zeros(size(xs));
derivs = zeros(size(xs));
auto_derivs .= ForwardDiff.derivative.(f, xs);
derivs .= dfdx.(xs);

plot(auto_derivs, labels="Auto forward derivative")
plot!(derivs, lw=3, ls=:dot, labels="Analytical derivative")
title!("Comparing analytical derivative & auto forward derivative")
xlabel!("X")
ylabel!("Y")

function sphere_to_cart(coordinates)
    r, θ, φ = coordinates
    x = r*sin(θ)*cos(φ)
    y = r*sin(θ)*sin(φ)
    z = r*cos(θ)
    [x, y ,z]
end

ρ, θ, ϕ = 2.4, π/3, π/2
coordinates = [ρ, θ, ϕ]
J = ForwardDiff.jacobian(sphere_to_cart, coordinates)
detJ = det(J)
det_analytical = ρ^2 * sin(θ)
det_analytical ≈ detJ