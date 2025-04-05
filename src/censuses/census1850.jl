

struct Census1850 <: CensusRecord
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
end



function dwelling(rec::Census1850)
    rec.structure
 end

function family(rec::Census1850)
    rec.family
 end
 


function givenname(rec::Census1850)
    rec.givenname
end
function surname(rec::Census1850)
    rec.surname
end
function birthyear(rec::Census1850)
    rec.birthyear
end

function birthplace(rec::Census1850)
    rec.birthplace
 end 

function gender(rec::Census1850)
    rec.gender
end



function race(rec::Census1850)
    rec.race
end

function occupation(rec::Census1850)
    rec.occupation
end







"""Download and parse the 1850 US Census data for a given enumeration and year.
$(SIGNATURES)
"""
function census1850table(enumeration::Symbol)
    # Read census data from a URL
    url = censusurl(enumeration, 1850)
    if isnothing(url)
        @warn("No URL found for enumeration: $enumeration and year: $year")
        return nothing
    end

    f = Downloads.download(url)
    data = readlines(f)[2:end]
    rm(f)
    # Parse each line into a Census1850 object
    records = [census1850(line, enumeration) for line in data if !isempty(line)]
    filter(rec -> ! isnothing(rec), records)
end

"""Read a single record for the 1850 US Census from a delimited string.

$(SIGNATURES)
"""
function census1850(delimited, enumeration::Symbol; delimiter = "|")
    # Parse the delimited string into a Census1850 object
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
        Census1850(structure, family, givenname, surname, 
        age, birthyear, gender, race, occupation, industry,
        realesate, birthplace, marriedthisyear, attendedschool,
        illiterate, condition,
        censuslabels[enumeration]
        )
      
    catch e
        @warn("Failed to parse census record: $delimited")
        return nothing
    end
    
end



