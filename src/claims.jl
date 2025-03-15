

"""Find all claims about birth in vault.

$(SIGNATURES)
"""
function birthrecords(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    births = filter(tripls) do t
        t.key == "birth"
    end 

    structs = birthstructure.(births)
    filter(s -> ! isnothing(s), structs)
end

"""Find all birthrecords about a named individual in a vault.
$(SIGNATURES)
"""
function birthrecords(gv::GenealogyVault, name)
    wname = Obsidian.iswikilink(name) ? name :  string("[[", name, "]]")
    @debug("Look for $(wname)")
    filter(rec -> rec.name == wname, birthrecords(gv))
end

"""Parse `NoteKV` data into a named tuple with data about birth.
$(SIGNATURES)
"""
function birthstructure(note::NoteKV)
    cols = split(note.value, "|")
    if length(cols) == 5
        (name, date, place, source, sourcetype) = cols
        (name = name, date = date, place = place, source = source, sourcetype = sourcetype) 
    else
        @warn("Unable to parse birthstructure in note $(note)")
        nothing
    end
end


"""Find all claims about death for a person.

$(SIGNATURES)
"""
function deathrecords(gv::GenealogyVault, person)
    wname = Obsidian.iswikilink(person) ? person :  string("[[", person, "]]")
    @debug("Look for $(wname)")
    filter(rec -> rec.name == wname, deathrecords(gv))
end


"""Find all claims about birth in vault.

$(SIGNATURES)
"""
function deathrecords(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    deaths = filter(tripls) do t
        t.key == "death"
    end 

    deathstructure.(deaths)
end



"""Parse `NoteKV` data into a named tuple with data about birth.
$(SIGNATURES)
"""
function deathstructure(note::NoteKV)
    cols = split(note.value, "|")
    
    if length(cols) == 5
        (name, date, place, source, sourcetype) = cols
        (name = name, date = date, place = place, source = source, sourcetype = sourcetype) 
    else
        @warn("Unable to parse deathstructure in note $(note)")
        nothing
    end
    
end



"""Find triples for all claims identifying a father.
$(SIGNATURES)
"""
function fatherlist(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    fathers = filter(tripls) do t
        t.key == "father"
    end 

    fatherstructure.(fathers)
end



"""Find triples for all claims identifying a mother.
$(SIGNATURES)
"""
function motherlist(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    mothers = filter(tripls) do t
        t.key == "mother"
    end 

    motherstructure.(mothers)
end



function sources(gv, person)
    filter(kvtriples(gv.vault)) do tr
        tr.key == "refersto" &&
        tr.value == wikify(person)
    end
end