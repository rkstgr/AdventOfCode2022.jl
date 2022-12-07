module Day07 # No Space Left On Device

using AdventOfCode2022
using Chain

struct File
    parent::Any
    name::String
    size::Int
end

mutable struct Directory
    parent::Union{Directory, Nothing}
    name::String
    children::Vector{Union{Directory, File}}
    size::Union{Int, Nothing}
end

mutable struct FileSystem
    root::Union{Directory, Nothing}
    current::Union{Directory, Nothing}
end

FileSystem() = FileSystem(nothing, nothing)

children(d::Directory) = d.children
children(f::File) = nothing
nodevalue(f::File) = f.size
nodevalue(d::Directory) = !isnothing(d.size) ? d.size : sum(nodevalue, children(d))
parent(n::Union{Directory, File}) = n.parent
addObject(parent::Directory, child::Union{Directory, File}) = push!(parent.children, child)

function parseInput(input::String)
    return map(x -> collect(split(x, "\n")), split(strip(input), r"\n(?=\$)"))
end

function print(dir::Directory, depth::Int=0)
    # iterate through the tree, keep track of the depth
    # print directory - [name] (type)
    # print file - [name] (type size=size)
    if !isnothing(dir.size)
        println("  "^depth, "- $(dir.name) (Dir size=$(dir.size))")
    else
        println("  "^depth, "- $(dir.name) (Dir)")
    end
    for child in children(dir)
        if typeof(child) == File
            println("  "^(depth+1), "- $(child.name) (File size=$(child.size))")
        else
            print(child, depth+1)
        end
    end

end

function evaluateCommand!(command::Vector{SubString{String}}, filesystem::FileSystem)
    operator = split(command[1], "\$ ")[2]
    
    if contains(operator, "cd")
        target = split(operator, " ")[2]
        if target == "/" # root
            filesystem.root = Directory(nothing, "/", [], nothing)
            filesystem.current = filesystem.root
        elseif target == ".." # parent
            filesystem.current = parent(filesystem.current)
        else # child
            for child in children(filesystem.current)
                if child.name == target
                    filesystem.current = child
                    break
                end
            end
        end
        
    elseif operator == "ls"
        for arg in command[2:end]
            x, name = split(arg, " ")
            if name in map(x -> x.name, children(filesystem.current))
                # we already have this file or directory
                continue
            else
                if x == "dir"
                    newDir = Directory(filesystem.current, name, [], nothing)
                    addObject(filesystem.current, newDir)
                else
                    size = parse(Int, x)
                    newFile = File(filesystem.current, name, size)
                    addObject(filesystem.current, newFile)
                end
            end

        end
    end

end

function updateSizes!(dir::Directory)
    dir.size = sum(nodevalue, children(dir))
    for child in children(dir)
        if typeof(child) == Directory
            updateSizes!(child)
        end
    end
end

updateSizes!(fs::FileSystem) = updateSizes!(fs.root)

function flatten(dir::Directory)
    # return a vector of all files and directories
    # in the directory
    files = []
    for child in children(dir)
        if typeof(child) == Directory
            push!(files, child)
            append!(files, flatten(child))
        else
            push!(files, child)
        end
    end
    return files
end

flatten(fs::FileSystem) = flatten(fs.root)


function day07(input::String = readInput(joinpath(@__DIR__, "..", "data", "day07.txt")))
    commands = parseInput(input)
    fs = FileSystem()
    evaluateCommand!.(commands, Ref(fs))
    updateSizes!(fs)

    directories = @chain flatten(fs) filter(x -> typeof(x) == Directory, _)

    # total size of all directories smaller than 100_000
    part1 = @chain directories begin
        filter(x -> x.size <= 100_000, _)
        map(x -> x.size, _)
        sum
    end 
    
    total_space = 70_000_000
    required_free = 30_000_000
    size_to_free_up = fs.root.size - (total_space - required_free)

    # smallest directory larger than the space we need to delete
    part2 = @chain directories begin
        filter(x -> x.size >= size_to_free_up, _)
        sort(_, by=x -> x.size)
        first
        _.size
    end 
    return [part1, part2]
    
end

end # module