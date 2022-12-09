module Day09

using AdventOfCode2022
using Chain

directions::Dict{Char, Vector{Int}} = Dict(
    'R' => [1, 0],
    'L' => [-1, 0],
    'U' => [0, 1],
    'D' => [0, -1],
)

function parseInput(input::AbstractString)::Vector{Vector{Int}}
    actions = split(strip(input), "\n")
    @chain actions begin
        map(x -> (x[1], parse(Int, x[2:end])), _)
        map(x -> repeat(x[1], x[2]), _)
        Iterators.Flatten(_)
        map(x -> directions[x], _)
        pushfirst!(_, [0, 0])
    end
end

function moveTail(tail::Vector{Int}, head::Vector{Int})::Vector{Int}
    delta = head - tail
    if maximum(abs.(delta)) <= 1
        return tail
    end
    delta = clamp.(delta, -1, 1)
    return tail + delta
end

function tailPositions(n, positions)::Vector{Vector{Int}}
    if n == 1
        return accumulate(moveTail, positions, dims=1)
    else
        return accumulate(moveTail, tailPositions(n-1, positions), dims=1)
    end
end

function day09(input = readInput(9))::Vector{Int}
    deltas = parseInput(input)
    positions = cumsum(deltas, dims=1)
    tail1 = tailPositions(1, positions)
    tail9 = tailPositions(8, tail1)
    part1 = length(unique(tail1))
    part2 = length(unique(tail9))
    return [part1, part2]
end

end # module