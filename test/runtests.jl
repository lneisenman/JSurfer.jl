using JSurfer
using Test, TestItems

# @testset "JSurfer.jl" begin
#     # Write your tests here.
# end

@testitem "test read_surface" begin
    fn = "/mnt/Active/SEEG/subjects/LNE_2021/surf/lh.pial"
    vertices, faces, stamp = read_surface(fn)
    @test size(vertices) == (147886, 3)
    @test size(faces) == (295768, 3)
end

@testitem "test read_curv" begin
    fn = "/mnt/Active/SEEG/subjects/LNE_2021/surf/lh.curv.pial"
    curv = read_curv(fn)
    @test size(curv) == (147886,)
    
end
@testitem "test load_brain" begin
    brain = load_brain("/mnt/Active/SEEG/subjects", "LNE_2021")
    @test size(brain.lh.vertices) == (147886, 3)
    @test size(brain.lh.curv) == (147886,)
end