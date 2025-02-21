
function conclusions(gv::GenealogyVault, person)
    allnotes = noteson(gv, person)
    birthlist = filter(n -> n.key == "birthdate", allnotes)
    deathlist = filter(n -> n.key == "deathdate", allnotes)
    motherlist =  filter(n -> n.key == "mother", allnotes)
    fatherlist =  filter(n -> n.key == "father", allnotes)

    birth = isempty(birthlist) ? "?" : birthlist[1].value
    death = isempty(deathlist) ? "?" : deathlist[1].value
    mother = "?"
    father = "?"

    if ! isempty(motherlist)
        mother = dewikify(motherlist[1].value)
    end
    if ! isempty(fatherlist)
        father = dewikify(fatherlist[1].value)
    end
    
    (birth = birth, death = death, mother = mother, father = father)
end



function hasconclusions(gv::GenealogyVault, person)
    conclusions(gv, person) |> hasconclusions
end



"""True if one or more vital records in a tuple has some valid data.
$(SIGNATURES)
"""
function hasconclusions(record)
    noconclusions = record.birth == "?" && 
    record.death  == "?" &&
    record.mother  == "?" &&
    record.father  == "?"

    ! noconclusions
end