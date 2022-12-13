module Day13

using AdventOfCode2022
using Chain

compare(left::Int, right::Int) = sign(right - left)
compare(left::Int, right::Vector) = compare([left], right)
compare(left::Vector, right::Int) = compare(left, [right])

function compare(left::Vector, right::Vector)
    length_left = length(left)
    length_right = length(right)

    for k in 1:min(length_left, length_right)
        comparison = compare(left[k], right[k])
        comparison == 0 && continue
        return comparison
    end

    return sign(length_right - length_left)
end

lessThan(left, right)::Bool = compare(left, right) == 1

function parse_input(input::AbstractString)
    parsed_data = []
    for line in eachline(IOBuffer(input))
        isempty(line) && continue
        push!(parsed_data, eval(Meta.parse(line)))
    end
    return parsed_data
end

function day13(input = readInput(13))
    parsed_data = parse_input(input)
    results::Vector{Bool} = @chain Iterators.partition(parsed_data, 2) begin
        map(x -> lessThan(x...), _)
    end

    part1 = sum(findall(results))

    append!(parsed_data, [[[2]], [[6]]])
    sorted_data = sort(parsed_data, lt=lessThan)
    part2 = prod(identity, findall(x -> x == [[2]] || x == [[6]], sorted_data))
    return [part1, part2]
end

end # module