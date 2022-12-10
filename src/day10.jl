module Day10

using AdventOfCode2022


function parseLine(input::AbstractString)
    if contains(input, "noop")
        return [0]
    else
        _, arg = split(input)
        return [0, parse(Int, arg)]
    end
end

function parseInput(input)
    lines = split(strip(input), "\n")
    ops = parseLine.(lines)
    ops = collect(Base.Flatten(ops))
    pushfirst!(ops, 1)
    return ops
end

function draw(x::Vector{Int})
    for i in 1:length(x)
        col = (i-1) % 40 + 1
        if abs(x[i]+1-col) <= 1
            print("#")
        else
            print(".")
        end
        if col == 40
            print("\n")
        end
    end
end

function day10(input = readInput(10))
    deltas = parseInput(input)
    x = cumsum(deltas)
    ix = 20:40:length(x)
    part1 = sum(x[ix] .* ix)
    draw(x)
    return [part1, 0]
end


end