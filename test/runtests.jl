using AdventOfCode2022
using Test


@testset "Day 1" begin
    sample = """
    1000
    2000
    3000
    
    4000
    
    5000
    6000
    
    7000
    8000
    9000
    
    10000
    """
    @test AdventOfCode2022.Day01.day01(sample) == [24000, 45000]
end

@testset "Day 2" begin
    sample = """
    A Y
    B X
    C Z
    """
    @test AdventOfCode2022.Day02.day02(sample) == [15, 12]
end

@testset "Day 3" begin
    sample = """
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
    @test AdventOfCode2022.Day03.day03(sample) == [157, 70]
end

@testset "Day 4" begin
    sample = """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
    @test AdventOfCode2022.Day04.day04(sample) == [2, 4]
end

@testset "Day 5" begin

    sample = """
        [D]    
    [N] [C]    
    [Z] [M] [P]
     1   2   3 

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
    @test AdventOfCode2022.Day05.day05(sample) == ["CMZ", "MCD"]
end

@testset "Day 6" begin

    @test AdventOfCode2022.Day06.day06("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == [7, 19]
    @test AdventOfCode2022.Day06.day06("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == [10, 29]
end

@testset "Day 7" begin
    testInput = raw"""
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
    @test AdventOfCode2022.Day07.day07(testInput) == [95437, 24933642]
end

@testset "Day 8" begin
    testInput = """
    30373
    25512
    65332
    33549
    35390
    """
    @test AdventOfCode2022.Day08.day08(testInput) == [21, 8]
end

@testset "Day 9" begin
    testInput = """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
    @test AdventOfCode2022.Day09.day09(testInput) == [13, 1]
end

@testset "Day 10" begin
    testInput = """
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
    """
    @test AdventOfCode2022.Day10.day10(testInput) == [13140, 0]
end

@testset "Day 11" begin
    testInput = """
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
"""
    @test AdventOfCode2022.Day11.day11(testInput) == [10605, 2713310158]
end

@testset "Day 12" begin
    testInput = """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """

    @test AdventOfCode2022.Day12.day12(testInput) == [31, 29]
end

@testset "Day 13" begin
    @test AdventOfCode2022.Day13.lessThan([1,1,3,1,1], [1,1,5,1,1]) == true
    @test AdventOfCode2022.Day13.lessThan([[1],[2,3,4]], [[1],4]) == true
    @test AdventOfCode2022.Day13.lessThan([9], [[8,7,6]]) == false
    @test AdventOfCode2022.Day13.lessThan([[4,4],4,4], [[4,4],4,4,4]) == true
    @test AdventOfCode2022.Day13.lessThan([7,7,7,7], [7,7,7]) == false
    @test AdventOfCode2022.Day13.lessThan([], [3]) == true
    @test AdventOfCode2022.Day13.lessThan([[[]]], [[]]) == false
    @test AdventOfCode2022.Day13.lessThan([1,[2,[3,[4,[5,6,7]]]],8,9], [1,[2,[3,[4,[5,6,0]]]],8,9]) == false
        
    test_input = """
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
    """
    @test AdventOfCode2022.Day13.day13(test_input) == [13, 140]
end