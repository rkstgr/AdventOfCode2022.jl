module Day16

using AdventOfCode2022

function parse_input(input::AbstractString)
    valves = Set{String}()
    connections = Dict{String, Set{String}}()
    flowrates = Dict{String, Int}()
    for line in split(strip(input), '\n')
        valve, rate, tunnels = match(r"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)", line).captures
        rate = parse(Int, rate)
        flowrates[valve] = rate
        push!(valves, valve)
        if contains(tunnels, ", ")
            tunnels = split(tunnels, ", ")
        else
            tunnels = [tunnels]
        end
        connections[valve] = Set{String}(tunnels)
    end
    return valves, connections, flowrates
end

State = Tuple{Int, Vector{String}}

function dynamic_solve(adjacent::Dict{String, Set{String}}, flowrates::Dict{String, Int}, start = "AA", timeleft = 30)

    state_matrix::Dict{Int, Dict{String, State}} = Dict(timeleft => Dict(start => (0, [])))

    flowrate(s::State) = sum(map(v -> flowrates[v], s[2]))
    function step(s::State)::State
        return (s[1]+ flowrate(s), s[2])
    end
    futurescore(s::State, t) = s[1] + t * flowrate(s)

    for t in timeleft:-1:1
        state_matrix[t-1] = Dict()
        for (v, s_tv) in state_matrix[t]
            new_s_tv = step(s_tv)

            if flowrates[v] > 0 && !(v in s_tv[2])
                new_s_tv = (new_s_tv[1], [new_s_tv[2]..., v])
            end
            
            # update s_t-1_v
            if !haskey(state_matrix[t-1], v) || futurescore(new_s_tv, t-1) > futurescore(state_matrix[t-1][v], t-1)
                state_matrix[t-1][v] = new_s_tv
            end
            
            new_s_tv = step(s_tv)
            for neighbor in adjacent[v]
                if !haskey(state_matrix[t-1], neighbor) || futurescore(new_s_tv, t-1) > futurescore(state_matrix[t-1][neighbor], t-1)
                    state_matrix[t-1][neighbor] = new_s_tv
                end
            end
        end
    end

    return state_matrix
end


function day16(input = readInput(16))
    _, connections, flowrates = parse_input(input)
    matrix::Dict{Int, Dict{String, State}} = dynamic_solve(connections, flowrates, "AA", 30)
    part1 = maximum(x -> x[1], values(matrix[0]))
    return [part1, 0]
end

end # module