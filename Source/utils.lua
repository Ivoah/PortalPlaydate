function math.sign(x)
    return x < 0 and -1 or 1
end

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

function math.clampAbs(val, bound)
    return math.clamp(val, -bound, bound)
end
