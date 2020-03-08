include("Dice.jl")

mutable struct Character
    Name :: String
    Initiative :: Int64
    HP :: Union{Int64, Dice}
    Damage :: Int64
    AC :: Int64
    Details
end

function Character(Name, Initiative, HP, Damage, AC)
    return Character(Name, Initivative, HP, Damage, AC, "")
end

function Base.string(c :: Character)
    return """
    $(c.Name)\n
    Damage: $(c.Damage) | Status: $(status(c.HP, c.Damage)) \n
    AC: $(c.AC) \n
    Details: \n
    --------\n
    $(c.Details)
    """
end

function status(HP :: Int64, Damage :: Int64)
    if Damage < HP
        return "Alive"
    else
        return "Unconcious"
    end
end

function status(HP :: Dice, Damage :: Int64)
    if Damage < min(HP)
        return "Alive"
    elseif Damage < mean(HP)
        return "Hurt"
    elseif Damage < max(HP)
        return "Severely Injured"
    else
        return "Dead"
    end
end
