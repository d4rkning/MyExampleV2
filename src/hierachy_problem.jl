abstract type AbstractPerson end
abstract type AbstractStudent <: AbstractPerson end

struct Person <: AbstractPerson
    name
end

struct Student <: AbstractStudent 
    name
    grade
end

struct GraduateStudent <: AbstractStudent
    name 
    grade
end



function person_info(p::AbstractPerson)
    println(p.name)
end

function person_info(p::AbstractStudent)
    println(p.name, " ", p.grade)
end

s = Student("Bob", 10.0)
p = Person("Alice")
sg = Student("Marley", 10.0)

person_info(p)
person_info(s)
person_info(sg)