module Day01

using AdventOfCode2022

function day01(input::String = readInput(joinpath(@__DIR__, "..", "data", "day01.txt")))
    # input consists of multiple lines with numbers and empty lines

    # remove trailing newlines
    input = strip(input)
    # split the input into groups of lines
    groups = split(input, "\n\n")
    # convert each group into a vector of numbers
    groups = map(x -> map(y -> parse(Int, y), split(x, "\n")), groups)
    # calculate the sum of each group
    sums = map(x -> sum(x), groups)
    return [maximum(sums), 0]
end

end # module