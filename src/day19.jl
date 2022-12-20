module Day19

using AdventOfCode2022


Resources = Tuple{Int, Int, Int, Int} # ore, clay, obsidian, geode
Machines = Tuple{Int, Int, Int, Int} # ore, clay, obsidian, geode // which machines are available
Blueprint = Tuple{Resources, Resources, Resources, Resources} # resource costs for each robot

function parseline(input::AbstractString)::Blueprint
    m = match(r"Blueprint \d+: Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.", input).captures
    ore_robot_cost =        (parse(Int, m[1]), 0, 0, 0)
    clay_robot_cost =       (parse(Int, m[2]), 0, 0, 0)
    obsidian_robot_cost =   (parse(Int, m[3]), parse(Int, m[4]), 0, 0)
    geode_robot_cost =      (parse(Int, m[5]), 0, parse(Int, m[6]), 0)
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

triangle(n::Int)::Int = div(n*(n+1), 2)

function maximum_geodes(r::Resources, m::Machines, blueprint::Blueprint, t::Int, deadline::Int=24, bestgeodes::Int = -1)::Int
    t_left = deadline - t

    if r[4] + m[4] * t_left + div(t_left*(t_left+1), 2) <= bestgeodes # uses triangle sequence
        # if the current resources are not enough to beat the bestgeodes, dont bother
        return bestgeodes
    end

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
        bestgeodes = max(bestgeodes, maximum_geodes(r_next, m_next, blueprint, t + Δt, deadline, bestgeodes))
    end

    # do nothing until deadline
    bestgeodes = max(bestgeodes, r[4]+(m[4]*t_left))
    return bestgeodes
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