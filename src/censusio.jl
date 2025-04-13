
censusurls = Dict(
    :addison1850 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Addison1850census.cex",
    :addison1880 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Addison1880census.cex",



    :bridport1850 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Bridport1850census.cex",
    :bridport1860 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Bridport1860census.cex",
    :bridport1880 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Bridport1880census.cex",

    :ferrisburg1850 =>"https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Ferrisburg1850census.cex",
    :ferrisburg1880 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Ferrisburg1880census.cex",


    :panton1850 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Panton1850census.cex",
    :panton1860 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Panton1860census.cex",
    :panton1870 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Panton1870census.cex",
    :panton1880 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Panton1880census.cex",



    :vergennes1850 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Vergennes1850census.cex",
    :vergennes1880 => "https://raw.githubusercontent.com/neelsmith/Vermont.jl/refs/heads/main/data/Vergennes1880census.cex",







)


censuslabels = Dict(
    :addison => "Addison, Addison, Vermont",
    :bridport => "Bridport, Addison, Vermont",
    :ferrisburg => "Ferrisburg, Addison, Vermont",
    :panton => "Panton, Addison, Vermont",
    :vergennes => "Vergennes, Addison, Vermont"
)


function censusurl(enumeration::Symbol, year::Int)
    if enumeration == :addison
        if year == 1880
            return censusurls[:addison1880]
        elseif year == 1850
            return censusurls[:addison1850]
        else
            @warn("No URL found for enumeration: $enumeration and year: $year")
            return nothing
        end
  
    elseif enumeration == :bridport
        if year == 1880
            return censusurls[:bridport1880]
        elseif year == 1850
            return censusurls[:bridport1850]
        elseif year == 1860
            return censusurls[:bridport1860]
        else
            @warn("No URL found for enumeration: $enumeration and year: $year")
            return nothing
        end
  
        
    elseif enumeration == :ferrisburg
        if year == 1850
            return censusurls[:ferrisburg1850]
        elseif year == 1880
            return censusurls[:ferrisburg1880]
        else
            @warn("No URL found for enumeration: $enumeration and year: $year")
            return nothing
        end
  
    elseif enumeration == :panton
        if year == 1880
            return censusurls[:panton1880]
        elseif year == 1850
            return censusurls[:panton1850]
        elseif year == 1860
            return censusurls[:panton1860]
        elseif year == 1870
            return censusurls[:panton1870]
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