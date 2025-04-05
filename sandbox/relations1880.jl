using ObsidianGenealogy

v1880 = census1880table(:vergennes)

currenthead = nothing
for p in v1880
    if p.relation == "Self (Head)"
        println("\nHead of household:")
        println("\t" * ObsidianGenealogy.readable(p) )
        currenthead = p
    else
        println("Relation of $(p.givenname) $(p.surname) to head:  $(p.relation) " )
    end
end