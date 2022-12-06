module Day06

using AdventOfCode2022


function windows(input::String, n::Int)::Vector{String}
    return [input[i:i+n-1] for i in 1:length(input)-n+1]
end

function messageOffset(windows::Vector{String})::Int
    # return index of first window where all characters are unique
    for (i, w) in enumerate(windows)
        if length(unique(w)) == length(w)
            return i + length(w) - 1# index position + length of window
        end
    end
    
end


function day06(input::String = readInput(joinpath(@__DIR__, "..", "data", "day06.txt")))
    part1 = messageOffset(windows(input, 4))
    part2 = messageOffset(windows(input, 14))
    return [part1, part2]
end


end # module