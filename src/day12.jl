module Day12

using AdventOfCode2022
using Graphs
using SparseArrays

struct Heightmap
    data::Array{Char,2}
    start_pos::Tuple{Int,Int}
    end_pos::Tuple{Int,Int}
end

function Heightmap(input::AbstractString)::Heightmap
    lines = split(strip(input), "\n")
    data = Array{Char}(undef, length(lines), length(lines[1]))
    for (i, line) in enumerate(lines)
        for (j, c) in enumerate(line)
            data[i,j] = c
        end
    end
    start_pos = findfirst(data .== 'S')
    end_pos = findfirst(data .== 'E')
    data[start_pos] = 'a'
    data[end_pos] = 'z'
    return Heightmap(data, start_pos, end_pos)
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

function shortest_path(hm::Heightmap, adj_matrix)
    # Get the adjacency matrix of the heightmap
    g = SimpleDiGraph(adj_matrix)

    # Get the size of the heightmap
    _, cols = size(hm.data)

    # Calculate the index of the start and end positions in the adjacency matrix
    start_idx = (hm.start_pos[1]-1)*cols + hm.start_pos[2]
    end_idx = (hm.end_pos[1]-1)*cols + hm.end_pos[2]

    return a_star(g, start_idx, end_idx)
end

function shortest_alternative_path(hm::Heightmap, adj_matrix)
    # Get the adjacency matrix of the heightmap
    g = SimpleDiGraph(transpose(adj_matrix))

    # Get the size of the heightmap
    rows, cols = size(hm.data)

    # Calculate the index of the start and end positions in the adjacency matrix
    idx_fn = (row, col) -> (row-1)*cols + col
    end_idx = idx_fn(hm.end_pos...)

    starting_indices = (cart_index -> idx_fn(cart_index[1], cart_index[2])).(findall(hm.data .== 'a'))
    paths = dijkstra_shortest_paths(g, [end_idx])

    return minimum(paths.dists[starting_indices])
end
    


function day12(input = readInput(12))
    heighmap = Heightmap(input)
    adj_matrix = adjacency_matrix(heighmap)
    path = shortest_path(heighmap, adj_matrix)
    dist = shortest_alternative_path(heighmap, adj_matrix)
    return [length(path), dist]
end

end # module