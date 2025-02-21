@testset "Test working wikiname format" begin
    original = "Name of an Obsidian note"
    @test dewikify(wikify(original)) == original
end