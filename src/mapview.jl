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
        loc = triple.value
        lat = typeof(loc[1]) <: Number ? loc[1] : parse(Float64, strip(loc[1]))
        lon = typeof(loc[2]) <: Number ? loc[2] : parse(Float64, strip(loc[2]))
        PointLocation(triple.wikiname, lat, lon)
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



#const esriworld = TileProviders.Esri(:WorldImagery)

function getbasemap(v::Vector{PointLocation};
    minlatextent = 0.02, minlonextent = 0.02, padding = 0.01)
    provider = TileProviders.Esri(:WorldImagery);
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
    fig = Figure(; size = (1200,600))
    ax = Axis(fig[1,1])
    m = Tyler.Map(ext; provider, figure=fig, axis=ax);

    @info("Returning rendered map")
    m
end


function plotlocations2(v::Vector{PointLocation};
    minlatextent = 0.02, minlonextent = 0.02, padding = 0.01)
    provider = TileProviders.Esri(:WorldImagery);
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
    fig = Figure(; size = (1200,600))
    ax = Axis(fig[1,1])

    for loc in v
        pts = Point2f(MapTiles.project((loc.lon, loc.lat), MapTiles.wgs84, MapTiles.web_mercator))
        objscatter = scatter!(ax, pts; color = :red,
        marker = '⭐', markersize = 10)
    end




    m = Tyler.Map(ext; provider, figure=fig, axis=ax);

    hidespines!(m.axis)
    hidedecorations!(m.axis)
    m
end

function plotlocations(v::Vector{PointLocation};
    minlatextent = 0.02, minlonextent = 0.02, padding = 0.01)
    #=
    provider = TileProviders.Esri(:WorldImagery);
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
    fig = Figure(; size = (1200,600))
    ax = Axis(fig[1,1])
    m = Tyler.Map(ext; provider, figure=fig, axis=ax);

    hidespines!(m.axis)
    hidedecorations!(m.axis)
=#
    finalmap = getbasemap(v; 
        minlatextent = minlatextent, minlonextent = minlonextent, padding = padding)

    for loc in v
        pts = Point2f(MapTiles.project((loc.lon, loc.lat), MapTiles.wgs84, MapTiles.web_mercator))
        objscatter = scatter!(finalmap.axis, pts; color = :red,
        marker = '⭐', markersize = 10)
    end

    hidespines!(finalmap.axis)
    hidedecorations!(finalmap.axis)
    
    finalmap
end
