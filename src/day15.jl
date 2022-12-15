module Day15

using AdventOfCode2022

struct Position
    x::Int
    y::Int
end

struct Range
    start::Int
    stop::Int # inclusive

    function Range(start::Int, stop::Int)::Union{Range, Nothing}
        if start <= stop
            return new(start, stop)
        else
            return nothing
        end
    end
end

range(a, b) = a:sign((a==b) ? 1 : b - a):b
..(a, b) = Range(a,b)

Base.length(range::Range) = range.stop - range.start + 1

function union(range1::Range, range2::Range)::Union{Vector{Range}, Range}
    a1, a2 = range1.start, range1.stop
    b1, b2 = range2.start, range2.stop

    if a1>b1
        return union(range2, range1)
    end

    #assume a1<=b1

    # disjoint with gap
    if a2+1<b1 
        return [a1..a2, b1..b2]
    end

    # partial overlap
    if b1 <= a2
        return a1..max(a2, b2)
    end

    # contained
    if b2 <= a2
        return a1..a2
    end

    error("Unhandled merge case: $range1, $range2")
end

function merge(ranges::Vector{Range})::Vector{Range}
    sorted_ranges = sort(ranges, by=x -> x.start)
    new_ranges = Range[]
    for current_range in sorted_ranges
        if isempty(new_ranges)
            push!(new_ranges, current_range)
            continue
        end
        
        last_range = pop!(new_ranges)
        merged_range = union(last_range, current_range)
    
        if merged_range isa Range
            push!(new_ranges, merged_range)
        else
            push!(new_ranges, merged_range...)
        end 
    end
    return new_ranges
end

dist(p1::Position, p2::Position)::Int = abs(p1.x - p2.x) + abs(p1.y - p2.y)

function parse_line(line::AbstractString)::Tuple{Position, Position}
    m = match(r"Sensor at x=(?<x>[+-]?\d+), y=(?<y>[+-]?\d+): closest beacon is at x=(?<bx>[+-]?\d+), y=(?<by>[+-]?\d+)", line)
    return Position(parse(Int, m[:x]), parse(Int, m[:y])), Position(parse(Int, m[:bx]), parse(Int, m[:by]))
end

function parse_input(input::AbstractString)::Vector{Tuple{Position, Position}}
    return parse_line.(split(strip(input), "\n"))
end

function xrange(sensor::Position, nearest_beacon::Position, target_y::Int)::Union{Range, Nothing}
    # returns all x positions on target_y that are <= distance from sensor
    beacon_distance = dist(sensor, nearest_beacon)
    distance_to_target_y = abs(target_y - sensor.y)
    
    if distance_to_target_y > beacon_distance
        return nothing
    end

    x_delta = beacon_distance - distance_to_target_y
    return Range(sensor.x - x_delta, sensor.x + x_delta)
end

function getcanditates(sensor::Position, beacon::Position)::Vector{Position}
    canditates::Vector{Position} = []
    target_distance = dist(sensor, beacon) + 1
    corner_points = [Position(sensor.x - target_distance,   sensor.y),
                     Position(sensor.x,                     sensor.y + target_distance),
                     Position(sensor.x + target_distance,   sensor.y),
                     Position(sensor.x,                     sensor.y - target_distance)]
    for (i, corner_point) in enumerate(corner_points)
        prev_corner_point = i > 1 ? corner_points[i-1] : corner_points[end]
        for (x, y) in zip(range(prev_corner_point.x,corner_point.x), range(prev_corner_point.y,corner_point.y))
            push!(canditates, Position(x, y))
        end
    end
    return canditates
end

function day15(input = readInput(15); target_y = 2_000_000, limit = 4_000_000)
    sensor_beacon_pairs = parse_input(input)
    ranges::Vector{Range} = []
    beacons_on_target = Set{Position}()
    for (sensor, beacon) in sensor_beacon_pairs
        xr = xrange(sensor, beacon, target_y)
        if xr !== nothing
            push!(ranges, xr)
        end
        if beacon.y == target_y
            push!(beacons_on_target, beacon)
        end
    end

    ranges = merge(ranges)
    part1 = sum(length.(ranges))-length(beacons_on_target)
    getpart2(pos::Position) = pos.x*4000000+pos.y
    
    # Part 2
    final_candidate = Position(-1, -1)
    for (sensor, beacon) in sensor_beacon_pairs
        canditates::Vector{Position} = getcanditates(sensor, beacon)
        for canditate in canditates
            if canditate.x >= 0 && canditate.x <= limit && canditate.y >= 0 && canditate.y <= limit
                if all(x -> dist(canditate, x[1]) > dist(x[1], x[2]), sensor_beacon_pairs)
                    final_candidate = canditate
                    return [part1, getpart2(final_candidate)]
                end
            end
        end
    end

    return [part1, getpart2(final_candidate)]
end

end # module