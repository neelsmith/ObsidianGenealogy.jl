"""A typed event in the life of an individual.
$(SIGNATURES)
"""
struct LifeEvent
    wikiname
    caption
    person
    role::Symbol
    date::Union{Date, Nothing}
    location::Union{PointLocation, Nothing}

    predicate
end


function lifeevents(gv, person)
    eventlist = vcat(
        birth(gv, person),
        uscensusevents(gv, person),
        death(gv, person),
        burial(gv,person)
    )
    filter(ev -> ! isnothing(ev), eventlist)
end


function death(gv, person)
    filter(ev -> ev.person == dewikify(person), deaths(gv))
end


"""Construct a `LifeEvent` from a death record.
$(SIGNATURES)
"""
function deathevent(gv, deathrec)
    wikiname = "Death of $(dewikify(deathrec.name))"
    caption = "Death of $(dewikify(deathrec.name))"
    person = dewikify(deathrec.name)
    role = :death

    datewords = split(deathrec.date, " ")
    deathdate = try
        datewords[end] |> Date
    catch err
        @warn("Could note parse date $(deathrec.date) for $(deathrec.name)")
        nothing
    end

    placematches = filter(locations(gv)) do loc
        loc.wikiname == dewikify(deathrec.place)
    end

    location = isempty(placematches) ? nothing : placematches[1]
    LifeEvent(wikiname, caption, person, role, deathdate, location,"")
end


"""Collect all death events in a genealogy vault.
$(SIGNATURES)
"""
function deaths(gv::GenealogyVault)
    map(rec -> deathevent(gv, rec), deathrecords(gv))
end



"""Construct a `LifeEvent` from a birth record.
$(SIGNATURES)
"""
function birthevent(gv, birthrec)
    wikiname = "Birth of $(dewikify(birthrec.name))"
    caption = "Birth of $(dewikify(birthrec.name))"
    person = dewikify(birthrec.name)
    role = :birth

    datewords = split(birthrec.date, " ")
    birthdate = try
        datewords[end] |> Date
    catch err
        @warn("Could note parse date $(birthrec.date) for $(birthrec.name) in birth record $(birthrec)")
        nothing
    end

    placematches = filter(locations(gv)) do loc
        loc.wikiname == dewikify(birthrec.place)
    end

    location = isempty(placematches) ? nothing : placematches[1]
    LifeEvent(wikiname, caption, person, role, birthdate, location,"")
end




function birth(gv, person)
    filter(ev -> ev.person == dewikify(person), births(gv))
end

"""Collect all birth events in a genealogy vault.
$(SIGNATURES)
"""
function births(gv::GenealogyVault)
    map(rec -> birthevent(gv, rec), birthrecords(gv))
end


"""Compile all burial events in a genealogy vault.
$(SIGNATURES)
"""
function burials(gv::GenealogyVault)
    burialslist = filter(trip -> trip.key == "burial" && (! isnothing(trip.value)), kvtriples(gv.vault))
    locc = locations(gv)
    map(burialslist) do triple
        person = dewikify(triple.wikiname)
        wikiterm = "Burial of $(person)"
        caption = "Event: burial of $(person)"
        burialdate = nothing # Need a way to capture this
        cemetery = dewikify(triple.value)
        locmatches = filter(loc -> loc.wikiname == cemetery, locc)
        loc = isempty(locmatches) ? nothing : locmatches[1]
        LifeEvent(wikiterm, caption, person,  :burial, burialdate, loc, "")
    end
end

"""Find the burial event for a person.
$(SIGNATURES)
"""
function burial(gv::GenealogyVault, person)
    records = filter(record -> record.person == dewikify(person), burials(gv))
    isempty(records) ? nothing : records[1]
end



pointcolors = Dict(
    :burial => :red,
    :death => :red,
    :birth => :green,
    :residence => :purple,
    :census => :blue
)

pointmarkers = Dict(
    :burial =>  '✝',
    :birth => '⊙',
    :death => '⨁',
    :residence => '⧇',
    :census => '⭒'
)


pointsize = Dict(
    :burial => 20,
    :birth => 20,
    :death => 10,
    :residence => 15,
    :census => 20
)
function plotevents(v::Vector{LifeEvent}; minlatextent = 0.1, minlonextent = 0.1, padding = 0.1,
    ptsize = 50, ptmarker = :xcross, ptcolor= :green
    )
    eventstoplot = filter(ev -> ! isnothing(ev.location), v)
    locstoplot = map(ev -> ev.location, eventstoplot)
    plotlocations(locstoplot; minlatextent = minlatextent, minlonextent = minlonextent, padding = padding, 
    ptsize = ptsize, ptmarker = ptmarker, ptcolor)
end

function plotlife(gv, person; 
    minlatextent = 0.02, 
    minlonextent = 0.02, padding = 0.01, 
    ptsize = 20)

    provider = TileProviders.Esri(:WorldGrayCanvas);
    #provider = TileProviders.CartoDB()

    events = filter(ev -> !isnothing(ev.location), lifeevents(gv, person))
    @info("Events for $(person): $(events)")
    eventlocc = map(ev -> ev.location, events)
    locs = filter(loc -> ! isnothing(loc), eventlocc)
    lims = limits(locs)
    
    (x1, x2) = lims[:X]
    (y1, y2) = lims[:Y]
    #if (x2 - x1) < minlonextent
        x1 -= padding
        x2 += padding
    #end
    #if (y2 - y1) < minlatextent
        y1 -= padding
        y2 += padding
    #end
    ext = Extent(X = (x1, x2), Y = (y1, y2))
    @info("Plot locations padded by $(padding) yields limits $(ext) ")


    fig = Figure(; size = (800,600))
    ax = Axis(fig[1,1])
    m = Tyler.Map(ext; provider, figure=fig, axis=ax);
    wait(m)
    hidespines!(m.axis)
    hidedecorations!(m.axis)


    for ev in filter(ev -> ! isnothing(ev.location), events)
        @info("Plotting $(ev.caption) ...")
        pts = Point2f(MapTiles.project((ev.location.lon, ev.location.lat), MapTiles.wgs84, MapTiles.web_mercator))
        objscatter = scatter!(m.axis, pts; color = pointcolors[ev.role],
        marker = pointmarkers[ev.role], markersize = pointsize[ev.role])
    end
   
    fig
end


"""Compile a list of dated events for a person, sorted by date.
$(SIGNATURES)
"""
function timeline(gv, person)
    events = filter(lifeevents(gv, person)) do ev
        ! isnothing(ev.date)
    end

    sort!(events, by = ev -> ev.date)
    for ev in events
        @info("$(ev.date) $(ev.caption)")
    end
end