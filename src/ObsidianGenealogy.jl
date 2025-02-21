module ObsidianGenealogy

import Base: show

using Obsidian
using Documenter, DocStringExtensions




include("vault.jl")
include("utils.jl")
include("conclusions.jl")
include("nuclearfamily.jl")
include("evidence.jl")
include("diagrams.jl")
include("export.jl")



export GenealogyVault, genealogyVault
export documents, people

export birthrecords, deathrecords
export parentrecords, childrecords, partners
export father, mother

export noteson, vitals
export conclusions

export exportvault

export wikify, dewikify

export ancestordiagram, descendantdiagram

end # module ObsidianGenealogy
