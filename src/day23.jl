module Day23

using AdventOfCode2022

# Credits: https://github.com/hraftery/aoc2022/blob/main/day23/day23.jl

const Position = Tuple{Int,Int} # row, column ordering
@enum Dir N NE E SE S SW W NW
index(e::Enum) = Int(e) + 1
const Up = [N, NE, NW]
const Down = [S, SE, SW]
const Left = [W, NW, SW]
const Right = [E, NE, SE]

const checkDirections = [(Up, N), (Down, S), (Left, W), (Right, E)]
allneighbours::Vector{Position} = [(-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1)]

function neighbours(pos::Position)::Vector{Position}
    res = Vector{Position}(undef, 8)
    for i in 1:8
        res[i] = (pos[1] + allneighbours[i][1], pos[2] + allneighbours[i][2])
    end
    return res
end

function Base.axes(positions::Set{Position})::Tuple{UnitRange{Int},UnitRange{Int}}
    r0, r1 = extrema([l[1] for l in positions])
    c0, c1 = extrema([l[2] for l in positions])
    return (r0:r1, c0:c1)
end

function parseinput(input::String)::Set{Position}
    elves = Set{Position}()

    for (row, l) ∈ enumerate(split(strip(input), "\n"))
        cols = findall(isequal('#'), l)
        union!(elves, [(row, col) for col in cols])
    end

    return elves
end

function show(elves)
    rows, cols = axes(elves)
    for r ∈ rows
        println(String([(r, c) ∈ elves ? '#' : '.' for c in cols]))
    end
end


function round(elfPositions::Set{Position}, count=1)::Tuple{Set{Position},Int}
    # Going with the immutable argument approach here for convenience, even though it feels heavy handed.
    newElfPositions = Set{Position}()
    proposals = Dict{Position,Position}() # dst => src
    for elfPosition ∈ elfPositions
        ns = neighbours(elfPosition)
        if !isdisjoint(elfPositions, ns) # First half
            for i in count:count+3
                i = (i - 1) % 4 + 1
                check, go = checkDirections[i]
                if isdisjoint(elfPositions, ns[index.(check)])
                    dst = ns[index(go)]
                    if dst ∈ keys(proposals) # clash. Cancel them both.
                        push!(newElfPositions, elfPosition)
                        push!(newElfPositions, proposals[dst])
                        delete!(proposals, dst) # and then remove it since only two elves can have the same proposal
                    else # no clash, add to proposals
                        proposals[dst] = elfPosition
                    end
                    @goto done
                end
            end
        end
        push!(newElfPositions, elfPosition) # No proposal? Just stay put.
        @label done
    end
    # Second half. Tried to combine the halves but couldn't figure out a way.
    union!(newElfPositions, keys(proposals)) # all proposals are now valid, so just add them

    # have included a sneaky way to indicate no change, which turns out to make little runtime difference
    return (newElfPositions, count + (isempty(proposals) ? 0 : 1))
end

function day23(input=readInput(23))
    elves = parseinput(input)

    count = 1
    for _ = 1:10
        elves, count = round(elves, count)
    end

    rows, cols = axes(elves)
    area = length(rows) * length(cols)
    part1 = area - length(elves)

    newElves, count = round(elves, count)
    while newElves ≠ elves
        elves = newElves
        newElves, count = round(elves, count)
    end

    part2 = count

    return [part1, part2]
end
end # module