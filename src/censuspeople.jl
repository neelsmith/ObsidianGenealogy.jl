
struct CensusPerson
    givenname::String
    surname::String
    gender::Union{Char,Nothing}
    birthyear::Union{Int, Nothing}
    id::UUID
 end
 

 function gender(p::CensusPerson)
    p.gender
 end

 function givenname(p::CensusPerson)
    p.givenname
 end
 function surname(p::CensusPerson)
    p.surname
 end
 function id(p::CensusPerson)
    @info("Get idval for this person")
    p.id
 end
 function birthyear(p::CensusPerson)
    p.birthyear
 end
 
 function delimited(rec::CensusPerson; delimiter = "|")
    return join([rec.givenname, rec.surname, rec.gender, rec.birthyear, rec.id], delimiter)
 end
 
 function show(io::IO, p::CensusPerson)
    s = string(p.givenname, " ", p.surname, " (b. $(p.birthyear))")
    print(io, s)
 end

 function matchingrecords(p::CensusPerson, records::Vector{T}; strict = true) where T <: CensusRecord
    if ! strict
        filter(records) do rec
            givenname(rec)[1] == givenname(p)[1] &&
            surname(rec) == surname(p) &&
            gender(rec) == gender(p) &&
            birthyear(rec) == birthyear(p)
        end

    else

        filter(records) do rec
            givenname(rec) == givenname(p) &&
            surname(rec) == surname(p) &&
            gender(rec) == gender(p) &&
            birthyear(rec) == birthyear(p)
        end
    end
 end

 function person(rec::CensusRecord, people::Vector{CensusPerson}; strict = true)
    matches = matchingpeople(rec, people; strict = strict)
    if length(matches) == 1
        matches[1]
    elseif isempty(matches)
        @debug("No matches for person (strict = $(strict))")
        nothing
    else
        @debug("Multiple matches for person")
        nothing
    end
 end

 function matchingpeople(record::T, people::Vector{CensusPerson}; strict = true) where T <: CensusRecord
    if ! strict
        filter(people) do p
            if !isempty(givenname(record)) && 
                !isempty(givenname(p))
                givenname(record)[1] == givenname(p)[1] &&
                surname(record) == surname(p) &&
                gender(record)  == gender(p) &&
                birthyear(record) == birthyear(p)
            else 
                false
            end
        end

    else
        filter(people) do p
            givenname(record) == givenname(p) &&
            surname(record) == surname(p) &&
            gender(record) == gender(p) &&
            birthyear(record) == birthyear(p)
        end
    end
 end


 function housemates(p::T, records::Vector{T}) where T <: CensusRecord
    filter(records) do rec
        dwelling(p) == dwelling(rec) &&
        enumeration(p) == enumeration(rec)
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
            elseif relative == p
                pr = (hoh = currenthead, relative = relative, relation = lowercase(relation(rec)))
                push!(rels, pr)
            end
        end
    end
   
    rels
end


function vermonters()
    url = "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/vermonters.cex"
    f = Downloads.download(url)


    folks = CensusPerson[]
    data = filter(ln -> ! isempty(ln), readlines(f)[2:end])
    for ln in data
        (givenname, surname, gender, yearraw, id) = split(ln, "|")
        birthyear = try
            parse(Int,yearraw)
        catch
            @warn("Couldn't parse year from $(yearraw)")
            nothing
        end
        push!(folks, CensusPerson(givenname, surname, gender[1], birthyear, UUID(id)))
    end
    rm(f)
    folks
end