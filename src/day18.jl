module Day18

using Chain
using AdventOfCode2022
using IterTools

Cube = Tuple{Int,Int,Int}

parseinput(input::String)::Vector{Cube} = @chain input strip split('\n') map(x -> Cube(parse.(Int, split(x, ','))), _) collect

adjacent_directions::Vector{Cube} = @chain collect(Iterators.product(-1:1, -1:1, -1:1)) filter(x->sum(abs.(x))==1, _) collect
adjacent_positions(cube::Cube)::Vector{Cube} = @chain map(d -> d.+cube, adjacent_directions) collect
#adjacent_positions(c) = @chain map(d -> d.+c, @chain collect(Iterators.product([-1:1 for _ in 1:length(c)]...)) filter(x->sum(abs.(x))==1, _) collect) collect

function surface_area(cubes::Vector{Cube}, interior::Vector{Cube})
    area = 0
    outer_area = 0
    for c in cubes
        for adj_pos in adjacent_positions(c)
            if adj_pos ∉ cubes
                area += 1
                if adj_pos ∉ interior
                    outer_area += 1
                end
            end
        end
    end
    return area, outer_area
end

function get_enclosing_cube(cubes::Vector{Cube})
    low = collect(cubes[1])
    high = collect(cubes[1])
    for c in cubes
        for i in 1:3
            if c[i] < low[i]
                low[i] = c[i]
            end
            if c[i] > high[i]
                high[i] = c[i]
            end
        end
    end
    enclosing_cubes = [p for p in Iterators.product(low[1]:high[1], low[2]:high[2], low[3]:high[3])][:]
    return enclosing_cubes, Tuple(low), Tuple(high)
end

function traverse(start::Cube, droplet::Vector{Cube}, border_low::Cube, border_high::Cube, prev_visited::Vector{Cube})
    is_interior = true
    queue = Vector()
    push!(queue, start)
    visited = Vector{Cube}()
    while !isempty(queue)
        current = pop!(queue)
        if any(current .< border_low) || any(current .> border_high)
            is_interior = false
            continue
        end
        push!(visited, current)
        for adj_pos in adjacent_positions(current)
            if adj_pos ∉ droplet && adj_pos ∉ visited && adj_pos ∉ prev_visited
                push!(queue, adj_pos)
            end
        end
    end
    return visited, is_interior
end

function get_interior(droplet)::Vector{Cube}
    inclosure, low, high = get_enclosing_cube(droplet)
    interior = Vector{Cube}()
    visited = Vector{Cube}()
    for c in filter(x -> x ∉ droplet, inclosure)
        if c ∈ visited
            continue
        end
        cx, is_interior = traverse(c, droplet, low, high, visited)
        if is_interior
            append!(interior, cx)
        end
        append!(visited, cx)
    end
    return interior
end

function day18(input = readInput(18))
    droplet = parseinput(input)
    interior = get_interior(droplet)
    total_surface, outer_surface = surface_area(droplet, interior)
    return [total_surface, outer_surface]
end

end # module