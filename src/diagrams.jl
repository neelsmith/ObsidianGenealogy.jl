
"""Compose a label for a node in a Mermaid diagram.
$(SIGNATURES)
"""
function nodelabel(s)
    string(replace(dewikify(s), " " => "_"), "(", dewikify(s), ")")
end


function linkednodelabel(gv::GenealogyVault, src, target)
    relpath = htmllink(gv, src, target)
    pathlabel = string("<a href='",relpath,"'>", dewikify(target), "</>")
    
    string(replace(dewikify(target), " " => "_"), "(", pathlabel, ")")
end

"""Wrap string `s` in mermaid block fencing.
$(SIGNATURES)
"""
function wrapmermaid(s; quarto = true)
    quarto ? string("```{mermaid}\n",s,"\n```\n") : string("```{mermaid}\n",s,"\n```\n") 
end


"""Define CSS classes for ancestor and descendant diagrams.
$(SIGNATURES)
"""
function cssClasses()
    """classDef mother fill:#ffd1dc
classDef father fill:#daf0f7  
classDef marriage fill:#ffffff
"""
end


"""Compose a Mermaid diagram for the ancestor tree of a named individual.
$(SIGNATURES)
"""
function ancestordiagram(v::GenealogyVault, name)
    edges = []
    ancestor_edges!(v, name, edges)
    string("graph LR\n", join(edges, "\n"), "\n", cssClasses())
end


"""Recursively compile edges for the ancestor graph of a given person.
$(SIGNATURES)
"""
function ancestor_edges!(v::GenealogyVault, person, edges)
    if isnothing(person)
        # nothing
    else
        dad = father(v, person)
        mom = mother(v, person)

        if ! isnothing(dad)

            #push!(edges, "$(nodelabel(person)) -->  $(nodelabel(dad))")
            push!(edges, "$(linkednodelabel(v, person, person)) -->  $(linkednodelabel(v, person, dad))")
            ancestor_edges!(v, dad, edges)
            nodename = replace(dewikify(dad), " " => "_")
            push!(edges, "class $(nodename) father")
        end

        if ! isnothing(mom) #m !== nothing
            #push!(edges, "$(nodelabel(person))  --> $(nodelabel(mom))")
            push!(edges, "$(linkednodelabel(v,person,person))  --> $(linkednodelabel(v,person,mom))")
            ancestor_edges!(v, mom, edges)
            nodename = replace(dewikify(mom), " " => "_")
            push!(edges, "class $(nodename) mother")
        end
    end
end




"""Compose a Mermaid diagram for the descendant tree of a named individual.
$(SIGNATURES)
"""
function descendantdiagram(gv::GenealogyVault, person)
    edges = []
    descendant_edges!(gv, person, edges)
    string("graph LR\n", join(edges, "\n"),"\n", cssClasses())
end


"""Recursively compile edges for the descendat graph of a given person.
$(SIGNATURES)
"""
function descendant_edges!(gv::GenealogyVault, person, edges)
    if isnothing(person)
        # nothing
    else
        spice = partners(gv, person)
        for spouse in spice
            mrg = replace((string(dewikify(person), "_and_", dewikify(spouse))), " " => "_")
            push!(edges, "class $(mrg) marriage")
            #push!(edges, "$(nodelabel(person)) --> $(mrg)[ ]")
            push!(edges, "$(linkednodelabel(gv, person,person)) --> $(mrg)[ ]")
            #push!(edges, "$(nodelabel(spouse)) --> $(mrg)(( ))")
            push!(edges, "$(linkednodelabel(gv, person, spouse)) --> $(mrg)(( ))")
            kids = childrecords(gv, person, dewikify(spouse))
            for kid in kids
                @debug("Linking $(mrg) to $(dewikify(kid.name))")
                #push!(edges, "$(mrg)[ ] --> $(nodelabel(kid.name))")
                push!(edges, "$(mrg)[ ] --> $(linkednodelabel(gv, person, kid.name))")
                descendant_edges!(gv, kid.name, edges)
            end
        end
        
    end
end