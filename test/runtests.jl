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