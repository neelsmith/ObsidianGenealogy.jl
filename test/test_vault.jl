@testset "Test genealogy vault organizatoin" begin
    @info(pwd())
    vaultdir = joinpath(pwd(), "data", "tiny")
    ovault = Vault(vaultdir)
    gvault = GenealogyVault(ovault, "documents", "people")
    @test gvault isa GenealogyVault

    @test_throws ArgumentError GenealogyVault(ovault, "baddocuments", "people")

    @test_throws ArgumentError GenealogyVault(ovault, "documents", "badpeople")
end