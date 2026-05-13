using SafeTestsets
@safetestset "Benchmark Tests" begin include("functionstest.jl") end
@safetestset "Benchmark Tests" begin include("strangsmatrixtest.jl") end
@safetestset "Benchmark Tests" begin include("factorialtest.jl") end