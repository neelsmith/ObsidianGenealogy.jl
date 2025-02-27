"""Create a named tuple of conclusions for a person.
$(SIGNATURES)
"""
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


"""True if one or more conclusion tyupes has valid data for
this person.
$(SIGNATURES)
"""
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


function evidenceforbirth(gv, person)
    birthrecords(gv, person)
end

function evidencefordeath(gv, person)
    deathrecords(gv, person)
end


function evidenceforfather(gv, person; value = "")
    allrecords = filter(parentrecords(gv, person)) do rec
        ! isempty(rec.father)
    end
    if ! isempty(value)
        filter(rec -> dewikify(rec.father) == value, allrecords)
    else
        allrecords
    end
end




function evidenceformother(gv, person; value = "")
    allrecords = filter(parentrecords(gv, person)) do rec
        ! isempty(rec.mother)
    end
    if ! isempty(value)
        filter(rec -> dewikify(rec.mother) == value, allrecords)
    else
        allrecords
    end
end


function evidenceforchild(gv, person; value = "")
    allrecords = filter(childrecords(gv, person)) do rec
        ! isempty(rec.name)
    end
    if ! isempty(value)
        filter(rec -> dewikify(rec.name) == value, allrecords)
    else
        allrecords
    end
end


function evidenceforconclusion(gv, person, conclusiontype; value = "")
    if conclusiontype == :birth
        evidenceforbirth(gv, person)
    elseif conclusiontype == :death
        evidencefordeath(gv, person)
    elseif conclusiontype == :father
        evidenceforfather(gv, person; value = value)
    elseif conclusiontype == :mother
        evidenceformother(gv, person; value = value)
    elseif conclusiontype == :child
        evidenceforchild(gv, person; value = value)
    end
end

"""True if a valid conclusoin of the specified type exists for a person.
$(SIGNATURES)
"""
function validconclusion(gv, person, conclusiontype::Symbol; value = "")
    if conclusiontype == :birth
        ! isempty(evidenceforbirth(gv, person))
    elseif conclusiontype == :death
        ! isempty(evidencefordeath(gv, person))
    elseif conclusiontype == :father
        ! isempty(evidenceforfather(gv, person; value = value)) 
    elseif conclusiontype == :mother
        ! isempty(evidenceformother(gv, person; value = value))                
    elseif conclusiontype == :child
        ! isempty(evidenceforchild(gv, person; value = value))   
    end
end

function invalidconclusions(gv, person)
    badlist = []
    conclist = conclusions(gv, person)
    @debug("Conclusions are: $(conclist)")

    @debug("Validate $(conclist)")
    if conclist.birth != "?"
        if validconclusion(gv, person, :birth)
            
        else
            msg = (name = person, type = :birth, value = conclist.birth)
            @warn("Undocumented conclusion for birth")
            push!(badlist, msg)
        end
    else
        @debug("No value for birth")
    end

    if conclist.death != "?"
        if validconclusion(gv, person, :death)
            # ok
        else
            @warn("Undocumented conclusion for death")
            msg = (name = person, type = :death, value = conclist.death)
            push!(badlist, msg)
        end
    else
        @debug("No value for death")
    end
   
    
    if conclist.mother != "?"
        if validconclusion(gv, person, :mother; value = conclist.mother)
            # ok
        else
            @warn("Undocumented conclusion for mother")
            msg = (name = person, type = :mother, value = conclist.mother)
            push!(badlist, msg)
        end
    else
        @debug("No value for mother")
    end

    if conclist.father != "?"
        if validconclusion(gv, person, :father; value = conclist.father)
            # ok
        else
            @warn("Undocumented conclusion for father")
            msg = (name = person, type = :father, value = conclist.father)
            push!(badlist, msg)
        end
    else
        @debug("No value for father")
    end
    badlist
end





function invalidconclusions(gv; publishedonly = false)
    # do for every individual in vault
    badconclusions = []
    folks = people(gv)
    peoplelist = publishedonly ? filter(person -> ObsidianGenealogy.deceased(gv, person), folks) : folks

    for person in peoplelist
        for invalid in invalidconclusions(gv, person)
            push!(badconclusions, invalid)
        end
    end
    badconclusions
end