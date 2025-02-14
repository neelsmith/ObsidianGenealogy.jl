
struct GenealogyVault
    vault::Vault
    documents
    people

    function GenealogyVault(v::Vault, docs, folks)
        if ! isdir(joinpath(v.root, docs))
            throw(ArgumentError("No directory for documents at path $(joinpath(v.root, docs)) "))
        elseif  ! isdir(joinpath(v.root, folks))
            throw(ArgumentError("No directory for people at path $(joinpath(v.root, docs)) "))
        else
            new(v, docs, folks)
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
function genealogyVault(dir::AbstractString; docs = "transcriptions", people = "people")
    GenealogyVault(Vault(dir), docs, people)
end



"""Construct a `GenealogyVault` from an Obsidian `Vault`.
$(SIGNATURES)
"""
function genealogyVault(v::Vault;  docs = "transcriptions", people = "people")
    GenealogyVault(v, docs, people)
end


"""Collect list of transcribed documents in a geneaological Obsidian vault.
$(SIGNATURES)
"""
function documents(gv::GenealogyVault)
    filenames = values(gv.vault.filemap) |> collect
    relativepaths = map(f -> replace(f, gv.vault.root * "/" => ""), filenames)
    docs = filter(f -> startswith(f, gv.documents), relativepaths)
end

"""Collect list of people in a geneaological Obsidian vault.
$(SIGNATURES)
"""
function people(gv::GenealogyVault)
    filenames = values(gv.vault.filemap) |> collect
    relativepaths = map(f -> replace(f, gv.vault.root * "/" => ""), filenames)
    docs = filter(f -> startswith(f, gv.people), relativepaths)
end


function birthrecords(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    births = filter(tripls) do t
        t.key == "birth"
    end 

    birthstructure.(births)
end

function birthstructure(note::NoteKV)
    split(note.value, "|")
end


function deathrecords(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    deaths = filter(tripls) do t
        t.key == "death"
    end 

    deathstructure.(deaths)
end

function deathstructure(note::NoteKV)
    split(note.value, "|")
end


function parentrecords(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    parents = filter(tripls) do t
        t.key == "parents"
    end 

    parentstructure.(parents)
end

function parentstructure(note::NoteKV)
    split(note.value, "|")
end