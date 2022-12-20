module Day19

using AdventOfCode2022


Resources = Tuple{Int8, Int8, Int8, Int8} # ore, clay, obsidian, geode
Machines = Tuple{Int8, Int8, Int8, Int8} # ore, clay, obsidian, geode // which machines are available
Blueprint = Tuple{Resources, Resources, Resources, Resources} # resource costs for each robot

function parseline(input::AbstractString)::Blueprint
    m = match(r"Blueprint \d+: Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.", input).captures
    ore_robot_cost =        (parse(Int8, m[1]), 0, 0, 0)
    clay_robot_cost =       (parse(Int8, m[2]), 0, 0, 0)
    obsidian_robot_cost =   (parse(Int8, m[3]), parse(Int8, m[4]), 0, 0)
    geode_robot_cost =      (parse(Int8, m[5]), 0, parse(Int8, m[6]), 0)
    return (ore_robot_cost, clay_robot_cost, obsidian_robot_cost, geode_robot_cost)
end

function daysUntilEnoughResources(costs::Resources, r::Resources, m::Machines)::Int
    Δt = 0 # Not reachable // missing machines
    for i in eachindex(costs)
        if costs[i] <= 0
            continue
        end

        if m[i] == 0
            return -1
        end

        Δt = max(Δt, div(costs[i]-r[i], m[i], RoundUp))
    end
    return Δt
end

function maximum_geodes(r::Resources, m::Machines, blueprint::Blueprint, t::Int, deadline::Int=24)::Int
    geodes::Int = -1
    t_left = deadline - t
    for i in Iterators.reverse(eachindex(m)) # TODO: go reverse
        if i!=4 && m[i] >= maximum(b[i] for b in blueprint)
            # we have already as much machines of type i as we could spend per turn
            continue
        end

        if i != 4 && m[i] * t_left + r[i] >= t_left * maximum(b[i] for b in blueprint)
            # if we have already enough resources of r[i] dont build another machine of type i
            continue
        end

        Δt = daysUntilEnoughResources(blueprint[i], r, m)
        if Δt <= -1
            continue
        end
        if (t + Δt) > deadline
            continue
        end
        Δt = Δt + 1
        r_next = r .+ (m .* Δt) .- blueprint[i]
        m_next = (m[1:i-1]..., m[i] + 1, m[i+1:end]...) # add new machine
        geodes = max(geodes, maximum_geodes(r_next, m_next, blueprint, t + Δt, deadline))
    end

    # do nothing until deadline
    geodes = max(geodes, r[4]+(m[4]*t_left))
    return geodes
end

function day19(input = readInpu(19))
    blueprints = parseline.(split(strip(input), "\n"))
    max_geodes = Vector{Int}(undef, length(blueprints))
    for i in eachindex(blueprints)
        max_geodes[i] = maximum_geodes((0,0,0,0), (1,0,0,0), blueprints[i], 0, 24)
    end
    part1 = sum(collect(1:length(blueprints)) .* max_geodes)

    k = min(3, length(blueprints))
    for i in 1:k
        max_geodes[i] = maximum_geodes((0,0,0,0), (1,0,0,0), blueprints[i], 0, 32)
    end
    part2 = prod(max_geodes[1:k])

    return [part1, part2]
end

end # module