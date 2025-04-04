
censusurls = Dict(
    :ferrisburg1850 =>"https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Ferrisburg1850census.cex"
)


censuslabels = Dict(
    :ferrisburg => "Ferrisburg, Addison, Vermont"
)


function censusurl(enumeration::Symbol, year::Int)

    if enumeration == :ferrisburg
        if year == 1850
            return censusurls[:ferrisburg1850]
        else
            @warn("No URL found for enumeration: $enumeration and year: $year")
            return nothing
        end
  


        
    else
        @warn("No URL found for enumeration: $enumeration")
        return nothing
    end
end