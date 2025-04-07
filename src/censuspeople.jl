
struct CensusPerson
    givenname::String
    surname::String
    birthyear::Union{Int, Nothing}
    id::UUID
 end
 
 
 function givenname(p::CensusPerson)
    p.givenname
 end
 function surname(p::CensusPerson)
    p.surname
 end
 function id(p::CensusPerson)
    p.id
 end
 function birthyear(p::CensusPerson)
    p.birthyear
 end
 
 function delimited(rec::CensusPerson; delimiter = "|")
    return join([rec.givenname, rec.surname, rec.birthyear, rec.id], delimiter)
 end
 
 function show(io::IO, p::CensusPerson)
    s = string(p.givenname, " ", p.surname, " (b. $(p.birthyear))")
    print(io, s)
 end

 function matchingrecords(p::CensusPerson, records::Vector{T}; strict = true) where T <: CensusRecord
    if ! strict
        @warn("Fuzzy matching not yet implemented")
    end

    filter(records) do rec
        givenname(rec) == givenname(p) &&
        surname(rec) == surname(p) &&
        birthyear(rec) == birthyear(p)
    end
 end

 function person(rec::CensusRecord, people::Vector{CensusPerson})
    matches = matchingpeople(rec, people)
    if length(matches) == 1
        matches[1]
    else
        @warn("No unique match for person")
        nothing
    end
 end

 function matchingpeople(record::T, people::Vector{CensusPerson}; strict = true) where T <: CensusRecord
    if ! strict
        @warn("Fuzzy matching not yet implemented")
    end

    filter(people) do p
        givenname(record) == givenname(p) &&
        surname(record) == surname(p) &&
        birthyear(record) == birthyear(p)
    end
 end


 function housemates(p::T, records::Vector{T}) where T <: CensusRecord
    filter(records) do rec
        dwelling(p) == dwelling(rec)
    end
 end


 function housemates(p::CensusPerson, records::Vector{T}) where T <: CensusRecord

    personrecords = matchingrecords(p, records)
    
    if length(personrecords) == 1
        filter(records) do rec
            dwelling(personrecords[1]) == dwelling(rec)
        end
    else
        @warn("For $(p), found multiple census records")
    end
 end


 function relations(p::CensusPerson, records::Vector{Census1880}, people::Vector{CensusPerson})
    rels = []
    currenthead = nothing
    for rec in housemates(p, records)
        peopleids = matchingpeople(rec, people)
        if length(peopleids) == 1
            #@info("== Person $(peopleids[1])")
        else
            #@info("No unique person")
        end
        if ishoh(rec)
            currenthead = peopleids[1]
        else
            relative = peopleids[1]
    

            if isempty(relation(rec))
                @info("NOT related $relative")
            else
                pr = (hoh = currenthead, relative = relative, relation = lowercase(relation(rec)))
                push!(rels, pr)
            end
        end
    end
   
    rels
end