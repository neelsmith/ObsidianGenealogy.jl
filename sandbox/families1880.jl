using ObsidianGenealogy
v1880 = census1880table(:vergennes)


#=
 "aunt"
 "daughter"
 "daughter-in-law"
 "father"
 "granddaughter"
 "grandmother"
 "grandson"
 "mother"
 "nephew"
 "niece"
 "sister"
 "son"
 "son-in-law"
 "uncle"
 "wife
=#

function relate(head, member)
    (head = head, relation = relation(member), member = member)
end

currhead = nothing
for p in v1880
    if  relation(p) == "Self (Head)"
        global currhead = p
        println("\nHead of household:\n\t" * readable(p))
    elseif ! isempty(p.relation)

        @info(relate(currhead, p))
        #println(string(p.givenname, " ", p.surname, ", ", p.relation))
    else
        #@warn("*Not related: " * readable(p))
    end
end