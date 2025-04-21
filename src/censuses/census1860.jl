

struct Census1860 <: CensusRecord
    #PageLine|Structure|Family|Given|Surname|Age|BirthYear|Gender|Race|Occupation|Industry|Value|BirthPlace|MarriedThisYear|AttendedSchool|Illiterate|Condition
    structure::Int
    family::Int
    givenname::String
    surname::String
    age::Int 
    birthyear::Int
    gender::Union{Char, Nothing}
    race::Union{Char, Nothing}
    occupation::String
    industry::String
    realesate::Union{Int, Nothing}
    birthplace::String
    marriedthisyear::Bool
    attendedschool::Bool
    illiterate::Bool
    condition::String
    enumeration::String
    page::Int
    line::Int
end


function censusyear(c::Census1860)
    1860
end
function show(io::IO, c::Census1860)
    basic = string(
            c.givenname, " ", c.surname,
            ", ",
            c.race, " ", c.gender, 
            ", b. ", c.birthyear, " in ", c.birthplace, ". ",
            " (Household $(dwelling(c)))"
           
        )
    print(io, basic)
 end


function enumeration(rec::Census1860)
    rec.enumeration
end

function page(rec::Census1860)
    rec.page
end

function line(rec::Census1860)
    rec.line
end


function dwelling(rec::Census1860)
    rec.structure
 end

function family(rec::Census1860)
    rec.family
 end
 


function givenname(rec::Census1860)
    rec.givenname
end
function surname(rec::Census1860)
    rec.surname
end
function birthyear(rec::Census1860)
    rec.birthyear
end

function birthplace(rec::Census1860)
    rec.birthplace
 end 

function gender(rec::Census1860)
    rec.gender
end



function race(rec::Census1860)
    rec.race
end

function occupation(rec::Census1860)
    rec.occupation
end




function census1860table(datalines::Vector{String}, enumeration::Symbol; delimiter = "|")

    # Parse each line into a Census1860 object
    #records = [census1860(line, enumeration) for line in data if !isempty(line)]
    #filter(rec -> ! isnothing(rec), records)
    data = filter(ln -> ! isempty(ln), datalines)
    #records = [census1880(line, enumeration) for line in data if !isempty(line)]

    records = Census1860[]
    currpage = 1
    prevline = 0
    for (i,line) in enumerate(data)
        cols = split(line, delimiter)
        currline = try 
             parse(Int, cols[1])
        catch e 
            @warn("Failed to parse int for currline $(cols[1]) in line number: $i, $(line)")
            nothing
        end
        if ! isnothing(currline) && currline <= prevline
            currpage = currpage + 1
        end
        push!(records, census1860(line, enumeration, currpage))
        prevline = currline
    end
    filter(rec -> ! isnothing(rec), records)
end

function census1860table(filename::String, enumeration::Symbol; delimiter = "|")
    census1860table(readlines(filename), enumeration; delimiter = delimiter)
end


"""Download and parse the 1860 US Census data for a given enumeration and year.
$(SIGNATURES)
"""
function census1860table(enumeration::Symbol; delimiter = "|")
    # Read census data from a URL
    url = censusurl(enumeration, 1860)
    if isnothing(url)
        @warn("No URL found for enumeration: $enumeration and year: $year")
        return nothing
    end

    f = Downloads.download(url)
    rawdata = readlines(f)[2:end]
    rm(f)
    census1860table(rawdata, enumeration; delimiter = delimiter)
end

"""Read a single record for the 1860 US Census from a delimited string.

$(SIGNATURES)
"""
function census1860(delimited, enumeration::Symbol, page::Int; delimiter = "|")
    # Parse the delimited string into a Census1860 object
    cols = split(delimited, delimiter)
    if length(cols) < 17
        @warn("Invalid number of columns in census record: $delimited")
        return nothing
    end
    # Extract the columns
    
    (rownumber, structraw, familyraw, 
    givenname, surname,
    ageraw, birthyearraw,
    genderraw, raceraw,
    occupation, industry,
    realesateraw, birthplace,
    marriedthisyearraw, attendedschoolraw,
    illiterateraw, condition) = cols

    line = try 
        parse(Int, rownumber)
    catch e
        @warn("Failed to parse line number: $rownumber")
        nothing
    end
    structure = try 
        parse(Int, structraw)
    catch e
        @warn("Failed to parse structure: $structraw")
        nothing
    end
    family = try 
        parse(Int, familyraw)
    catch e
        @warn("Failed to parse family: $familyraw")
        nothing
    end
    age = try 
        parse(Int, ageraw)
    catch e
        nothing
    end
    birthyear = try 
        parse(Int, birthyearraw)
    catch e
        nothing
    end
    gender = genderraw[1] in ['M', 'F'] ? genderraw[1] : nothing
    race = raceraw[1] in ['W', 'B', 'M', 'I', 'C'] ? raceraw[1] : nothing
    realesate = try 
        parse(Int, realesateraw)
    catch e
        nothing
    end
    marriedthisyear = isempty(marriedthisyearraw) ? false : true
    attendedschool = isempty(attendedschoolraw) ? false : true
    illiterate = isempty(illiterateraw) ? false : true

    try
        (structure, family, givenname, surname, 
        age, birthyear, gender, race, occupation, industry,
        realesate, birthplace, marriedthisyear, attendedschool,
        illiterate, condition,
        censuslabels[enumeration], page, line
        )
       #= Census1860(structure, family, givenname, surname, 
        age, birthyear, gender, race, occupation, industry,
        realesate, birthplace, marriedthisyear, attendedschool,
        illiterate, condition,
        censuslabels[enumeration], page, line
        )
      =#
    catch e
        @warn("Failed to parse census record: $delimited")
        return nothing
    end
    
end



