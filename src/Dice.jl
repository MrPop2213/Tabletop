macro d_str(p)
    return parse_dice(p)
end

function parse_dice(p::String)
    p = lowercase(p)
    p = join(split(p), "")
    if '+' in p
        p, mod = split(p, '+')
        mod = parse(Int64, mod)
    else
        mod = 0
    end
    n, d = split(p,'d')
    mult = parse(Int64, n)
    dice = parse(Int64, d)
    return Dice(mult, dice, mod)
end

struct Dice
    mult
    dice
    mod
end

function Base.string(d::Dice)
    if d.mod != 0
        return "$(d.mult)d$(d.dice)+$(d.mod)"
    else
        return "$(d.mult)d$(d.dice)"
    end
end

function Base.rand(d::Dice)
    return sum(ceil.(rand(d.mult) * d.dice)) + d.mod
end

function Base.max(d::Dice)
    return d.mult * d.dice + d.mod
end

function Base.min(d::Dice)
    return d.mult + d.mod
end

function mean(d::Dice)
    return Int64(floor(0.5 * (d.dice + 1) * d.mult + d.mod))
end
