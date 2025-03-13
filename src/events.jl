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


function plotevents(v::Vector{LifeEvent}; minlatextent = 0.1, minlonextent = 0.1, padding = 0.1,
    ptsize = 50, ptmarker = :xcross
    )
    #plotlocations(map(ev -> ev.location, v))
    eventstoplot = filter(ev -> ! isnothing(ev.location), v)
    locstoplot = map(ev -> ev.location, eventstoplot)
    plotlocations(locstoplot; minlatextent = minlatextent, minlonextent = minlonextent, padding = padding, 
    ptsize = ptsize, ptmarker = ptmarker, ptcolor)
end


pointcolors = Dict(
    :burial => :red,
    :birth => :green
)
pointmarkers = Dict(
    :burial =>  '✝',
    :birth => :circle
)