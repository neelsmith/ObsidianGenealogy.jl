
function locations(gv::GenealogyVault)
    triplelist = filter(trip -> trip.key == "location" && (! isnothing(trip.value)), kvtriples(gv.vault))

    map(triplelist) do triple
        loc = triple.value

        lat = typeof(loc[1]) <: Number ? loc[1] : parse(Float64, strip(loc[1]))
        lon = typeof(loc[2]) <: Number ? loc[2] : parse(Float64, strip(loc[2]))
        #lat = parse(Float64, loc[1])
        #lon = parse(Float64, loc[2])
        #@info("Type of loc 1 $(typeof(loc[1]))")
        #triple.wikiname
        (wikiname = triple.wikiname, lat = lat, lon = lon)
    end
        
end


"""Create a bounding box for a vector of points.
$(SIGNATURES)
"""
function limits(locs; padding = 0.1)
    maxlat = map(locs) do tpl
        tpl.lat
    end |> maximum
    maxlon = map(locs) do tpl
        tpl.lon
    end |> maximum


    minlat = map(locs) do tpl
        tpl.lat
    end |> minimum
    minlon = map(locs) do tpl
        tpl.lon
    end |> minimum        

    ((minlon, maxlon), (minlat, maxlat))

end