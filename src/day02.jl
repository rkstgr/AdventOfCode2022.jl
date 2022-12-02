module Day02

using AdventOfCode2022
using Chain
using Match

function day02(input::String = readInput(joinpath(@__DIR__, "..", "data", "day02.txt")))

    games = @chain input begin
        strip
        split(_, "\n")
        map(x -> split(x, " "), _)
        map(x -> (findfirst(only(x[1]), "ABC"), findfirst(only(x[2]), "XYZ")), _) # A X -> 1, 1
    end
    
    function result(x)
        return x[2] + [3, 6, 0][(x[2]-x[1]+ 3) % 3 + 1]
    end

    part1 = @chain games begin
        map(result, _)
        sum
    end

    function hand2(hand1, result)
        if result == 2
            return hand1 # draw
        elseif result == 1
            return hand1 == 1 ? 3 : hand1 - 1
        else
            return hand1 == 3 ? 1 : hand1 + 1
        end
    end


    part2 = @chain games begin
        map(x -> (x[1], hand2(x[1], x[2])), _)
        map(result, _)
        sum
    end
    
    return [part1, part2]
end
    
end # module