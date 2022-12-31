module Day24

using AdventOfCode2022

# credit: https://github.com/goggle/AdventOfCode2022.jl/blob/master/src/day24.jl

const Time = Int
const Position = Tuple{Int, Int}

function parseinput(input :: String) :: Tuple{Position, Position, Dict{Time, Set{Position}}, Int}
    data = map(x -> x[1], reduce(vcat, permutedims.(map(x -> split(x, ""), split(input)))))
    valley = map(x -> x.I, findall(x -> x ∈ ('.', '>', '<', '^', 'v'), data)) |> Set
    start = (1,2)
    goal = (size(data, 1), size(data, 2) - 1)
    cycle_period = lcm(size(data, 1) - 2, size(data, 2) - 2)

    up = map(x -> x.I, findall(x -> x == '^', data))
    right = map(x -> x.I, findall(x -> x == '>', data))
    down = map(x -> x.I, findall(x -> x == 'v', data))
    left = map(x -> x.I, findall(x -> x == '<', data))

    reachable = Dict{Time, Set{Position}}()
    reachable[0] = setdiff(valley, union(up, right, down, left))

    for n in 1:cycle_period-1
        for i in axes(up, 1)
            up[i] = (mod1(up[i][1] - 1 - 1, size(data, 1) - 2) + 1, up[i][2])
        end
        for i in axes(right, 1)
            right[i] = (right[i][1], mod1(right[i][2] + 1 - 1, size(data, 2) - 2) + 1)
        end
        for i in axes(down, 1)
            down[i] = (mod1(down[i][1] + 1 - 1, size(data, 1) - 2) + 1, down[i][2])
        end
        for i in axes(left, 1)
            left[i] = (left[i][1], mod1(left[i][2] - 1 - 1, size(data, 2) - 2) + 1)
        end
        reachable[n] = setdiff(valley, union(up, right, down, left))
    end

    return (start, goal, reachable, cycle_period)
end

function solve(start::Tuple{Int,Int}, goal::Tuple{Int,Int}, reachable::Dict{Int,Set{Tuple{Int,Int}}}, starttime::Int, cycle::Int)
    reachable_after = Dict{Int,Set{Tuple{Int,Int}}}()
    reachable_after[starttime] = Set([start])
    r = starttime + 1
    while true
        reachable_after[r] = Set{Tuple{Int,Int}}()
        for point ∈ reachable_after[r-1]
            point == goal && return r - 1 - starttime
            if point ∈ reachable[mod(r, cycle)]
                push!(reachable_after[r], point)
            end
            if (point[1] + 1, point[2]) ∈ reachable[mod(r, cycle)]
                push!(reachable_after[r], (point[1] + 1, point[2]))
            end
            if (point[1], point[2] + 1) ∈ reachable[mod(r, cycle)]
                push!(reachable_after[r], (point[1], point[2] + 1))
            end
            if (point[1] - 1, point[2]) ∈ reachable[mod(r, cycle)]
                push!(reachable_after[r], (point[1] - 1, point[2]))
            end
            if (point[1], point[2] - 1) ∈ reachable[mod(r, cycle)]
                push!(reachable_after[r], (point[1], point[2] - 1))
            end
        end
        r += 1
    end
end

function day24(input :: String = readInput(24))
    start, goal, reachable, cycle_period = parseinput(input)
    p1 = solve(start, goal, reachable, 0, cycle_period)

    # part 2
    p22 = solve(goal, start, reachable, p1, cycle_period)
    p23 = solve(start, goal, reachable, p1+p22, cycle_period)

    return [p1, p1 + p22 + p23]
end

end # module