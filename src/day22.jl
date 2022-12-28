module Day22

using AdventOfCode2022
using Chain
using MLStyle

@data Tile begin
    Wall
    Open
end
@data Rotation begin
    LeftRotation
    RightRotation
end
@data Direction begin
    Right
    Down
    Left
    Up
end

Map = Dict{Tuple{Int, Int}, Tile}

mutable struct State
    pos::Tuple{Int, Int}
    dir::Direction
end

function parseinput(input::AbstractString)
    parts = split(input, "\n\n")
    mapString = parts[1]
    intructionsString = parts[2]
    map = Map()
    maxy = 0
    maxx = 0
    for (y, line) in enumerate(split(rstrip(mapString), "\n"))
        for (x, c) in enumerate(line)
            if c == '#'
                map[(x, y)] = Wall
            elseif c == '.'
                map[(x, y)] = Open
            end
            maxx = max(maxx, x)
            maxy = max(maxy, y)
        end
    end
    # instructions
    instructions = Vector{Union{Int, Rotation}}()
    matches = eachmatch(r"(\d+|R|L)", intructionsString)
    for m in matches
        if m.match == "R"
            push!(instructions, RightRotation)
        elseif m.match == "L"
            push!(instructions, LeftRotation)
        else
            push!(instructions, parse(Int, m.match))
        end
    end
    return map, instructions, (maxx, maxy)
end

function printMap(map::Map, max_dim::Tuple{Int, Int})
    for y in 1:max_dim[2]
        for x in 1:max_dim[1]
            if (x, y) in keys(map)
                @match map[(x, y)] begin
                    Wall => print('#')
                    Open => print('.')
                end
            else
                print(" ")
            end
        end
        println()
    end
end

function printMap(map::Map, max_dim::Tuple{Int, Int}, directions::Dict{Tuple{Int, Int}, Direction})
    for y in 1:max_dim[2]
        for x in 1:max_dim[1]
            if (x, y) in keys(map)
                if map[(x, y)] == Wall
                    print('#')
                elseif map[(x, y)] == Open
                    if haskey(directions, (x, y))
                        @match directions[(x, y)] begin
                            Right => print('>')
                            Down => print('v')
                            Left => print('<')
                            Up => print('^')
                        end
                    else
                        print('.')
                    end
                end
            else
                print(" ")
            end
        end
        println()
    end
end

function nextPosition(pos::Tuple{Int, Int}, dir::Direction, map)
    if !haskey(map, pos)
        throw("{pos} is not a valid position.")
    end

    nextPos = @match dir begin
        Up => (pos[1], pos[2] - 1)
        Right => (pos[1] + 1, pos[2])
        Down => (pos[1], pos[2] + 1)
        Left => (pos[1] - 1, pos[2])
    end
    if nextPos in keys(map)
        return nextPos
    else
        return @match dir begin
            Up => @chain keys(map) filter(p -> p[1] == pos[1], _) argmax(p -> p[2], _)
            Right => @chain keys(map) filter(p -> p[2] == pos[2], _) argmin(p -> p[1], _)
            Down => @chain keys(map) filter(p -> p[1] == pos[1], _) argmin(p -> p[2], _)
            Left => @chain keys(map) filter(p -> p[2] == pos[2], _) argmax(p -> p[1], _)
        end
    end
end

function move(state::State, map::Map)
    next_pos = nextPosition(state.pos, state.dir, map)
    if map[next_pos] == Wall
        return state
    end
    return State(next_pos, state.dir)
end

function act(state::State, instruction::Union{Int, Rotation}, map::Map)::Tuple{State, Dict{Tuple{Int, Int}, Direction}}
    directions = Dict{Tuple{Int, Int}, Direction}()
    directions[state.pos] = state.dir
    if instruction isa Int
        for _ in 1:instruction
            state = move(state, map)
            directions[state.pos] = state.dir
        end
    elseif instruction isa Rotation
        if instruction == LeftRotation
            state = if state.dir == Up
                State(state.pos, Left)
            elseif state.dir == Right
                State(state.pos, Up)
            elseif state.dir == Down
                State(state.pos, Right)
            elseif state.dir == Left
                State(state.pos, Down)
            end
        elseif instruction == RightRotation
            state = if state.dir == Up
                State(state.pos, Right)
            elseif state.dir == Right
                State(state.pos, Down)
            elseif state.dir == Down
                State(state.pos, Left)
            elseif state.dir == Left
                State(state.pos, Up)
            end
        else
            throw("Invalid rotation")
        end
        directions[state.pos] = state.dir
    else
        throw("Invalid instruction")
    end
    return state, directions
end

initial_state(map) = State((@chain keys(map) filter(p -> p[2] == 1, _) argmin(p -> p[1], _)), Right)

value(dir::Direction) = @match dir begin
    Right => 0
    Down => 1
    Left => 2
    Up => 3
end
final_password(state::State) = 1000*state.pos[2] + 4*state.pos[1] + value(state.dir)

#=
x=
1       51         150
       +------+------+ y = 1
       |  g   |   e  |
       |f     |     d|
       |      |  b   | y = 50
       +------+------+
       |      |
       |a    b|
       |      |
+------+------+
|   a  |      | y = 101
|f     |     d|
|      |   c  | y = 150
+------+------+
|      |
|g    c|
|   e  | y = 200
+------+
=#


function nextPosition2(pos::Tuple{Int, Int}, dir::Direction, map)
    if !haskey(map, pos)
        throw("{pos} is not a valid position.")
    end

    nextPos = @match dir begin
        Up => (pos[1], pos[2] - 1)
        Right => (pos[1] + 1, pos[2])
        Down => (pos[1], pos[2] + 1)
        Left => (pos[1] - 1, pos[2])
    end

    if nextPos in keys(map)
        return nextPos
    else
        # wrap around
        # if dir == Up && pos[2] == 101

    end
end

function day22(input = readInput(22))
    map, instructions, max_dim = parseinput(input)
    state = initial_state(map)
    directions = Dict{Tuple{Int, Int}, Direction}()
    directions[state.pos] = state.dir
    for instruction in instructions
        state, dirs = act(state, instruction, map)
        for (pos, dir) in dirs
            directions[pos] = dir
        end
    end
    # printMap(map, max_dim, directions)
    part1 = final_password(state)
    return [part1, 0]
end

end # module