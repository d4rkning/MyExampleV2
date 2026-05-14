module MyExampleV2
using ForwardDiff
using Unitful

include("functions.jl")
include("strangsmatrix.jl")
include("my_factorial.jl")
include("myrange.jl")
include("linspace.jl")

export my_f, derivative_of_my_f
export strangs_matrix
export my_factorial
export MyRange
export LinSpace

end