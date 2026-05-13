module MyExampleV2
using ForwardDiff

include("functions.jl")
include("strangsmatrix.jl")
include("my_factorial.jl")

export my_f, derivative_of_my_f
export strangs_matrix
export my_factorial

end