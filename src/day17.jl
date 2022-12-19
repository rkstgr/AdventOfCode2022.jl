module Day17

using AdventOfCode2022
using StatsBase

struct Rock
    stones::Vector{Tuple{Int,Int}}
    size::Tuple{Int, Int}
end

Flat = Rock([(0,0), (1,0), (2,0), (3,0)], (4, 1))
Plus = Rock([(1,0), (0, 1), (1,1), (2,1), (1,2)], (3,3))
ReverseL = Rock([(0,0), (1,0), (2,0), (2,1), (2,2)], (3,3))
Stick = Rock([(0,0), (0, 1), (0, 2), (0, 3)], (1, 4))
Cube = Rock([(0,0), (1,0), (0,1), (1,1)], (2,2))

rocks = [Flat, Plus, ReverseL, Stick, Cube]

struct FallingRock
    rock::Rock
    position::Tuple{Int,Int}
end

CHAMBER_BUFFER = 1000
mutable struct Chamber
    placed_rocks::Vector{FallingRock} # sorted by position.y+height
    total_height::Int
end
Chamber() = Chamber([], 0)

function add_rock!(chamber, falling_rock)
    push!(chamber.placed_rocks, falling_rock)
    sort!(chamber.placed_rocks, by = x -> x.position[2] + x.rock.size[2])
    if length(chamber.placed_rocks) > CHAMBER_BUFFER
        popfirst!(chamber.placed_rocks)
    end
    chamber.total_height = max(chamber.total_height, falling_rock.position[2] + falling_rock.rock.size[2] - 1)
end

# VISUALIZATION

function Base.show(io::IO, r::Rock)
    w, h = r.size
    for y in h-1:-1:0
        for x in 0:w -1
            if (x,y) in r.stones
                print(io, "#")
            else
                print(io, ".")
            end
        end
        println(io)
    end
end

function Base.show(io::IO, c::Chamber)
    max_y = c.total_height
    placed_positions = collect(Iterators.flatten(map(absolute_stone_positions, c.placed_rocks)))
    for y in max_y+3:-1:1
        print("|")
        for x in 1:7
            pos = (x, y)
            if pos in placed_positions
                print(io, "#")
            else
                print(io, ".")
            end
        end
        print("|")
        println(io)
    end
    println(io, "+-------+")
end

# SIMULATION

function absolute_stone_positions(falling_rock::FallingRock)::Vector{Tuple{Int,Int}}
    x, y = falling_rock.position
    return [(x + dx, y + dy) for (dx, dy) in falling_rock.rock.stones]
end

function has_collision(chamber::Chamber, falling_rock::FallingRock)::Bool
    for i in length(chamber.placed_rocks):-1:1
        S = chamber.placed_rocks[i]
        if (S.position[2] + S.rock.size[2]) < falling_rock.position[2]
            # if S is below new_rock, we can't collide
            # ass all other rocks are below S we can break and dont have to check further
            return false
        end
        
        # check if any of the stones of S collide with the new_rock
        chamber_positions = absolute_stone_positions(S)
        rock_positions = absolute_stone_positions(falling_rock)
        if any(x -> x in chamber_positions, rock_positions)
            # we collided, so we can't fall further
            return true
        end
    end
    return false
end

function push_rock(chamber::Chamber, falling_rock::FallingRock, jet::Char)::FallingRock
    if jet == '>'
        new_x = falling_rock.position[1] + 1
        if new_x > 7 - falling_rock.rock.size[1] + 1
            return falling_rock
        end
    elseif jet == '<'
        new_x = falling_rock.position[1] - 1
        if new_x < 1
            return falling_rock
        end
    else
        throw(ArgumentError("jet must be either > or <. Got $jet"))
    end

    new_falling_rock = FallingRock(falling_rock.rock, (new_x, falling_rock.position[2]))

    if has_collision(chamber, new_falling_rock)
        return falling_rock
    else
        return new_falling_rock
    end
end

function fall_one_unit_if_possible(chamber::Chamber, falling_rock::FallingRock)::Tuple{FallingRock, Bool}
    new_rock = FallingRock(falling_rock.rock, (falling_rock.position[1], falling_rock.position[2] - 1))

    if new_rock.position[2] <= 0
        # collided with the bottom
        return falling_rock, true
    end

    if has_collision(chamber, new_rock)
        return falling_rock, true
    end

    return new_rock, false
end

function drop_rock!(chamber::Chamber, rock_index::Int, jet_index::Int, jetpattern::String; debug=false)::Tuple{Int, Int}
    falling_rock = FallingRock(rocks[rock_index], (3, chamber.total_height + 4))
    rock_index = (rock_index % length(rocks)) + 1

    while true
        jet = jetpattern[jet_index]
        falling_rock = push_rock(chamber, falling_rock, jet)

        jet_index = (jet_index % length(jetpattern)) + 1

        falling_rock, is_placed = fall_one_unit_if_possible(chamber, falling_rock)
        
        if is_placed
            add_rock!(chamber, falling_rock)
            break
        end

    end    
    
    return rock_index, jet_index
end

function drop_n_rocks(n::Int, jetpattern::String)
    jetindex = 1
    rockindex = 1
    chamber = Chamber()
    heights = Vector{Int}(undef, n)
    for i in 1:n
        rockindex, jetindex = drop_rock!(chamber, rockindex, jetindex, jetpattern)
        heights[i] = chamber.total_height
    end
    return heights
end

function get_period(d::Vector{Int})
    c = autocor(d, 1:length(d)-1)
    c = c .* LinRange(1, 10, length(c))
    peaks = findall(x -> x > 2, c)
    px = diff(peaks)
    return px[end]
end

function get_height(x::Int, p::Int, d1::Vector{Int}, dp::Vector{Int})
    return sum(d1) + ((x-p)÷p) * sum(dp) + sum(dp[1: ((x-p)%p)])
end


function day17(input = readInput(17))
    heights = drop_n_rocks(5000, input)
    part1 = heights[2022]

    d = diff(heights)
    p = get_period(d)
    d1 = d[1:p]
    dp = d[p+1:2p]
    part2 = get_height(10^12, p, d1, dp)
    return [part1, part2]
end

end # module



