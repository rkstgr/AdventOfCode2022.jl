module Day08

using AdventOfCode2022

UP = (-1, 0)
RIGHT = (0, 1)
DOWN = (1, 0)
LEFT = (0, -1)
directions = [UP, RIGHT, DOWN, LEFT]

function heights(input::AbstractString)
    lines = split(strip(input), "\n")
    height = zeros(Int, length(lines), length(lines[1]))
    for (i, line) in enumerate(lines)
        for (j, c) in enumerate(line)
            height[i, j] = parse(Int, c)
        end
    end
    height
end

function slice(x::Int, y::Int, dir::Tuple, heights::Matrix)
    if dir == UP
        return reverse(heights[1:x-1, y])
    elseif dir == RIGHT
        return heights[x, y+1:end]
    elseif dir == DOWN
        return heights[x+1:end, y]
    elseif dir == LEFT
        return reverse(heights[x, 1:y-1])
    end
end

function isVisible(x::Int, y::Int, heights::Matrix)
    for dir in directions
        if all(slice(x, y, dir, heights) .< heights[x, y])
            return true
        end
    end
    return false
end

function isVisible(heights::Matrix)
    visible = falses(size(heights))
    for x in 1:size(heights, 1)
        for y in 1:size(heights, 2)
            visible[x, y] = isVisible(x, y, heights)
        end
    end
    visible
end

function viewingDistance(x::Int, y::Int, dir::Tuple, heights::Matrix)
    dist = findfirst(s -> s >= heights[x,y], slice(x, y, dir, heights))
    if isnothing(dist)
        return length(slice(x, y, dir, heights))
    else
        return dist
    end
end

function scenicScore(x::Int, y::Int, heights::Matrix)
    score = 1
    for dir in directions
        dist = viewingDistance(x, y, dir, heights)
        score *= dist
    end
    return score
end

scenicScore(heights::Matrix) = scenicScore.(1:size(heights, 1), permutedims(1:size(heights,2)), Ref(heights))

function day08(input = readInput(8))
    h = heights(input)
    return [sum(isVisible(h)), maximum(scenicScore(h))]
end

end # module