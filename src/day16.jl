module Day16

using AdventOfCode2022

struct Valve
    name::String
    flowrate::Int
    connectedTo::Vector{String}
end

function parse_input(input::AbstractString)::Vector{Valve}
    valves = Valve[]
    for line in split(strip(input), '\n')
        name, flowrate, tunnels = match(r"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)", line).captures
        flowrate = parse(Int, flowrate)
        if contains(tunnels, ", ")
            tunnels = split(tunnels, ", ")
        else
            tunnels = [tunnels]
        end
        valve = Valve(name, flowrate, tunnels)
        push!(valves, valve)
    end
    return valves
end

function floyd_warshall(valves::Vector{Valve})::Dict{String, Dict{String, Int}}
    graph = Dict{String, Dict{String, Int}}()
    for v1 in valves
        graph[v1.name] = Dict{String, Int}()
        for v2 in valves
            if v1.name == v2.name
                graph[v1.name][v2.name] = 0
            elseif v2.name in v1.connectedTo
                graph[v1.name][v2.name] = 1
            else
                graph[v1.name][v2.name] = 1_000_000
            end
        end
    end

    for k in valves
        for i in valves
            for j in valves
                if graph[i.name][j.name] > graph[i.name][k.name] + graph[k.name][j.name]
                    graph[i.name][j.name] = graph[i.name][k.name] + graph[k.name][j.name]
                end
            end
        end
    end

    return graph
end

function day16(input = readInput(16))
    valves = parse_input(input)
    graph = floyd_warshall(valves)
    worth_it::Vector{Valve} = filter(x -> x.flowrate > 0 || x.name == "AA", valves)

    bitfield = Dict{String, UInt16}(worth_it[i].name => UInt16(1 << (i-1)) for i in eachindex(worth_it))

    start::UInt16 = bitfield["AA"]

    valve_distance = Vector{UInt16}(undef, typemax(UInt16))
    for v1 in worth_it
        for v2 in worth_it
            valve_distance[bitfield[v1.name]|bitfield[v2.name]] = graph[v1.name][v2.name]
        end
    end

    nodes = Vector{Vector{UInt16}}(undef, length(worth_it))
    for i in eachindex(worth_it)
        nodes[i] = [bitfield[worth_it[i].name], worth_it[i].flowrate]
    end

    function dfs(T::Int, score::Int, t::Int, on::UInt16, node::UInt16)::Int
        max = score
        # For every node with flowrate > 0 (excluding start)
        for w in nodes
            if node == w[1] || start == w[1] || w[1]&on != 0
                continue
            end
        
            l = valve_distance[node|w[1]] + 1
            if t + l > T
                continue # If we cannot reach it in time, skip
            end

            # Walk to w and open it
            # Update score with all the future reward from w
            # Search from there
            next = dfs(T, score + (T - t -l) * w[2], t + l, on|w[1], w[1])
            if next > max
                max = next
            end
        end
        return max
    end

    function dfspaths(T::Int, score::Int, t::Int, on::UInt16, node::UInt16, path::UInt16)::Vector{Tuple{Int,UInt16}}
        paths = [ (score, path) ]
        for w in nodes
            if node == w[1] || start == w[1] || w[1]&on != 0
                continue
            end
        
            l = valve_distance[node|w[1]] + 1
            if t + l > T
                continue # If we cannot reach it in time, skip
            end

            paths = vcat(paths, dfspaths(T, score + (T - t -l) * w[2], t + l, on|w[1], w[1], path|w[1]))
        end

        return paths
    end

    part1 = dfs(30, 0, 0, UInt16(0), start)

    allpaths = dfspaths(26, 0, 0, UInt16(0), start, UInt16(0))
    trimpaths = Tuple{Int, UInt16}[]
    for path in allpaths
        if path[1] > 2*part1 / 5
            push!(trimpaths, path)
        end
    end

    part2:: Int = 0
    for i in eachindex(trimpaths)
        for j in i+1:length(trimpaths)
            if trimpaths[i][2] & trimpaths[j][2] != 0
                continue
            end
            m = trimpaths[i][1] + trimpaths[j][1]
            if m > part2
                part2 = m
            end
        end
    end
    
    
    return [part1, part2]
end

end # module