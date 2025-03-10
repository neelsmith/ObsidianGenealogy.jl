
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