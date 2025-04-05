

struct Census1880 <: CensusRecord
    #Street|Dwelling|Surname|GivenName|Race|Gender|Age|BirthMonth|BirthYear|Relation|Marital|MarriedThisYear|Occupation|MonthsUnemployed|Sick|Blind|DeafDumb|Idiotic|Insane|Maimed|AttendedSchool|CannotRead|CannotWrite|Birthplace|FatherBirthPlace|MotherBirthPlace
    street::String
    dwelling::Int
    surname::String
    givenname::String
    race::String
    gender::Union{Char, Nothing}
    age::Union{Int, Nothing}
    birthyear::Union{Int, Nothing}
    relation::String
    marital::String
    marriedthisyear::Bool    
    occupation::String
    monthsunemployed::Int
    sick::String
    blind::Bool
    deaf_dumb::Bool
    idiotic::Bool
    insane::Bool
    maimed::Bool
    attendedschool::Bool
    cannotread::Bool
    cannotwrite::Bool
    birthplace::String
    fatherbirthplace::String
    motherbirthplace::String
    # The enumeration is the name of the census district
    enumeration::String
end

"""Format a string with a readable summary of a complete 1880 census entry.
$(SIGNATURES)
"""
function readable(c::Census1880)
        basic = string(
            c.givenname, " ", c.surname,
            ", ",
            c.race, " ", c.gender, 
            ", born ", c.birthyear, " in ", c.birthplace,
            " (", c.age, " in 1880). ",
            "Household $(c.dwelling). "
           
        )
        additions = []

        if ! isempty(c.relation)
            push!(additions, string("Role in household: ", c.relation, ". "))
        end
        if ! isempty(c.motherbirthplace)
            push!(additions, "Mother born in $(c.motherbirthplace). ")
        end
        if ! isempty(c.fatherbirthplace)
            push!(additions, "Father born in $(c.fatherbirthplace). ")
        end


        if !isempty(c.occupation)
            push!(additions, "Occupation: " * c.occupation * ". ")
        end
        if c.monthsunemployed > 0
            push!(additions, "Unemployed $(c.monthsunemployed) months. ")
        end

        if ! isempty(c.sick)
            push!(additions, "Illness: $(c.sick). ")
        end

        if c.blind
            push!(additions, "Blind. ")
        end

        if c.deaf_dumb
            push!(additions, "Deaf and mute. ")
        end

        if c.idiotic
            push!(additions, "'Idiotic'. ")
        end

        if c.insane
            push!(additions, "Insane. ")
        end

        if c.maimed
            push!(additions, "Maimed or disabled. ")
        end


        if c.attendedschool
            push!(additions, "Attended school. ")
        end

        if c.cannotread
            push!(additions, "Cannot read. ")
        end
        if c.cannotwrite
            push!(additions, "Cannot write. ")
        end

        basic * join(additions, "")
       
end

"""Parse a single 1880 census record from a row of delimited-text data.
$(SIGNATURES)
"""
function census1880(delimited, enumeration::Symbol; delimiter = "|")
    cols = split(delimited, delimiter)
    if length(cols) < 27
        @warn("Invalid number of columns in census record: $delimited")
        return nothing
    end
    # Extract the columns
    #Street|Dwelling|Surname|GivenName|Race|Gender|Age|BirthMonth|BirthYear|Relation|Marital|MarriedThisYear|Occupation|MonthsUnemployed|Sick|Blind|DeafDumb|Idiotic|Insane|Maimed|AttendedSchool|CannotRead|CannotWrite|Birthplace|FatherBirthPlace|MotherBirthPlace
    (rownumber, street, dwellingraw,
    surname, givenname,
    race, genderraw,
    ageraw, birthmonth, birthyearraw,
    relation, marital, marriedthisyearraw, 
    occupation, monthsunemployedraw, 
    sickraw, blindraw, deaf_dumbraw,
    idioticraw, insaneraw,
    maimedraw, attendedschoolraw,
    cannotreadraw, cannotwriteraw,
    birthplace, fatherbirthplace,
    motherbirthplace) = cols


    dwelling = try 
        parse(Int, dwellingraw)
    catch e
        @warn("Failed to parse dwelling: $dwellingraw")
        nothing
    end

    age = try 
        parse(Int, ageraw)
    catch e
        nothing
    end
    birthyear = try 
        parse(Int, replace(birthyearraw, "Abt " => ""))
    catch e
        nothing
    end
    gender = if isempty(genderraw)
        nothing
    else
            genderraw[1] in ['M', 'F'] ? genderraw[1] : nothing
    end
    #race = raceraw[1] in ['W', 'B', 'M', 'I', 'C'] ? raceraw[1] : nothing
   
    marriedthisyear = isempty(marriedthisyearraw) ? false : true
    attendedschool = isempty(attendedschoolraw) ? false : true
    cannotread = isempty(cannotreadraw) ? false : true
    cannotwrite = isempty(cannotwriteraw) ? false : true
    monthsunemployed = if isempty(monthsunemployedraw)
        0
    else
        try 
            parse(Int, monthsunemployedraw)
        catch e
            @warn("Failed to parse months unemployed: $monthsunemployedraw")
            nothing
        end
    end
    
  
    sick = sickraw
    blind = isempty(blindraw) ? false : true
    deaf_dumb = isempty(deaf_dumbraw) ? false : true
    idiotic = isempty(idioticraw) ? false : true
    insane = isempty(insaneraw) ? false : true
    maimed = isempty(maimedraw) ? false : true
    try
        #=
                (street, dwelling, surname, givenname, race, 
                gender, age, birthyear,relation, marital,
                marriedthisyear,occupation,
                monthsunemployed, sick,
                blind, deaf_dumb,
                idiotic, insane,
                maimed, attendedschool,
                cannotread, cannotwrite,
                birthplace, fatherbirthplace,
                motherbirthplace,  
                censuslabels[enumeration]
                )
=#

        Census1880(street, dwelling, 
        surname, givenname, 
        race, gender, age, birthyear,
        relation, marital,marriedthisyear,
        occupation, monthsunemployed, sick,
        blind, deaf_dumb,
        idiotic, insane,
        maimed, attendedschool,
        cannotread, cannotwrite,
        birthplace, fatherbirthplace,
        motherbirthplace,  
        censuslabels[enumeration]
        )

    catch e
        @warn("Failed to parse census record: $delimited")
        @warn("Error: $e")
        return nothing
    end

end


"""Download and parse the 1880 US Census data for a given enumeration and year.
$(SIGNATURES)
"""
function census1880table(enumeration::Symbol)
    # Read census data from a URL
    url = censusurl(enumeration, 1880)
    if isnothing(url)
        @warn("No URL found for enumeration: $enumeration and year: $year")
        return nothing
    end

    f = Downloads.download(url)
    data = readlines(f)[2:end]
    rm(f)
    # Parse each line into a Census1880 object
    records = [census1880(line, enumeration) for line in data if !isempty(line)]
    filter(rec -> ! isnothing(rec), records)
end