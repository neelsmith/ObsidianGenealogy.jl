

struct Census1880 <: CensusRecord
    #Street|Dwelling|Surname|GivenName|Race|Gender|Age|BirthMonth|BirthYear|Relation|Marital|MarriedThisYear|Occupation|MonthsUnemployed|Sick|Blind|DeafDumb|Idiotic|Insane|Maimed|AttendedSchool|CannotRead|CannotWrite|Birthplace|FatherBirthPlace|MotherBirthPlace
    street::String
    dwelling::Int
    surname::String
    givenname::String
    race::Union{Char, Nothing}
    gender::Union{Char, Nothing}
    age::Int 
    birthyear::Int
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
    raceraw, genderraw,
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
    gender = genderraw[1] in ['M', 'F'] ? genderraw[1] : nothing
    race = raceraw[1] in ['W', 'B', 'M', 'I', 'C'] ? raceraw[1] : nothing
   
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
                )=#



      
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

function census1880table()
end
