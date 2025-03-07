@testset "Test working wikiname format" begin
    original = "Name of an Obsidian note"
    @test dewikify(wikify(original)) == original
end


@testset "Test checking datavalues" begin
    @test ObsidianGenealogy.hasdata("x")
    @test ObsidianGenealogy.allwhitespace("x") == false

    @test ObsidianGenealogy.allwhitespace(" ")
    @test ObsidianGenealogy.hasdata(" ") == false

    @test ObsidianGenealogy.allwhitespace("")
    @test ObsidianGenealogy.hasdata("") == false

    @test ObsidianGenealogy.allwhitespace("?") == false
    @test ObsidianGenealogy.hasdata("?") == false

    @test ObsidianGenealogy.hasdata(nothing) == false
end