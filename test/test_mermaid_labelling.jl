@testset "Test formatting content for Mermaid" begin
    @test ObsidianGenealogy.node("[[Candace Smith]]") == "Candace_Smith(Candace Smith)"
    
end