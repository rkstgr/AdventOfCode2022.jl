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