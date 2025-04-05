using ObsidianGenealogy

v1880 = census1880table(:vergennes)


for p in v1880
    if p.relation == "Self (Head)"
        println("Head of household:")
        println("\t" * ObsidianGenealogy.readable(p) * "\n")
    end
end