module Day14

using AdventOfCode2022
using Chain
using IterTools
using Match
using Printf

@enum Material Air Rock Sand

struct Block
    x::Int
    y::Int
    material::Material
end

struct Cave
    blocks::Dict{Tuple{Int,Int}, Block}
    y_limit::Int
end

function hasblock(cave::Cave, position::Tuple{Int, Int})::Bool
    return (position[2] == cave.y_limit) || haskey(cave.blocks, position)
end

..(a, b) = a:sign((a==b) ? 1 : b - a):b

function parse_line(input::AbstractString)::Vector{Tuple{Int, Int}}
    # corner points are returned doubled
    corner_points::Vector{Tuple{Int, Int}} = @chain input begin 
        split(_, " -> ")
        map(x -> split(x, ","), _)
        map(x -> (parse(Int, x[1]), parse(Int, x[2])), _)
    end
    lines = @chain corner_points begin
        collect(IterTools.partition(_, 2, 1))
        map(x -> vec(collect(Iterators.product(x[1][1]..x[2][1], x[1][2]..x[2][2]))), _)
    end
    return collect(Iterators.flatten(lines))
end

function parse_input(input::AbstractString)::Vector{Block}
    return @chain input begin
        split(_, '\n')
        filter(x -> x != "", _)
        map(x -> parse_line(x), _)
        Iterators.flatten(_)
        unique(_)
        map(x -> Block(x[1], x[2], Rock), _)
    end
end

Cave(input::AbstractString) = Cave(Dict((x.x, x.y) => x for x in parse_input(input)), maximum(x -> x.y, parse_input(input))+2)

function findMinMaxCoordinates(cave::Cave)
    min_x = minimum(x -> x[1], keys(cave.blocks))
    min_y = minimum(x -> x[2], keys(cave.blocks))
    max_x = maximum(x -> x[1], keys(cave.blocks))
    max_y = maximum(x -> x[2], keys(cave.blocks))
    return min_x, max_x, min_y, max_y
end

function Base.show(io::IO, obj::Cave)
    min_x, max_x, min_y, max_y = findMinMaxCoordinates(obj)
    for col in 0:max_y
        print(io, @sprintf("%4d ", col))
        for row in min_x:max_x
            block = get(obj.blocks, (row, col), nothing)
            if isnothing(block)
                print(io, ".")
            else
                if block.material == Rock
                    print(io, "#")
                elseif block.material == Sand
                    print(io, "o")
                end
            end
        end
        println(io)
    end
end

function place_sand!(cave::Cave, source::Tuple{Int, Int})::Tuple{Cave, Int, Int}
    # places the sand and returns the coordinates of the sand
    # if the sand falls out of the cave, returns (-1, -1)
    x, y = source
    while true
        # check if the block below is empty
        if !hasblock(cave, (x, y+1))
            y += 1

        # below not empty, check below left
        elseif !hasblock(cave, (x-1, y+1))
            x -= 1
            y += 1
        
        # below and below left not empty, check below right
        elseif !hasblock(cave, (x+1, y+1))
            x += 1
            y += 1
        
        # below, below left and below right not empty, stop
        else
            break
        end
    end
    cave.blocks[(x, y)] = Block(x, y, Sand)
    return cave, x, y
end

function simulate!(cave)::Tuple{Int, Int}
    # place sand until it falls out of the cave
    # return the number of sand blocks
    touched_floor = 0
    n = 0
    while true
        _, x, y = place_sand!(cave, (500, 0))
        if y+1 == cave.y_limit && touched_floor == 0
            touched_floor = n
        end
        n += 1
        if y == 0
            break
        end
    end
    return (touched_floor, n)
end

function day14(input = readInput(14))
    cave = Cave(input)
    part1, part2 = simulate!(cave)
    return [part1, part2]
end

end # module