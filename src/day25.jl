module Day25

using AdventOfCode2022

parseinput(input) :: Vector{String} = input |> strip |> x -> split(x, "\n")

function snafu2dec(snafu :: String) :: Int
    x = 0
    for (i, c) in enumerate(Iterators.reverse(snafu))
        val = if c == '-'
            -1
        elseif c == '='
            -2
        else
            parse(Int, c)
        end 
        x += val * 5^(i-1)
    end
    return x
end

function dec2snafu(x :: Int) :: String
    snafu = ""
    i = 0
    while x != 0
        y = (x ÷ 5^i) % 5
        if y == 4
            x += 5^i
            snafu = '-' * snafu
        elseif y == 3
            x += 2 * 5^i
            snafu = '=' * snafu
        else
            x -= y * 5^i
            snafu = string(y) * snafu
        end 
        i += 1
    end
    return snafu
end

function day25(input = readInput(25))
    data = parseinput(input)

    part1 = dec2snafu(sum(snafu2dec.(data)))

    return part1
end

end # module