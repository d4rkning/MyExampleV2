struct Dual
    x::Float64
    dx::Float64
end

Base.:+(a::Dual, b::Dual) = Dual(a.x + b.x, a.dx + b.dx)
Base.:*(a::Dual, b::Dual) = Dual(a.x * b.x, b.dx * a.x + b.x * a.dx)
Base.:-(a::Dual, b::Dual) = Dual(a.x - b.x, a.dx - b.dx)
Base.:/(a::Dual, b::Dual) = Dual(a.x / b.x, (a.dx * b.x - a.x * b.dx) / b.x^2)
Base.sin(a::Dual) = Dual(sin(a.x), cos(a.x) * a.dx)
Base.cos(a::Dual) = Dual(cos(a.x), -sin(a.x) * a.dx)    


f(x::Dual) = sin(x) + x*x
f(Dual(2, 1))
g(x::Dual, y::Dual) = x*y
g(Dual(2, 1), Dual(3, 1))

struct MultiVariateDual
    x::Float64
    dx::Vector{Float64}
end

Base.:+(a::MultiVariateDual, b::MultiVariateDual) = MultiVariateDual(a.x + b.x, a.dx + b.dx)
Base.:*(a::MultiVariateDual, b::MultiVariateDual) = MultiVariateDual(a.x * b.x, b.dx * a.x + b.x * a.dx)

Base.:+(a::Float64, b::MultiVariateDual) = MultiVariateDual(a + b.x, b.dx)
Base.:+(a::MultiVariateDual, b::Float64) = b + a

Base.:*(a::Float64, b::MultiVariateDual) = MultiVariateDual(a * b.x, a .* b.dx)
Base.:*(a::MultiVariateDual, b::Float64) = b * a

Base.:-(a::Float64, b::MultiVariateDual) = MultiVariateDual(a - b.x, -b.dx)
Base.:-(a::MultiVariateDual, b::Float64) = MultiVariateDual(a.x - b, a.dx)

Base.:/(a::MultiVariateDual, b::MultiVariateDual) = MultiVariateDual(a.x / b.x, (b.x .* a.dx .- a.x .* b.dx) ./ (b.x^2))
Base.:/(a::MultiVariateDual, b::Real) = MultiVariateDual(a.x / b, a.dx ./ b)

Base.:^(a::MultiVariateDual, p::Real) = MultiVariateDual(a.x^p, (p * a.x^(p-1)) .* a.dx)

Base.exp(a::MultiVariateDual) = MultiVariateDual(exp(a.x), exp(a.x) .* a.dx)

Base.log(a::MultiVariateDual) = MultiVariateDual(log(a.x), a.dx ./ a.x)

h(x::MultiVariateDual, y::MultiVariateDual) = x+y

h(MultiVariateDual(2.0, [1.0, 0.0]), MultiVariateDual(3.0, [0.0, 1.0]))

i(x::MultiVariateDual, y::MultiVariateDual) = x*y
i(MultiVariateDual(2.0, [1.0, 0.0]), MultiVariateDual(3.0, [0.0, 1.0]))