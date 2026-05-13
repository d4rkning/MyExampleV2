import Random

trials = 10_000_000
count = 0
for i=1:trials
    u,v = 2rand(Float64, 2) .- 1
    count += sqrt(u^2 +v^2 <= 1)
end
println(count/trials*4)