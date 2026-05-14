module MyExampleV2
using ForwardDiff
using LinearAlgebra
using IterativeSolvers

include("functions.jl")
include("strangsmatrix.jl")
include("my_factorial.jl")
include("myrange.jl")
include("linspace.jl")

export my_f, derivative_of_my_f
export strangs_matrix, LazyStrangsMatrix, StrangsMatrix
export my_factorial
export MyRange
export LinSpace

end