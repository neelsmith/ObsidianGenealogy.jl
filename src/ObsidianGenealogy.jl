module ObsidianGenealogy

import Base: show

using Obsidian
using Documenter, DocStringExtensions

include("vault.jl")

export GenealogyVault, genealogyVault
export documents, people
export birthrecords, deathrecords
export parentrecords

end # module ObsidianGenealogy
