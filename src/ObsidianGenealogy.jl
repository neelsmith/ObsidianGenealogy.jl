module ObsidianGenealogy

import Base: show

using Obsidian
using Documenter, DocStringExtensions

include("vault.jl")
include("conclusions.jl")
include("nuclearfamily.jl")
include("evidence.jl")
include("export.jl")


export GenealogyVault, genealogyVault
export documents, people

export birthrecords, deathrecords
export parentrecords, childrecords

export noteson, vitals

export exportvault

end # module ObsidianGenealogy
