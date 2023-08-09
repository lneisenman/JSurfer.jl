module JSurfer

export Brain, Surface, loadbrain, readsurface

struct Surface
    vertices::Array{Float32, 2}
    faces::Array{Int32, 2}
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


function readsurface(fn)
    TRIANGLE::Int64 = 16777214
    # QUAD::Int64 = 16777215
    # NEW_QUAD::Int64 = 16777213

    result::Int64 = 0
    coords = Array{Float32, 2}[]
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
        coords = Array{Float32}(undef, vnum, 3)
        faces = Array{Int32}(undef, fnum, 3)
        for row in 1:vnum
            for col in 1:3
                coords[row, col] = ntoh(read(io, Float32))
            end
        end
        for row in 1:fnum
            for col in 1:3
                faces[row, col] = ntoh(read(io, Int32))
            end
        end
        faces .= faces .+ 1
    end

    return Surface(coords, faces, stamp)
end


function loadbrain(subjects_dir::AbstractString, subject::AbstractString)
    lhfile = joinpath((subjects_dir, subject, "surf", "lh.pial"))
    lh = readsurface(lhfile)
    rhfile = joinpath((subjects_dir, subject, "surf", "rh.pial"))
    rh = readsurface(rhfile)
    return Brain(lh, rh)
end

end
