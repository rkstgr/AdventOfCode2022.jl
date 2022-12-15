module Day15

using AdventOfCode2022

struct Position
    x::Int
    y::Int
end

manhatten_distance(p1::Position, p2::Position)::Int = abs(p1.x - p2.x) + abs(p1.y - p2.y)
dist(p1::Position, p2::Position)::Int = manhatten_distance(p1, p2)

function parse_line(line::AbstractString)::Tuple{Position, Position}
    m = match(r"Sensor at x=(?<x>[+-]?\d+), y=(?<y>[+-]?\d+): closest beacon is at x=(?<bx>[+-]?\d+), y=(?<by>[+-]?\d+)", line)
    return Position(parse(Int, m[:x]), parse(Int, m[:y])), Position(parse(Int, m[:bx]), parse(Int, m[:by]))
end

function parse_input(input::AbstractString)::Vector{Tuple{Position, Position}}
    return parse_line.(split(strip(input), "\n"))
end

function positions_around(starting_position::Position, distance::Int)
    return [Position(x, y) for x in starting_position.x-distance:starting_position.x+distance, y in starting_position.y-distance:starting_position.y+distance if dist(starting_position, Position(x, y)) <= distance]
end

function positions_without_beacon(sensor::Position, nearest_beacon::Position)
    d = dist(sensor, nearest_beacon)
    all_around = Set(positions_around(sensor, d))
    return [p for p in all_around if p != nearest_beacon]
end

@enum PositionStatus Beacon Sensor NoBeacon

function day15(input = readInput(15); target_y = 2_000_000)
    sensor_beacon_pairs = parse_input(input)
    map = Dict{Position, PositionStatus}()
    for (sensor, beacon) in sensor_beacon_pairs
        for p in positions_without_beacon(sensor, beacon)
            map[p] = NoBeacon
        end
        map[sensor] = Sensor
        map[beacon] = Beacon
    end
    part1 = length(filter(p -> p.y == target_y && (map[p] == NoBeacon || map[p] == Sensor), keys(map)))
    return [part1, 0]
end

end # module