module ObsidianGenealogy

import Base: show

using Obsidian
using Documenter, DocStringExtensions
using Dates

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


include("census.jl")
export uscensusnotes, uscensusevents
export address, enumeration, date,addresslocation
end # module ObsidianGenealogy
