module Day18

using Chain
using AdventOfCode2022

parseinput(input::String)::Vector{Tuple{Int, Int, Int}} = @chain input strip split('\n') map(x -> Tuple(parse.(Int, split(x, ','))), _) collect
sides((x,y,z)) = Set([(x+1, y, z), (x-1, y, z), (x, y+1, z), (x, y-1, z), (x, y, z+1), (x, y, z-1)])

function day18(input = readInput(18))
    cubes = Set(parseinput(input))
    seen = Set{Tuple{Int, Int, Int}}()
    queue = [(-1, -1, -1)]

    while !isempty(queue)
        c = popfirst!(queue)
        if c ∈ seen
            continue
        end
        append!(queue, [s for s in setdiff(sides(c), cubes, seen) if all(-1 <= x <= 24 for x in s)])
        push!(seen, c)
    end

    part1 = 0
    part2 = 0
    for c in cubes
        for s in sides(c)
            if s ∉ cubes
                part1 += 1
            end
            if s ∈ seen
                part2 += 1
            end
        end
    end

    return [part1, part2]
end

end # module