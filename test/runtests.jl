using SafeTestsets
@safetestset "Benchmark Tests" begin include("functionstest.jl") end
@safetestset "Strangs matrix Tests" begin include("strangsmatrixtest.jl") end
@safetestset "Factorial Tests" begin include("factorialtest.jl") end
@safetestset "MyRage Tests" begin include("myrangetests.jl") end
@safetestset "LinSpace tests" begin include("linspacetest.jl") end
@safetestset "distribution quantile tests" begin include("distributionquantiletest.jl") end
@safetestset "my eval poly tests" begin include("myevalpolytest.jl") end