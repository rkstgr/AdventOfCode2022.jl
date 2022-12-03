module Day03

using AdventOfCode2022
using Chain

chars = vcat([x for x in 'a':'z'], [x for x in 'A':'Z'])
charValues = Dict(zip(chars, 1:length(chars)))

partition = Iterators.partition

function day03(input::String = readInput(joinpath(@__DIR__, "..", "data", "day03.txt")))
    compartements = @chain input begin
        strip
        split(_, "\n")
        map(x -> (x, length(x)÷2), _)
        map(x -> (x[1][1:x[2]], x[1][x[2]+1:end]), _)
    end

    part1 = @chain compartements begin
        map(x -> intersect(Set(collect(x[1])), Set(collect(x[2]))), _)
        map(x -> pop!(x), _)
        map(x -> charValues[x], _)
        sum
    end

    part2 = @chain compartements begin
        map(x -> union(x...), _)
        partition(3)
        map(x -> intersect(x...), _)
        map(x -> pop!(x), _)
        map(x -> charValues[x], _)
        sum
    end
        
    return [part1, part2]
end

end # module