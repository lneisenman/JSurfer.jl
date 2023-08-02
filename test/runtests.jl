using JSurfer
using Test, TestItems

# @testset "JSurfer.jl" begin
#     # Write your tests here.
# end

@testitem "test readsurface" begin
    fn = "/mnt/Active/SEEG/subjects/LNE_2021/surf/lh.pial"
    surf = readsurface(fn)
    @test size(surf.vertices) == (147886, 3)
end
