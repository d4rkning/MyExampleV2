for i = 1:5
    println(i)
end

t = 0
while t < 5
    println(t)
    t += 1
end

school = :UCI

if school == :UCI
    println("ZotZotZot")
else
    println("Not even worth discussing")
end

for i=1:2,j=2:4
    println(i*j)
end
f(x,y,z,w) = x+y+z+w
@time f(1,1,1,1)
@time f(1,1,1,1)
@time f(1,1,1,1)
@time f(1,1,1,1.0)
@time f(1,1,1,1.0)

struct Field
    name
    school
end

ds = Field(:DataScience, [:PhysicalScience,:ComputerScience])
ds.name