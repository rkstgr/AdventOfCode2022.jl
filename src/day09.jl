module Day09

using AdventOfCode2022
using Chain

directions::Dict{Char, Tuple{Int, Int}} = Dict(
    'R' => (1, 0),
    'L' => (-1, 0),
    'U' => (0, 1),
    'D' => (0, -1),
)

Position = Tuple{Int, Int}

struct Rope
    head::Position
    tails::Vector{Position}
end

Rope() = Rope((0, 0), [(0, 0)])
Rope(n::Int) = Rope((0, 0), [(0, 0) for i in 1:n])
Rope(hx::Int, hy::Int, tx::Int, ty::Int) = Rope((hx, hy), [(tx, ty)])

function parseInput(input::AbstractString)::Vector{Char}
    actions = split(strip(input), "\n")
    @chain actions begin
        map(x -> (x[1], parse(Int, x[2:end])), _)
        map(x -> repeat(x[1], x[2]), _)
        Iterators.Flatten(_)
        collect
    end
end

function moveHead(head::Position, dir::Tuple{Int, Int})::Position
    return head .+ dir
end

function moveTail(head::Position, tail::Position)::Position
    delta = head .- tail
    if maximum(abs.(delta)) <= 1
        return tail
    end
    delta = clamp.(head .- tail, -1, 1)
    return tail .+ delta
end

function move(rope::Rope, dir::Char)::Rope
    head = moveHead(rope.head, directions[dir])
    tails::Vector{Position} = Vector{Position}(undef,length(rope.tails))
    for i in 1:length(rope.tails)
        if i == 1
            tails[i] = moveTail(head, rope.tails[i])
        else
            tails[i] = moveTail(tails[i-1], rope.tails[i])
        end
    end
    return Rope(head, tails)
end

function run(rope::Rope, actions::Vector{Char})::Vector{Rope}
    ropes::Vector{Rope} = Vector{Rope}(undef, length(actions)+1)
    ropes[1] = rope
    for i in 1:length(actions)
        ropes[i+1] = move(ropes[i], actions[i])
    end
    return ropes
end

function day09(input = readInput(9))::Vector{Int}
    actions = parseInput(input)
    ropes = run(Rope(9), actions)
    part1 = length(unique(s -> s.tails[1], ropes))
    part2 = length(unique(s -> s.tails[end], ropes))
    return [part1, part2]
end

end # module