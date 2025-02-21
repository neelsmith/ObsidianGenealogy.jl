
function parentrecords(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    parents = filter(tripls) do t
        t.key == "parents"
    end 

    filter(parentstructure.(parents)) do record
        ! isnothing(record)
    end
end

function parentrecords(gv::GenealogyVault, name)
    wname = Obsidian.iswikilink(name) ? name :  string("[[", name, "]]")
    @debug("Look for $(wname)")
    filter(rec -> rec.name == wname, parentrecords(gv))
end

function parentstructure(note::NoteKV)
    cols = split(note.value, "|")
    if length(cols) == 5
        (name, father, mother, source, sourcetype) = cols
        (name = name, father = father, mother = mother, source = source, sourcetype = sourcetype) 
    else
        @warn("Unable to parse parentstructure in note $(note)")
        nothing
    end
end

function father(gv, name)
    @debug("Find parents for $(name)")
    recc = parentrecords(gv, name)

    if isempty(recc)
        nothing
    else
        @debug("Look at $(recc)")
        fathervalues = map(rec -> rec.father, recc) |> unique
        nonempties = filter(n -> !isempty(n), fathervalues)
        isempty(nonempties) ? nothing : dewikify(nonempties[1])
    end
end

function mother(gv, name)
    @debug("Find parents for $(name)")
    recc = parentrecords(gv, name)

    if isempty(recc)
        nothing
    else
        @debug("Look at $(recc)")
        mothervalues = map(rec -> rec.mother, recc) |> unique
        nonempties = filter(n -> !isempty(n), mothervalues)
        isempty(nonempties) ? nothing : dewikify(nonempties[1])
    end
end

function childrecords(gv::GenealogyVault, name)
    wname = wikify(name) #Obsidian.iswikilink(name) ? name :  string("[[", name, "]]")
    @debug("Look for $(wname)")
    filter(rec -> rec.father == wname || rec.mother == wname, parentrecords(gv))
end

function childrecords(gv::GenealogyVault, parent1, parent2)
    wikiform1 = "[[" * parent1 * "]]"
    wikiform2 = "[[" * parent2 * "]]"
    filter(parentrecords(gv)) do rec
        (rec.father == wikiform1 && rec.mother  == wikiform2) ||
        (rec.father == wikiform2 && rec.mother  == wikiform1)
    end
end


function partners(gv::GenealogyVault, name)
    
    map(childrecords(gv, name)) do rec
        rec.father == wikify(name) ? rec.mother : rec.father
    end |> unique
end
