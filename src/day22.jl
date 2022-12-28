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
    for (r, row) in enumerate(split(rstrip(mapString), "\n"))
        for (c, elem) in enumerate(row)
            if elem == ' '
                continue
            end
            map[(r,c)] = @match elem begin
                '#' => Wall
                '.' => Open
            end
        end
    end
    # instructions
    instructions = Vector{Union{Int, Rotation}}()
    matches = eachmatch(r"(\d+|R|L)", intructionsString)
    for m in matches
        @match m.match begin
            "R" => push!(instructions, RightRotation)
            "L" => push!(instructions, LeftRotation)
            _ => push!(instructions, parse(Int, m.match))
        end
    end
    return map, instructions
end

function max_dims(map::Map)
    max_r = 0
    max_c = 0
    for (r, c) in keys(map)
        max_r = max(max_r, r)
        max_c = max(max_c, c)
    end
    return (max_r, max_c)
end

function printMap(map::Map)
    max_dim = max_dims(map)
    for r in 1:max_dim[1]
        for c in 1:max_dim[2]
            if (r, c) in keys(map)
                @match map[(r, c)] begin
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

function printMap(map::Map, directions::Dict{Tuple{Int, Int}, Direction})
    max_dim = max_dims(map)
    for r in 1:max_dim[1]
        for c in 1:max_dim[2]
            if (r, c) in keys(map)
                if map[(r, c)] == Wall
                    print('#')
                elseif map[(r, c)] == Open
                    if haskey(directions, (r, c))
                        @match directions[(r, c)] begin
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
        Up => (pos[1] - 1, pos[2])
        Right => (pos[1], pos[2] + 1)
        Down => (pos[1] + 1, pos[2])
        Left => (pos[1], pos[2] - 1)
    end
    if nextPos in keys(map)
        return nextPos
    else
        return @match dir begin
            Up => @chain keys(map) filter(p -> p[2] == pos[2], _) argmax(p -> p[1], _)
            Right => @chain keys(map) filter(p -> p[1] == pos[1], _) argmin(p -> p[2], _)
            Down => @chain keys(map) filter(p -> p[2] == pos[2], _) argmin(p -> p[1], _)
            Left => @chain keys(map) filter(p -> p[1] == pos[1], _) argmax(p -> p[2], _)
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

initial_state(map) = State((@chain keys(map) filter(p -> p[1] == 1, _) argmin(p -> p[2], _)), Right)

value(dir::Direction) = @match dir begin
    Right => 0
    Down => 1
    Left => 2
    Up => 3
end
final_password(state::State) = 1000*state.pos[1] + 4*state.pos[2] + value(state.dir)

#=
------ column ------------>
|      |      |      |
1    50 51     101 150
       +------+------+ row = 1
       |  g   |   e  |
       |f     |     d|
       |      |  b   | row = 50
       +------+------+
       |      |
       |a    b|
       |      |
+------+------+
|   a  |      | row = 101
|f     |     d|
|      |   c  | row = 150
+------+------+
|      |
|g    c|
|   e  | row = 200
+------+
=#


function nextState(pos::Tuple{Int, Int}, dir::Direction, map)::State
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
        return State(nextPos, dir)
    else
        col, row = pos
        # return @match ((col, row), dir) begin
        #     ((c, 101), Up)                      => State((51, 50+x), Right)
        #     ((c,   1), Up) && if x <= 100 end   => State((,150+x-50), Right)
        #     ((,   1), Up)                      => State()
        # end

    end
end

function day22(input = readInput(22))
    map, instructions = parseinput(input)
    state = initial_state(map)
    directions = Dict{Tuple{Int, Int}, Direction}()
    directions[state.pos] = state.dir
    for instruction in instructions
        state, dirs = act(state, instruction, map)
        for (pos, dir) in dirs
            directions[pos] = dir
        end
    end
    # printMap(map, directions)
    part1 = final_password(state)
    return [part1, 0]
end

end # module