module Day11

using AdventOfCode2022
using DataStructures

mutable struct Monkey
    items
    operation
    divisor
    ontrue
    onfalse
    inspected
end

function parse_input(input::AbstractString)
    data = SortedDict{Int, Monkey}()
    monkey = 0
    for line in split(input, "\n")
        line = strip(line)
        if startswith(line, "Monkey")
            monkey = parse(Int, match(r"\d+", line).match)
            data[monkey] = Monkey(Int[], x -> x, x -> false, 0, 0, 0)
        elseif contains(line, "Starting items")
            items = split(line, ":")[2]
            data[monkey].items = map(x -> parse(Int, x), split(items, ", "))
        elseif contains(line, "Operation")
            op = match(r"new = old (\S+)", line).captures[1]
            if op == "+"
                data[monkey].operation = x -> x + parse(Int, match(r"\d+", line).match)
            elseif op == "*"
                if contains(line, "old")
                    if contains(line, "old * old")
                        data[monkey].operation = x -> x * x
                    else
                        data[monkey].operation = x -> x * parse(Int, match(r"\d+", line).match)
                    end
                else
                    data[monkey].operation = x -> x * parse(Int, match(r"\d+", line).match)
                end
            end
        elseif contains(line, "Test")
            data[monkey].divisor = parse(Int, match(r"\d+", line).match)
        elseif contains(line, "If true")
            data[monkey].ontrue = parse(Int, match(r"throw to monkey (\d+)", line).captures[1])
        elseif contains(line, "If false")
            data[monkey].onfalse = parse(Int, match(r"throw to monkey (\d+)", line).captures[1])
        end
    end
    return data
end

function simulate_round(monkeys, m)
    for (key, monkey) in monkeys
        items = monkey.items
        monkey.items = []
        for item in items
            item = monkey.operation(item)
            if m == 0
                item = div(item, 3)
            else
                item = item % m
            end
            if item % monkey.divisor == 0
                push!(monkeys[monkey.ontrue].items, item)
            else
                push!(monkeys[monkey.onfalse].items, item)
            end
            monkey.inspected += 1
        end
    end
    return monkeys
end

function simulate_rounds(monkeys, n, m)
    for _ in 1:n
        simulate_round(monkeys, m)
    end
    return monkeys
end

function monkey_business(monkeys)
    count = map(x -> x.inspected, values(monkeys))
    count = sort(count, rev=true)
    level = count[1] * count[2]
    return level
end

function day11(input = readInput(11))
    initial_monkeys = parse_input(input)
    m = prod(map(x -> x.divisor, values(initial_monkeys)))
    monkeys1=simulate_rounds(deepcopy(initial_monkeys), 20, 0)
    monkeys2=simulate_rounds(deepcopy(initial_monkeys), 10000, m)
    part1 = monkey_business(monkeys1)
    part2 = monkey_business(monkeys2)
    return [part1, part2]
end

end