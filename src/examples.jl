α = 0.5
∇f(u) = α*u; ∇f(2)
sin(2π)

@code_llvm 2*5
@code_warntype 2^5

2 + 5.

1/2
1.0/2

map((x) -> x^2, 1:5)
A = 1:5
B = [ 
    1 2
    3 4
    5 6
    7 8
    9 10
]

broadcast(+, A, B)
A = 1:5
B = [2;3;4;5;6]
A.*B

A = rand(4, 4)
A[1:3, :]

ff(x::Union{Int, Int32}, y::Int) = 2x+y
ff(x::Float64, y::Float64) = x/y
@code_llvm ff(2, 5)
@code_llvm ff(2.0, 5.0)

ff(x, y) = 2x + 2y

a= [1., 2., 3.]
typeof(a)
a[1]
b = ["1.0", 2, 2.0]
typeof(b)

function bad_container(a)
    a[2]
end
@code_warntype bad_container(b)

f(x, y) = x + y
x = Number[1.0, 3]
function q(x)
    a = 4
    b = 2
    c = f(x[1], a)
    d = f(b, c)
    f(d, x[2])
end

@code_warntype q(x)
using BenchmarkTools
@btime q(x)
x = [1.0, 3.0]
@btime q(x)

isbits(1.0)

function g(x, y)
    a = 4
    b = 2
    c = f(x, a)
    d = f(b, c)
    f(d, y)
end

struct Mycomplex
    real::Float64
    imag::Float64
end

isbits(Mycomplex(1.0, 1.0))

Base.:+(a::Mycomplex, b::Mycomplex) = Mycomplex(a.real + b.real, a.imag + b.imag)
Base.:+(a::Mycomplex, b::Int) = Mycomplex(a.real + b, a.imag)
Base.:+(a::Int, b::Mycomplex) = Mycomplex(a + b.real, b.imag)
g(Mycomplex(1.0, 1.0), Mycomplex(1.0, 1.0))
@code_warntype g(Mycomplex(1.0, 1.0), Mycomplex(1.0, 1.0))
@code_llvm g(Mycomplex(1.0, 1.0), Mycomplex(1.0, 1.0))

struct MyParameterizedComplex{T}
    real::T
    image::T
end

isbits(MyParameterizedComplex(1.0, 1.0))
Base.:+(a::MyParameterizedComplex, b::MyParameterizedComplex) = MyParameterizedComplex(a.real + b.real, a.image + b.image)
Base.:+(a::MyParameterizedComplex, b::Int) = MyParameterizedComplex(a.real + b, a.image)
Base.:+(a::Int, b::MyParameterizedComplex) = MyParameterizedComplex(a + b.real, b.image)
g(MyParameterizedComplex(1.0, 1.0), MyParameterizedComplex(1.0, 1.0))