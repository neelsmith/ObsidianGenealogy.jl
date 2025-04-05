using ObsidianGenealogy
v1880 = census1880table(:vergennes)

for p in v1880
    if  relation(p) == "Self (Head)"
        println("\nHead of household:\n\t" * readable(p))
    elseif ! isempty(p.relation)
        println(string(p.givenname, " ", p.surname, ", ", p.relation))
    else
        println("*Not related: " * readable(p))
    end
end