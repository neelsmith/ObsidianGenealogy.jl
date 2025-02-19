module ObsidianGenealogy

import Base: show

using Obsidian
using Documenter, DocStringExtensions

include("vault.jl")
include("vitals.jl")
include("conclusions.jl")
include("export.jl")


export GenealogyVault, genealogyVault
export documents, people

export birthrecords, deathrecords
export parentrecords

export noteson, vitals

export exportvault

end # module ObsidianGenealogy
