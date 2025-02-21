module ObsidianGenealogy

import Base: show

using Obsidian
using Documenter, DocStringExtensions




include("vault.jl")
include("utils.jl")
include("conclusions.jl")
include("nuclearfamily.jl")
include("evidence.jl")
include("export.jl")


export GenealogyVault, genealogyVault
export documents, people

export birthrecords, deathrecords
export parentrecords, childrecords, partners

export noteson, vitals
export conclusions

export exportvault

export wikify, dewikify

end # module ObsidianGenealogy
