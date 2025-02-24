
function nodelabel(s)
    string(replace(dewikify(s), " " => "_"), "[", dewikify(s), "]")
end

function wrapmermaid(s; quarto = true)
    quarto ? string("```{mermaid}\n",s,"\n```\n") : string("```{mermaid}\n",s,"\n```\n") 
end

function cssClasses()
    """classDef mother fill:#ffd1dc
classDef father fill:#daf0f7  
"""
end

function ancestordiagram(v::GenealogyVault, name)
    edges = []
    ancestor_edges!(v, name, edges)
    string("graph LR\n", join(edges, "\n"), "\n", cssClasses())
end

function ancestor_edges!(v::GenealogyVault, person, edges)
    if isnothing(person)
        # nothing
    else
        dad = father(v, person)
        mom = mother(v, person)

        if ! isnothing(dad)
            push!(edges, "$(nodelabel(person)) -->  $(nodelabel(dad))")
            ancestor_edges!(v, dad, edges)
            nodename = replace(dewikify(dad), " " => "_")
            push!(edges, "class $(nodename) father")
        end

        if ! isnothing(mom) #m !== nothing
            push!(edges, "$(nodelabel(person))  --> $(nodelabel(mom))")
            ancestor_edges!(v, mom, edges)
            nodename = replace(dewikify(mom), " " => "_")
            push!(edges, "class $(nodename) mother")
        end
    end
end



function descendantdiagram(gv::GenealogyVault, person)
    edges = []
    descendant_edges!(gv, person, edges)
    string("graph LR\n", join(edges, "\n"))
end



function descendant_edges!(gv::GenealogyVault, person, edges)
    if isnothing(person)
        # nothing
    else
        spice = partners(gv, person)
        for spouse in spice
            mrg = replace((string(person, "+", dewikify(spouse))), " " => "_")

            push!(edges, "$(nodelabel(person)) --> $(mrg)[ ]")
            push!(edges, "$(nodelabel(spouse)) --> $(mrg)[ ]")
            kids = childrecords(gv, person, dewikify(spouse))
            for kid in kids
                @debug("Linking $(mrg) to $(dewikify(kid.name))")
                push!(edges, "$(mrg)[ ] --> $(nodelabel(kid.name))")
                descendant_edges!(gv, kid.name, edges)
            end
        end
        
    end
end