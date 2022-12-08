module Day08

using AdventOfCode2022

Direction = Tuple{Int, Int}
UP:: Direction = (-1, 0)
RIGHT:: Direction = (0, 1)
DOWN:: Direction = (1, 0)
LEFT:: Direction = (0, -1)
directions::Vector{Direction} = [UP, RIGHT, DOWN, LEFT]

function heights(input::AbstractString):: Matrix{UInt8}
    lines = split(strip(input), "\n")
    height = zeros(Int, length(lines), length(lines[1]))
    for (i, line) in enumerate(lines)
        for (j, c) in enumerate(line)
            height[i, j] = parse(UInt8, c)
        end
    end
    return height
end

function slice(x::Int, y::Int, dir::Direction, heights::Matrix{UInt8})
    if dir == UP
        return heights[x-1:-1:1, y]
    elseif dir == RIGHT
        return heights[x, y+1:end]
    elseif dir == DOWN
        return heights[x+1:end, y]
    elseif dir == LEFT
        return heights[x, y-1:-1:1]
    end
end

function isVisible(x::Int, y::Int, heights::Matrix{UInt8})
    if x == 1 || x == size(heights, 1) || y == 1 || y == size(heights, 2)
        return true
    end
    for dir in directions
        if all(slice(x, y, dir, heights) .< heights[x, y])
            return true
        end
    end
    return false
end

isVisible(heights::Matrix)::Matrix{Bool} = isVisible.(1:size(heights, 1), permutedims(1:size(heights,2)), Ref(heights))

function viewingDistance(x::Int, y::Int, dir::Tuple{Int, Int}, heights::Matrix{UInt8})::Int
    if x == 1 || x == size(heights, 1) || y == 1 || y == size(heights, 2)
        return 0
    end
    dist = findfirst(s -> s >= heights[x,y], slice(x, y, dir, heights))
    if isnothing(dist)
        return length(slice(x, y, dir, heights))
    else
        return dist
    end
end

function scenicScore(x::Int, y::Int, heights::Matrix{UInt8})::Int
    score = 1
    for dir in directions
        dist = viewingDistance(x, y, dir, heights)
        score *= dist
    end
    return score
end

scenicScore(heights::Matrix)::Matrix{Int} = scenicScore.(1:size(heights, 1), permutedims(1:size(heights,2)), Ref(heights))

function day08(input = readInput(8))
    h = heights(input)
    return [sum(isVisible(h)), maximum(scenicScore(h))]
end

end # module