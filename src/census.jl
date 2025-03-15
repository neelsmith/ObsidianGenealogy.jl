
censustags = [
    "#census/1790census",
    "#census/1800census",
    "#census/1810census",
    "#census/1820census",
    "#census/1830census",
    "#census/1840census",
    "#census/1850census",
    "#census/1850census2",
    "#census/1860census",
    "#census/1870census",
    "#census/1880census",
    "#census/1890census",
    "#census/1900census",   
    "#census/1910census",
    "#census/1920census",
    "#census/1930census",
    "#census/1940census",
    "#census/1945census"
]

"""Collect all census records in a genealogy vault.
$(SIGNATURES)
"""
function uscensusnotes(gv::GenealogyVault)
    map(censustags) do tag
        if haskey(gv.vault.intags, tag)
            gv.vault.intags[tag]
        else
            []
        end
    end |> Iterators.flatten |> collect
end


"""Construact a `LifeEvent` from a census note.
$(SIGNATURES)
"""
function uscensusevent(gv::GenealogyVault, trip::NoteKV)
    recordeddate = date(gv, trip)
    dateval = recordeddate isa Date ? recordeddate : nothing
    @debug("Event from $(trip)")    
    
    wikiname = trip.wikiname
    caption = "Census event: " * wikiname
    person = dewikify(trip.value)
    role = :census



    @debug("Get location for $(wikiname)")
    location = addresslocation(gv, wikiname) #nothing
    @debug("Got $(location) ($(typeof(location)))")
    #addr = address(gv, trip)
    LifeEvent(wikiname, caption, person, role, dateval, location, "")
end



"""Collect all census events for a person.
$(SIGNATURES)
"""
function uscensusevents(gv::GenealogyVault, person)
    trips = uscensusnotes(gv, person)
    map(trips) do trip
        uscensusevent(gv, trip)
    end
end


"""Collect all census notes for a person.
$(SIGNATURES)
"""
function uscensusnotes(gv::GenealogyVault, person)
    triplelist = filter(kvtriples(gv.vault)) do tr
        tr.key == "refersto"  && tr.value == wikify(person) &&
        tr.wikiname in uscensusnotes(gv)
    end
end

"""True if note is a census record.
$(SIGNATURES)
"""
function iscensusnote(gv, note)
    note in uscensusnotes(gv)
end




#####################################################################
### Get specific data from census note:
#
#
##
# Enumeration:
##
"""Find census enumeration from a census event.
$(SIGNATURES)
"""
function enumeration(gv::GenealogyVault, censusevt::LifeEvent)
    enumeration(gv, censusevt.wikiname)
end

"""Find census enumeration from the census note in a key-value triple.
$(SIGNATURES)
"""
function enumeration(gv::GenealogyVault, censustriple::NoteKV)
    enumeration(gv, censustriple.wikiname)
end

"""Find the census enumeration for a named census note.
$(SIGNATURES)
"""
function enumeration(gv::GenealogyVault, censusnote::AbstractString)
    matches = filter(kvtriples(gv.vault)) do tr
       tr.wikiname == censusnote && tr.key == "Enumeration" #"Ebenezer White 1850 census"
    end
    isempty(matches) ? nothing : dewikify(matches[1].value)
end


##
# Date:
##


"""Find census date from a census event.
$(SIGNATURES)
"""
function date(gv::GenealogyVault, censusevt::LifeEvent)
    date(gv, censusevt.wikiname)
end

"""Find census date from the census note in a key-value triple.
$(SIGNATURES)
"""
function date(gv::GenealogyVault, censustriple::NoteKV)
    date(gv, censustriple.wikiname)
end

"""Find the census date for a named census note.
$(SIGNATURES)
"""
function date(gv::GenealogyVault, censusnote)
    
    matches = filter(kvtriples(gv.vault)) do tr
       tr.wikiname == censusnote && tr.key == "Date" #"Ebenezer White 1850 census"
    end
    if isempty(matches)
        nothing
    else
        stringdate =  matches[1].value
        try 
            dateval = Date(stringdate)
        catch e
            stringdate
        end
    end
end




##
# Address:
##


#=
function address(gv::GenealogyVault, censusevt::LifeEvent)
    #address(gv, censusevt.wikiname) 
end


function address(gv::GenealogyVault, censusnote::NoteKV)
    address(gv, censusnote.wikiname) 
end
=#



"""Find the census address for a named census note.
$(SIGNATURES)
"""
function address(gv::GenealogyVault, censusnote::AbstractString)
    
    matches = filter(kvtriples(gv.vault)) do tr
       tr.wikiname == censusnote && tr.key == "address"
    end
    if isempty(matches) 
        @debug("Use enumeration if no address")
        enumeration(gv, censusnote)
    else 
        addr = dewikify(matches[1].value)
    end
end


"""Find geographic location for a census record's address value.
If a specific address is not record, try using the enmeration as a proxy.
$(SIGNATURES)
"""
function addresslocation(gv::GenealogyVault, censusnote::AbstractString)
    addr = address(gv, censusnote)
    @debug("Addr for $(censusnote) is $(addr)")
    locc = location(gv, addr)
    if isempty(locc)
        @debug("No location for $(addr): try proxy")
        proxylocc = filter(t -> t.wikiname == addr && t.key == "proxylocation", kvtriples(gv.vault))
        @debug("Proxies $(proxylocc)")
        if isempty(proxylocc)
            @warn("No proxy location for $(addr)")
            nothing
        else
            @debug("Get location for $(dewikify(proxylocc[1].value))")
            proxypoints = location(gv, dewikify(proxylocc[1].value))
            @debug("Type = $(typeof(proxypoints))")
            proxypoints[1]
        end


    else
        # Found address!
        locc[1]
    end
end