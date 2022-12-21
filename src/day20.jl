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

wrap(i::Int, n::Int) = mod(i-1, n) + 1
wrap(i::Int, r::Ring) = wrap(i, length(r.objects))
at_original_index(ring::Ring, idx::Int) = ring.objects[wrap(idx, ring)]

function at_current_index(ring::Ring, idx::Int)
    idx = mod(idx-1, length(ring.objects)) + 1
    ring.objects[findfirst(obj -> obj.i == idx, ring.objects)]
end

function move_after!(r::Ring, src::RingObject, tgt::RingObject)
    s_i = src.i
    t_i = tgt.i

    src_prev = src.prev
    src_next = src.next
    # remove i and stich together
    src_prev.next = src_next
    src_next.prev = src_prev

    tgt_next = tgt.next
    tgt.next = src
    src.prev = tgt
    src.next = tgt_next
    tgt_next.prev = src

    # update indices

    if s_i < t_i
        src.i = wrap(src.next.i - 1, r)
        # update all objects between old_src.next :: src.prev
        obj = src_next
        while obj.next.i != src.next.i
            obj.i -= 1
            obj = obj.next
        end
    end

    if t_i < s_i
        src.i = wrap(src.prev.i + 1, r)
        # update all objects 
        obj = src.next
        while obj.i != src_next.i
            obj.i += 1
            obj = obj.next
        end
    end

end

function mix!(r::Ring)
    N = length(r.objects)
    for oi in 1:N
        ri = at_original_index(r, oi)
        if ri.value == 0
            continue
        end
        x = ri.value
        if x == 0
            continue
        elseif x > 0
            x = wrap(x, N-1)
            if x <= N - ri.i
                tgt = at_current_index(r, ri.i + x)
            else
                tgt = at_current_index(r, x - (N - ri.i))
            end
        elseif x < 0
            x = wrap(abs(x), N-1) * -1
            if ri.i > abs(x)
                tgt = at_current_index(r, ri.i + x)
            else
                tgt = at_current_index(r, N + x + ri.i)
            end
            tgt = tgt.prev
        end
        move_after!(r, ri, tgt)
    end
end

function day20(input = readInput(20))
    numbers = parseinput(input)

    ring = Ring(numbers)
    mix!(ring)
    zero_original_index = findfirst(obj -> obj.value == 0, ring.objects)
    zero_object = at_original_index(ring, zero_original_index)
    part1 = 0
    for x in [1000, 2000, 3000]
        part1 += at_current_index(ring, zero_object.i + x).value
    end
    
    key = 811589153
    ring = Ring(numbers .* key)
    
    for _ in 1:10
        mix!(ring)
    end
    zero_original_index = findfirst(obj -> obj.value == 0, ring.objects)
    zero_object = at_original_index(ring, zero_original_index)
    part2 = 0
    for x in [1000, 2000, 3000]
        part2 += at_current_index(ring, zero_object.i + x).value
    end
    return [part1, part2]
end

end # module