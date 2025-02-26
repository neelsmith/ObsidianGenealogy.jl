
"""An Obsidian vault with genealogical data.
"""
struct GenealogyVault
    vault::Vault
    documents
    people
    images

    """Validate parameters before instantiating a vault."""
    function GenealogyVault(v::Vault, docs, folks, imgs)
        if ! isdir(joinpath(v.root, docs))
            throw(ArgumentError("No directory for documents at path $(joinpath(v.root, docs)) "))
        elseif  ! isdir(joinpath(v.root, folks))
            throw(ArgumentError("No directory for people at path $(joinpath(v.root, docs)) "))
        elseif ! isdir(joinpath(v.root, imgs))
            throw(ArgumentError("No directory for images at path $(joinpath(v.root, imgs)) "))
        else
            new(v, docs, folks, imgs)
        end
    end
end

"""Override Base.show for `GenealogyVault`.
$(SIGNATURES)
"""
function show(io::IO, v::GenealogyVault)
    count = wikinames(v.vault) |> length
    suffix = count == 1 ? "" : "s"
    str = string("Genealogical Obsidian vault with $count note$suffix" )
    show(io,str)
end

"""Construct a `GenealogyVault` from a directory name.
$(SIGNATURES)
"""
function genealogyVault(dir::AbstractString; docs = "transcriptions", people = "people", imgs = "images")
    GenealogyVault(Vault(dir), docs, people, imgs)
end

"""Construct a `GenealogyVault` from an Obsidian `Vault`.
$(SIGNATURES)
"""
function genealogyVault(v::Vault;  docs = "transcriptions", people = "people", imgs = "images")
    GenealogyVault(v, docs, people, imgs)
end

"""Collect list of transcribed documents in a geneaological Obsidian vault.
$(SIGNATURES)
"""
function documents(gv::GenealogyVault)
    filenames = values(gv.vault.filemap) |> collect
    relativepaths = map(f -> replace(f, gv.vault.root * "/" => ""), filenames)
    docpaths = filter(f -> startswith(f, gv.documents), relativepaths)
    map(doc -> replace(basename(doc), r".md$" => ""), docpaths)
end

"""Collect list of people in a geneaological Obsidian vault.
$(SIGNATURES)
"""
function people(gv::GenealogyVault)
    filenames = values(gv.vault.filemap) |> collect
    relativepaths = map(f -> replace(f, gv.vault.root * "/" => ""), filenames)
    docpaths = filter(f -> startswith(f, gv.people), relativepaths)
    map(doc -> replace(basename(doc), r".md$" => ""), docpaths)
end



"""Collect list of images in a geneaological Obsidian vault.
$(SIGNATURES)
"""
function images(gv::GenealogyVault)
    filenames = values(gv.vault.filemap) |> collect
    relativepaths = map(f -> replace(f, gv.vault.root * "/" => ""), filenames)
    docpaths = filter(f -> startswith(f, gv.images), relativepaths)
    map(doc -> replace(basename(doc), r".md$" => ""), docpaths)
end





"""Find triples for all claims identifying a father.
$(SIGNATURES)
"""
function fatherlist(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    fathers = filter(tripls) do t
        t.key == "father"
    end 

    fatherstructure.(fathers)
end



"""Find triples for all claims identifying a mother.
$(SIGNATURES)
"""
function motherlist(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    mothers = filter(tripls) do t
        t.key == "mother"
    end 

    motherstructure.(mothers)
end



"""Find all key-value notes on a given person.
$(SIGNATURES)
"""
function noteson(gv::GenealogyVault, person)
    tripls = gv.vault |> kvtriples
    filter(t -> t.wikiname == person, tripls) 
end