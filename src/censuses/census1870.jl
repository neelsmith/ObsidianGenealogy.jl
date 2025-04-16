struct Census1870 <: CensusRecord
    #Line Number|Dwelling Number|Family Number|Surname|Given Name|Age|Birth Year|Gender|Race|Occupation|Real Estate Value|Personal Estate Value|Birthplace|Father of Foreign Birth|Mother of Foreign Birth|Birth Month|Marriage Month|Attended School|Cannot Read|Cannot Write|Condition|Male Citizen Over 21|Denied Voting Rights

    structure::Int
    family::Int
    givenname::String
    surname::String
    age::Union{Int, Nothing}
    birthyear::Union{Int,Nothing}
    gender::Union{Char, Nothing}
    race::Union{Char, Nothing}
    occupation::String
    realesate::Union{Int, Nothing}
    personalestate::Union{Int, Nothing}
    birthplace::String


    fatherforeign::Bool
    motherforeign::Bool
    
    birthmonth::String
    marriagemonth::String

    attendedschool::Bool
    cannotread::Bool
    cannotwrite::Bool
    condition::String

    adultmale::Bool
    deniedvoting::Bool

    enumeration::String
    page::Int
    line::Int
end



function censusyear(c::Census1870)
    1870
end

function show(io::IO, c::Census1870)
    basic = string(
            c.givenname, " ", c.surname,
            ", ",
            c.race, " ", c.gender, 
            ", b. ", c.birthyear, " in ", c.birthplace, ". ",
            " (Household $(dwelling(c)))"
           
        )
    print(io, basic)
 end


function enumeration(rec::Census1870)
    rec.enumeration
end

function page(rec::Census1870)
    rec.page
end

function line(rec::Census1870)
    rec.line
end


function dwelling(rec::Census1870)
    rec.structure
 end

function family(rec::Census1870)
    rec.family
 end
 


function givenname(rec::Census1870)
    rec.givenname
end
function surname(rec::Census1870)
    rec.surname
end
function birthyear(rec::Census1870)
    rec.birthyear
end

function birthplace(rec::Census1870)
    rec.birthplace
 end 

function gender(rec::Census1870)
    rec.gender
end



function race(rec::Census1870)
    rec.race
end

function occupation(rec::Census1870)
    rec.occupation
end



function census1870table(filename::String, enumeration::Symbol; delimiter = "|")
    census1870table(readlines(filename), enumeration; delimiter = delimiter)
end

function census1870table(datalines::Vector{String}, enumeration::Symbol; delimiter = "|")
     # Parse each line into a Census1870 object
    #records = [census1870(line, enumeration) for line in data if !isempty(line)]
    #filter(rec -> ! isnothing(rec), records)
    data = filter(ln -> ! isempty(ln), datalines)
    #records = [census1880(line, enumeration) for line in data if !isempty(line)]

    records = Census1870[]
    currpage = 1
    prevline = 0
    for line in data
        cols = split(line, delimiter)
        currline = try 
             parse(Int, cols[1])
        catch e 
            @warn("Failed to parse line on page $(currpage): $line ")
            nothing
        end
        if ! isnothing(currline) && currline <= prevline
            currpage = currpage + 1
        end
        push!(records, census1870(line, enumeration, currpage))
        prevline = currline
    end
    filter(rec -> ! isnothing(rec), records)
end


"""Download and parse the 1870 US Census data for a given enumeration and year.
$(SIGNATURES)
"""
function census1870table(enumeration::Symbol; delimiter = "|")
    # Read census data from a URL
    url = censusurl(enumeration, 1870)
    if isnothing(url)
        @warn("No URL found for enumeration: $enumeration and year: $year")
        return nothing
    end

    f = Downloads.download(url)
    rawdata = readlines(f)[2:end]
    rm(f)
    census1870table(rawdata, enumeration; delimiter = delimiter)
end

   




"""Read a single record for the 1870 US Census from a delimited string.

$(SIGNATURES)
"""
function census1870(delimited, enumeration::Symbol, page::Int; delimiter = "|")
    # Parse the delimited string into a Census1870 object
    cols = split(delimited, delimiter)
    #Line Number|Dwelling Number|Family Number|Surname|Given Name|Age|Birth Year|Gender|Race|Occupation|Real Estate Value|Personal Estate Value|Birthplace|Father of Foreign Birth|Mother of Foreign Birth|Birth Month|Marriage Month|Attended School|Cannot Read|Cannot Write|Condition|Male Citizen Over 21|Denied Voting Rights
    if length(cols) < 23
        @warn("Invalid number of columns [$(length(cols))] in census record: $delimited")
        return nothing
    end
    # Extract the columns
    (rownumber, structraw, familyraw, 
    surname, givenname,
    ageraw, birthyearraw,
    genderraw, raceraw,
    occupation, 

    realesateraw, personalestateraw, birthplace,
    foreignfatherraw, foreignmotherraw, 
    birthmonth, marriagemonth, 
    attendedschoolraw,
    cannotreadraw, cannotwriteraw, condition,
    adultmaleraw, deniedvoteraw
    ) = cols

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

    personalestate = try 
        parse(Int, personalestateraw)
    catch e
        nothing
    end
    
    attendedschool = isempty(attendedschoolraw) ? false : true
    cannotread = isempty(cannotreadraw) ? false : true
    cannotwrite = isempty(cannotwriteraw) ? false : true

    adultmale = isempty(adultmaleraw) ? false : true
    deniedvote = isempty(deniedvoteraw) ? false : true

    foreignfather = isempty(foreignfatherraw) ? false : true
    foreignmother = isempty(foreignmotherraw) ? false : true

    try

        Census1870(structure, family, givenname, surname, 
        age, birthyear, gender, race, occupation, 
        realesate, personalestate, birthplace, 
        foreignfather, foreignmother,
        birthmonth, marriagemonth, attendedschool,
        cannotread, cannotwrite, condition,
        adultmale, deniedvote,
        censuslabels[enumeration], page, line
        )
      
    catch e
        @warn("Failed to parse census record: $delimited")
        @warn(e)
        return nothing
    end
    
end


