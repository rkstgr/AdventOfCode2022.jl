module Day04

using AdventOfCode2022


function day04(input::String = readInput(joinpath(@__DIR__, "..", "data", "day04.txt")))
    input = strip(input)

    part1 = 0
    part2 = 0
    for line in split(input, "\n")
        (a, b) = split(line, ",")[1:2]
        (a1, a2) = split(a, "-")[1:2]
        (b1, b2) = split(b, "-")[1:2]
        range1 = parse(Int, a1):parse(Int, a2)
        range2 = parse(Int, b1):parse(Int, b2)
        if range1 ⊆ range2 || range2 ⊆ range1
            part1 += 1
        end
        if !isdisjoint(range1, range2)
            part2 += 1
        end
    end

    return [part1, part2]
end

end # module

