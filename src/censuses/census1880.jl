

struct Census1850 <: CensusRecord
    #Street|Dwelling|Surname|GivenName|Race|Gender|Age|BirthMonth|BirthYear|Relation|Marital|MarriedThisYear|Occupation|MonthsUnemployed|Sick|Blind|DeafDumb|Idiotic|Insane|Maimed|AttendedSchool|CannotRead|CannotWrite|Birthplace|FatherBirthPlace|MotherBirthPlace
    street::String
    dwelling::Int
    surname::String
    givenname::String
    race::Union{Char, Nothing}
    gender::Union{Char, Nothing}
    age::Int 
    birthmonth::String
    birthyear::Int
    relation::String
    marital::String
    marriedthisyear::Bool    
    occupation::String
    monthsunemployed::Int
    sick::Bool
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

function census1880()
end

function census1880table()
end
