
censusurls = Dict(
    :ferrisburg1850 =>"https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Ferrisburg1850census.cex",


    :vergennes1850 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Vergennes1850census.cex",
    :vergennes1880 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Vergennes1880census.cex",


    :panton1880 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Panton1880census.cex"
)


censuslabels = Dict(
    :ferrisburg => "Ferrisburg, Addison, Vermont",
    :panton => "Panton, Addison, Vermont",
    :vergennes => "Vergennes, Addison, Vermont"
)


function censusurl(enumeration::Symbol, year::Int)

    if enumeration == :ferrisburg
        if year == 1850
            return censusurls[:ferrisburg1850]
        else
            @warn("No URL found for enumeration: $enumeration and year: $year")
            return nothing
        end
  
    elseif enumeration == :panton
        if year == 1880
            return censusurls[:panton1880]
        else
            @warn("No URL found for enumeration: $enumeration and year: $year")
            return nothing
        end

    elseif enumeration == :vergennes
        if year == 1850
            return censusurls[:vergennes1850]
        elseif year == 1880
            return censusurls[:vergennes1880]
        else
            @warn("No URL found for enumeration: $enumeration and year: $year")
            return nothing
        end        


        
    else
        @warn("No URL found for enumeration: $enumeration and year: $(year)")
        return nothing
    end
end