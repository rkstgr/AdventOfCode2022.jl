module Day21

using AdventOfCode2022

mutable struct Computation
    left::String
    op::Char
    right::String
end

Graph = Dict{String, Union{Computation, Float64}}

function parseinput(input::AbstractString)
    graph = Graph()
    for line in split(strip(input), "\n")
        lhs, rhs = split(line, ": ")
        if rhs[1] in '0':'9'
            graph[lhs] = parse(Float64, rhs)
        else
            left, op, right = split(rhs, " ")
            graph[lhs] = Computation(left, op[1], right)
        end
    end
    return graph
end

function compute(graph, key::String)  
    val = graph[key]
    if val isa Number
        return val, key == "humn" ? true : false
    end

    left, left_depends = compute(graph, val.left)
    right, right_depends = compute(graph, val.right)
    
    if val.op == '+'
        result = left + right
    elseif val.op == '-'
        result = left - right
    elseif val.op == '*'
        result = left * right
    elseif val.op == '/'
        result = left / right
    end

    if !left_depends && !right_depends # collapse
        graph[key] = result
    end
    return result, left_depends || right_depends
end

function solve(graph, key::String, x::Number)
    if key == "humn"
        return x
    end
    # update X
    if graph[key].op == '+'
        right_node = graph[graph[key].right]
        if right_node isa Number && graph[key].right != "humn"
            # solving left
            return solve(graph, graph[key].left, x - right_node)
        else
            # solving right
            return solve(graph, graph[key].right, x - graph[graph[key].left])
        end
    elseif  graph[key].op == '-'
        right_node = graph[graph[key].right]
        if right_node isa Number && graph[key].right != "humn"
            # solving left
            return solve(graph, graph[key].left, x + right_node)
        else
            # solving right
            return solve(graph, graph[key].right, graph[graph[key].left] - x)
        end
    elseif  graph[key].op == '*'
        right_node = graph[graph[key].right]
        if right_node isa Number && graph[key].right != "humn"
            # solving left
            return solve(graph, graph[key].left, x / right_node)
        else
            # solving right
            return solve(graph, graph[key].right, x / graph[graph[key].left])
        end
    elseif  graph[key].op == '/'
        right_node = graph[graph[key].right]
        if right_node isa Number && graph[key].right != "humn"
            # solving left
            return solve(graph, graph[key].left, x * right_node)
        else
            # solving right
            return solve(graph, graph[key].right, graph[graph[key].left] / x)
        end
    end
end

function day21(input = readInput(21))
    graph = parseinput(input)
    part1, _ = compute(graph, "root")

    left = graph["root"].left
    start, x = graph[left] isa Number ? (right, graph[left]) : (left, graph[graph["root"].right])
    part2 = solve(graph, start, x)

    return [Int(part1), Int(round(part2))]
end

end # module