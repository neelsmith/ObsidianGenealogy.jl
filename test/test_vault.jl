@testset "Test genealogy vault organization" begin
    @info(pwd())
    vaultdir = joinpath(pwd(),  "assets", "tinyvault")
    ovault = Vault(vaultdir)
    gvault = GenealogyVault(ovault, "documents", "people")
    @test gvault isa GenealogyVault

    @test_throws ArgumentError GenealogyVault(ovault, "baddocuments", "people")

    @test_throws ArgumentError GenealogyVault(ovault, "documents", "badpeople")
end