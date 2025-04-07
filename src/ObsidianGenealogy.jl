module ObsidianGenealogy

import Base: show



using Obsidian
using Documenter, DocStringExtensions
using Dates
using UUIDs
using Downloads

using Tyler
using Tyler.TileProviders
using Tyler.Extents
using Tyler.MapTiles
using CairoMakie

include("vault.jl")
include("utils.jl")
include("claims.jl")
include("nuclearfamily.jl")
include("conclusions.jl")
include("diagrams.jl")
include("export.jl")




export GenealogyVault, genealogyVault
export documents, people, images

export kvtriples
export birthrecords, deathrecords
export parentrecords, childrecords, partners
export father, mother

export noteson, vitals, sources

export evidenceforbirth, evidencefordeath
export evidenceformother, evidenceforfather, evidenceforchild
export hasconclusions, conclusions, evidenceforconclusion, validconclusion
export invalidconclusions

export exportvault

export wikify, dewikify

export ancestordiagram, descendantdiagram

include("mapview.jl")
export PointLocation
export locations, limits, location
export plotlocations

include("events.jl")
export LifeEvent
export lifeevents
export births, birth
export deaths, death
export burials, burial
export plotevents
export plotlife
export timeline


include("censusvault.jl")
export uscensusnotes, uscensusevents
export address, enumeration, date,addresslocation

include("censusio.jl")
include("censustables.jl")
include("censuses/census1850.jl")
export Census1850, census1850, census1850table
include("censuses/census1880.jl")
export Census1880, census1880, census1880table



export givenname, surname, gender, race, occupation,  birthplace, birthyear
export dwelling, family

export sickness, monthsunemployed
export maritalstatus, relation

export hohlist

export readable


include("censuspeople.jl")
export CensusPerson
export matchingrecords

end # module ObsidianGenealogy
