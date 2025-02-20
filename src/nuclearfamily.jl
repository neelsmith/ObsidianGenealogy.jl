
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