"""A tagged location with longitude and latitude.
$(SIGNATURES)
"""
struct PointLocation
    wikiname
    lat
    lon
end


"""Collect all tagged point locations in a vault.
$(SIGNATURES)
"""
function locations(gv::GenealogyVault)
    triplelist = filter(trip -> trip.key == "location" && (! isnothing(trip.value)), kvtriples(gv.vault))
    map(triplelist) do triple
        loc = triple.value isa String ? split(triple.value, ",") : triple.value

 
        @debug("TRIPLE $(triple)")
        #loc = dewikify(triple.value)
        @debug("LOC? $(loc) type $(typeof(loc))")

        lat = typeof(loc[1]) <: Number ? loc[1] : parse(Float64, strip(loc[1]))
        lon = typeof(loc[2]) <: Number ? loc[2] : parse(Float64, strip(loc[2]))
        PointLocation(triple.wikiname, lat, lon)
    end      
end

"""Find a tagged point location in a vault.
$(SIGNATURES)
"""
function location(gv, wikiname)
    locs = locations(gv)
    filter(locs) do loc
        loc.wikiname == wikiname
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
    Extent(X = (minlon, maxlon), Y = (minlat, maxlat))
end


"""Create a Makie figure with a plot of points.
$(SIGNATURES)
"""
function plotlocations(v::Vector{PointLocation};
    minlatextent = 0.02, minlonextent = 0.02, padding = 0.01, 
    ptsize = 50, ptmarker = :xcross, ptcolor = :green)

    provider = TileProviders.Esri(:WorldGrayCanvas);
    lims = limits(v)
    
    (x1, x2) = lims[:X]
    (y1, y2) = lims[:Y]
    if (x2 - x1) < minlonextent
        x1 -= padding
        x2 += padding
    end
    if (y2 - y1) < minlatextent
        y1 -= padding
        y2 += padding
    end
   

    
    ext = Extent(X = (x1, x2), Y = (y1, y2))
    @info("Plot locations with padded limits $(ext) ")
    fig = Figure(; size = (800,600))
    ax = Axis(fig[1,1])
    m = Tyler.Map(ext; provider, figure=fig, axis=ax);
    wait(m)
    hidespines!(m.axis)
    hidedecorations!(m.axis)



    for loc in v
        pts = Point2f(MapTiles.project((loc.lon, loc.lat), MapTiles.wgs84, MapTiles.web_mercator))
        objscatter = scatter!(m.axis, pts; color = ptcolor,
        marker = ptmarker, markersize = ptsize)
    end
    
    fig
end
