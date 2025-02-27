module ObsidianGenealogy

import Base: show

using Obsidian
using Documenter, DocStringExtensions




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

export noteson, vitals

export evidenceforbirth, evidencefordeath
export evidenceformother, evidenceforfather, evidenceforchild
export hasconclusions, conclusions, evidenceforconclusion, validconclusion
export invalidconclusions

export exportvault

export wikify, dewikify

export ancestordiagram, descendantdiagram

end # module ObsidianGenealogy
