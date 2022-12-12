module Day12

using AdventOfCode2022
using Graphs
using SparseArrays

struct Heightmap
    data::Array{Char,2}
    start_index::Int
    end_index::Int
end

function index(array::AbstractArray, row::Int, col::Int)::Int
    return (row-1)*size(array, 2) + col
end

function Heightmap(input::AbstractString)::Heightmap
    lines = split(strip(input), "\n")
    data = Array{Char}(undef, length(lines), length(lines[1]))
    start_index = 0
    end_index = 0
    for (i, line) in enumerate(lines)
        for (j, c) in enumerate(line)
            if c == 'S'
                start_index = index(data, i, j)
                data[i,j] = 'a'
            elseif c == 'E'
                end_index = index(data, i, j)
                data[i,j] = 'z'
            else
                data[i,j] = c
            end
        end
    end
    return Heightmap(data, start_index, end_index)
end

function adjacency_matrix(hm::Heightmap)
    # Get the size of the heightmap
    rows, cols = size(hm.data)

    # Initialize the adjacency matrix with zeros
    adj_matrix = spzeros(Int, rows*cols, rows*cols)

    # Loop over all squares on the heightmap
    for i in 1:rows
        for j in 1:cols
            # Get the elevation of the current square
            elev = hm.data[i,j]

            # Calculate the index of the current square in the adjacency matrix
            idx = (i-1)*cols + j

            # Check if the square above the current square is within the heightmap and
            # has an elevation that is at most one higher than the current square
            if (i > 1) && hm.data[i-1,j] <= elev + 1
                # If so, set the corresponding element of the adjacency matrix to 1
                adj_matrix[idx, idx - cols] = 1
            end

            # Repeat the process for the other three directions
            if i < rows && hm.data[i+1,j] <= elev + 1
                adj_matrix[idx, idx + cols] = 1
            end

            if j > 1 && hm.data[i,j-1] <= elev + 1
                adj_matrix[idx, idx - 1] = 1
            end

            if j < cols && hm.data[i,j+1] <= elev + 1
                adj_matrix[idx, idx + 1] = 1
            end

        end
    end

    return adj_matrix
end

function shortest_paths_to(hm::Heightmap, target_index::Int)
    g = SimpleDiGraph(transpose(adjacency_matrix(hm)))
    return dijkstra_shortest_paths(g, [target_index])
end

function day12(input = readInput(12))
    heighmap = Heightmap(input)
    paths = shortest_paths_to(heighmap, heighmap.end_index)
    alternatives_index = (x -> index(heighmap.data, x[1], x[2])).(findall(heighmap.data .== 'a'))
    return [paths.dists[heighmap.start_index], minimum(paths.dists[alternatives_index])]
end

end # module