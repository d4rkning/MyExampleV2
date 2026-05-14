struct MyRange{T<:Number}
    start::T
    step::T
    stop::T
end

function _MyRange(a::MyRange, i::Int)
    b = a.start + a.step * (i-1)
    if b > a.stop   
        throw(BoundsError("Attempted to access out of bounds"))
    elseif b < a.start
        throw(BoundsError("Attempted to access out of bounds"))
    end
    return b
end
Base.getindex(a::MyRange, i::Int) = _MyRange(a, i)
Base.getindex(a::MyRange, b::Float64) = a.start + a.step * (b-1)