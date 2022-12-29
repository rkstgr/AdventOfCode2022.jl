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

function wrapFlat(state::State, map::Map)::State
    pos = state.pos
    dir = state.dir
    nextPos = @match dir begin
        Up => @chain keys(map) filter(p -> p[2] == pos[2], _) argmax(p -> p[1], _)
        Right => @chain keys(map) filter(p -> p[1] == pos[1], _) argmin(p -> p[2], _)
        Down => @chain keys(map) filter(p -> p[2] == pos[2], _) argmin(p -> p[1], _)
        Left => @chain keys(map) filter(p -> p[1] == pos[1], _) argmax(p -> p[2], _)
    end
    return State(nextPos, dir)
end

function wrapCube(state::State, map::Map)::State

    #=
    ------ column ------------>
    |      |      |      |
    1    50 51     101 150
        +------+------+ 
        |^ g>  |  e> ^| row = 1
        |f     |     d|
        |      |  b>  | row = 50
        +------+------+
        |      |
        |a    b|
        |v    v|
    +------+------+
    |  a>  |      | row = 101
    |f     |     d|
    |v     |   c>v| row = 150
    +------+------+
    |      |
    |g    c|
    |v e> v| row = 200
    +------+
    =#
    return @match (state.pos, state.dir) begin
            # a
            ((101, c), Up) && if c in 1:50 end => State((50+c, 51), Right)
            ((r,  51), Left) && if r in 51:100 end => State((101, r-50), Down)
            # b
            ((r, 100), Right) && if r in 51:100 end => State((50, r+50), Up)
            ((50,  c), Down)  && if c in 101:150 end => State((c-50, 100), Left)
            # c
            ((r, 50), Right) && if r in 151:200 end => State((150, r-100), Up)
            ((150, c), Down) && if c in 51:100 end => State((c+100, 50), Left)
            # d
            ((r, 100), Right) && if r in 101:150 end => State((50 - (r - 101), 150), Left)
            ((r, 150), Right) && if r in 1:50 end => State((151-r, 100), Left)
            # e
            ((1, c), Up) && if c in 101:150 end => State((200, c-100), Up)
            ((200, c), Down) && if c in 1:50 end => State((1, c+100), Down)
            # f
            ((r,  1), Left) && if r in 101:150 end => State((50 - (r - 101), 51), Right)
            ((r, 51), Left) && if r in 1:50 end => State((151-r, 1), Right)
            # g
            ((r, 1), Left) && if r in 151:200 end => State((1, r-100), Down)
            ((1, c), Up) && if c in 51:100 end => State((c+100, 1), Right)
            _ => throw("Invalid state: $state")
        end
end

function nextState(state::State, map::Map, wrapFn::Function)::State
    pos = state.pos
    dir = state.dir

    nextPos = @match dir begin
        Up => (pos[1] - 1, pos[2])
        Right => (pos[1], pos[2] + 1)
        Down => (pos[1] + 1, pos[2])
        Left => (pos[1], pos[2] - 1)
    end

    if !haskey(map, nextPos)
        return wrapFn(state, map)
    end

    return State(nextPos, dir)
end

function act(state::State, instruction::Union{Int, Rotation}, map::Map, wrapFn::Function)::Tuple{State, Dict{Tuple{Int, Int}, Direction}}
    directions = Dict{Tuple{Int, Int}, Direction}()
    directions[state.pos] = state.dir
    if instruction isa Int
        for _ in 1:instruction
            next_state = nextState(state, map, wrapFn)
            if map[next_state.pos] != Wall
                state = next_state
            end
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

function part1(input = readInput(22))
    map, instructions = parseinput(input)

    state = initial_state(map)
    for instruction in instructions
        state, _ = act(state, instruction, map, wrapFlat)
    end
    return final_password(state)
end

function day22(input = readInput(22))
    map, instructions = parseinput(input)

    state = initial_state(map)
    for instruction in instructions
        state, _ = act(state, instruction, map, wrapFlat)
    end
    part1 = final_password(state)

    state = initial_state(map)
    for inst in instructions
        state, _ = act(state, inst, map, wrapCube)
    end
    part2 = final_password(state)

    return [part1, part2]
end

end # module