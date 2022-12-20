module Day20

using AdventOfCode2022


parseinput(input::AbstractString)::Vector{Int} = parse.(Int, split(strip(input), "\n"))

mutable struct RingObject
    value::Int
    i::Int # index position
    next::Union{Nothing, RingObject}
    prev::Union{Nothing, RingObject}
end

function RingObject(value::Int)
    obj = RingObject(value, 0, nothing, nothing)
    obj.next = obj
    obj.prev = obj
    return obj
end

Base.show(io::IO, obj::RingObject) = print(io, obj.value)

mutable struct Ring
    objects::Vector{RingObject}
end

function Ring(values::Vector{Int})
    objects = RingObject.(values)
    for i in eachindex(objects)
        objects[i].i = i
        objects[i].next = objects[mod(i, length(objects)) + 1]
        objects[i].prev = objects[mod(i-2, length(objects)) + 1]
    end
    return Ring(objects)
end

at_original_index(ring::Ring, idx::Int) = ring.objects[mod(idx-1, length(ring.objects)) + 1]
Base.getindex(ring::Ring, idx::Int) = at_original_index(ring, idx)
function at_current_index(ring::Ring, idx::Int)
    idx = mod(idx-1, length(ring.objects)) + 1
    ring.objects[findfirst(obj -> obj.i == idx, ring.objects)]
end

function Base.show(io::IO, ring::Ring)
    print(io, "Ring [")
    obj_idx = findfirst(obj -> obj.i == 1, ring.objects)
    obj = ring.objects[obj_idx]
    for _ in 1:length(ring.objects)
        print(io, obj.value, ", ")
        obj = obj.next
    end
    print(io, "\b\b]")
end

function move_forward!(r::Ring, original_i::Int)
    prev = r[original_i].prev
    next = r[original_i].next
    next2 = next.next

    prev.next = next
    next.prev = prev
    next.next = r[original_i]
    r[original_i].next = next2
    r[original_i].prev = next
    next2.prev = r[original_i]

    i = r[original_i].i
    r[original_i].i = next.i
    next.i = i
    if r[original_i].i == length(r.objects)
        for j in 1:length(r.objects)
            if r[j].i == length(r.objects)
                r[j].i = 1
            else
                r[j].i += 1
            end
        end
    end
end

function move_backward!(r::Ring, original_i::Int)
    prev = r[original_i].prev
    next = r[original_i].next
    prev2 = prev.prev

    r[original_i].prev = prev2
    r[original_i].next = prev
    prev.prev = r[original_i]
    prev.next = next
    next.prev = prev
    prev2.next = r[original_i]

    i = r[original_i].i
    r[original_i].i = prev.i
    prev.i = i
    if r[original_i].i == length(r.objects) # if the items wraps around, reorder the indices
        for j in 1:length(r.objects)
            if r[j].i == 1
                r[j].i = length(r.objects)
            else
                r[j].i -= 1
            end
        end
    end
end

function mix(r::Ring)
    for i in 1:length(r.objects)
        ri = at_original_index(r, i)
        if ri.value == 0
            continue
        elseif ri.value > 0
            for _ in 1:ri.value
                move_forward!(r, i)
            end
        else
            for _ in 1:abs(ri.value)
                move_backward!(r, i)
            end
        end
        # println("After $(r[i].value): \n $r")
    end
end

function day20(input = readInput(20))
    numbers = parseinput(input)
    ring = Ring(numbers)
    mix(ring)
    zero_original_index = findfirst(obj -> obj.value == 0, ring.objects)
    zero_object = at_original_index(ring, zero_original_index)
    part1 = 0
    for x in [1000, 2000, 3000]
        part1 += at_current_index(ring, zero_object.i + x).value
    end

    key = 811589153


    return [part1, 0]
end

end # module