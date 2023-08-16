module JSurfer

export Brain, Surface, load_brain, read_surface, read_curv

struct Surface
    vertices::Array{Float32, 2}
    faces::Array{Int32, 2}
    curv::Array{Float32}
    stamp::String
end


struct Brain
    lh::Surface
    rh::Surface
end


function read3(io::IOStream)
    test = read(io, 3)
    return (Int(test[1]) << 16) + (Int(test[2]) << 8) + Int(test[3])
end


function read_surface(fn)
    TRIANGLE::Int32 = 16777214
    # QUAD::Int32 = 16777215
    # NEW_QUAD::Int32 = 16777213

    result::Int32 = 0
    vertices = Array{Float32, 2}[]
    faces = Array{Int32, 2}[]
    stamp::String = ""

    open(fn, "r") do io
        result = read3(io)
        if result != TRIANGLE
            ArgumentError("$fn is not a freesurfer file")
        end
        stamp = readline(io)
        temp = readline(io)
        vnum = ntoh(read(io, Int32))
        fnum = ntoh(read(io, Int32))
        vertices = Array{Float32}(undef, vnum, 3)
        faces = Array{Int32}(undef, fnum, 3)
        for row in 1:vnum
            for col in 1:3
                vertices[row, col] = ntoh(read(io, Float32))
            end
        end
        for row in 1:fnum
            for col in 1:3
                faces[row, col] = ntoh(read(io, Int32))
            end
        end
        faces .= faces .+ 1
    end

    return vertices, faces, stamp
end


function read_curv(fn)
    MAGIC::Int32 = 16777215
    result::Int32 = 0
    curv = Array{Float32}[]

    open(fn, "r") do io
        result = read3(io)
        if result != MAGIC
            ArgumentError("$fn is not a freesurfer file")
        end
        vnum = ntoh(read(io, Int32))
        curv = Array{Float32}(undef, vnum)
        for row in 1:vnum
            curv[row] = ntoh(read(io, Float32))
        end
    end

    return curv
end


function load_brain(subjects_dir::AbstractString, subject::AbstractString)
    lhfile = joinpath((subjects_dir, subject, "surf", "lh.pial"))
    vertices, faces, stamp = read_surface(lhfile)
    lhfile = joinpath((subjects_dir, subject, "surf", "lh.curv.pial"))
    curv = read_curv(lhfile)
    lh = Surface(vertices, faces, curv, stamp)

    rhfile = joinpath((subjects_dir, subject, "surf", "rh.pial"))
    vertices, faces, stamp = read_surface(rhfile)
    rhfile = joinpath((subjects_dir, subject, "surf", "rh.curv.pial"))
    curv = read_curv(rhfile)
    rh = Surface(vertices, faces, curv, stamp)

    return Brain(lh, rh)
end

end
