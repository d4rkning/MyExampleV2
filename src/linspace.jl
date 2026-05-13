struct LinSpace
    start
    stop
    length
end

function Base.getindex(a::LinSpace, i::Int)
    if i < 1 || i > a.length
        throw(BoundsError("Attempted to access out of bounds"))
    end
    return a.start + ((a.stop - a.start) / (a.length - 1)) * (i - 1)
end

