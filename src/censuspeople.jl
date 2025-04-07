
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