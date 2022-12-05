module Day05

using AdventOfCode2022

function initializeStack(input::String)::Dict{Int, Vector{Char}}
    stackString = split(input, "\n\n")[1]

    stackStringReversed = (split(stackString, "\n") |> reverse)
    stackOffsets = [x.offset for x in collect(eachmatch(r"[0-9]", stackStringReversed[1]))]
    stackOffsets = Dict(zip(1:length(stackOffsets), stackOffsets))

    stacks = Dict(zip(1:length(stackOffsets), [Char[] for i in 1:length(stackOffsets)]))
    for r in stackStringReversed[2:end]
        for (key, offset) in stackOffsets
            if offset > length(r)
                continue
            end
            item = r[offset]
            if item == ' '
                continue
            end
            push!(stacks[key], item)
        end
    end
    return stacks
end # initializeStacks


function getInstructions(input::String)::Vector{String}
    return split(split(input, "\n\n")[2] |> strip, "\n")
end

function apply_instruction!(stacks, instruction)::Nothing
    # example intruction: move 1 from 2 to 1
    instruction = split(instruction, " ")
    times = parse(Int, instruction[2])
    from = parse(Int, instruction[4])
    to = parse(Int, instruction[6])
    if times > 1
        for _ in 1:times
            apply_instruction!(stacks, "move 1 from $from to $to")
        end
    else
        push!(stacks[to], pop!(stacks[from]))
    end # if
    return nothing
end # apply_instruction!

function apply_instruction2!(stacks, instruction)::Nothing
    # example intruction: move 1 from 2 to 1
    instruction = split(instruction, " ")
    times = parse(Int, instruction[2])
    from = parse(Int, instruction[4])
    to = parse(Int, instruction[6])
    arr = reverse([pop!(stacks[from]) for _ in 1:times])
    append!(stacks[to], arr)
    return nothing
end # apply_instruction!


function getTopItems(stacks::Dict{Int, Vector{Char}})::Vector{Char}
    return [stacks[i][end] for i in sort(collect(keys(stacks)))]
end



function day05(input::String = readInput(joinpath(@__DIR__, "..", "data", "day05.txt")))
    instructions = getInstructions(input)

    stack1 = initializeStack(input)
    apply_instruction!.(Ref(stack1), instructions)
    part1 = getTopItems(stack1) |> join

    stack2 = initializeStack(input)
    apply_instruction2!.(Ref(stack2), instructions)
    part2 = getTopItems(stack2) |> join

    return [part1, part2]
end

end # module

