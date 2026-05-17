module MyExampleV2
using ForwardDiff
using LinearAlgebra
using IterativeSolvers
using RDatasets
using Clustering

include("functions.jl")
include("strangsmatrix.jl")
include("my_factorial.jl")
include("myrange.jl")
include("linspace.jl")
include("distribution_quantile_problem.jl")
include("metaprogramming.jl")

export my_f, derivative_of_my_f
export strangs_matrix, LazyStrangsMatrix, StrangsMatrix
export my_factorial
export MyRange
export LinSpace
export find_quantile
export @myevalpoly

end