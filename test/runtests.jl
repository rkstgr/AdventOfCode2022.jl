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