using ObsidianGenealogy, Obsidian 
using UUIDs


fburg1850 = census1850table(:ferrisburg)


struct CensusPerson
    givenname::String
    surname::String
    birthyear::Int
    id::UUID
end


fburgpeople = map(fburg1850) do rec
   CensusPerson(
        rec.givenname,
        rec.surname,
        rec.birthyear,
        UUIDs.uuid4()
    )
end


function delimited(rec::CensusPerson)
    return join([rec.givenname, rec.surname, rec.birthyear, rec.id], "|")
end

function personidforcensusrec(rec, people::Vector{CensusPerson})
    matches = filter(people) do rec
        rec.givenname == eg.givenname &&
        rec.surname == eg.surname &&
        rec.birthyear == eg.birthyear
    end

    if length(matches) == 1
        return matches[1].id
    elseif length(matches) > 1
        @warn("Multiple matches found for census record: $rec")
        return nothing
    else
        @warn("No match found for census record: $rec")
        return nothing
    end
end

