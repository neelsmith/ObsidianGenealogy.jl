
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

function noteson(gv::GenealogyVault, person)
    tripls = gv.vault |> kvtriples
    filter(t -> t.wikiname == person, tripls) 
end


function vitals(gv::GenealogyVault, person)
    allnotes = noteson(gv, person)
    birthlist = filter(n -> n.key == "birthdate", allnotes)
    deathlist = filter(n -> n.key == "deathdate", allnotes)
    motherlist =  filter(n -> n.key == "mother", allnotes)
    fatherlist =  filter(n -> n.key == "father", allnotes)

    birth = isempty(birthlist) ? "?" : birthlist[1].value
    death = isempty(deathlist) ? "?" : deathlist[1].value
    mother = "?"
    father = "?"


    ## THIS HTML CONVERSION DOES NOT BELONG HERE>
    if ! isempty(motherlist)
        motherwikilink = motherlist[1].value
        mother = replace(motherwikilink, r"[\[\]]" => "")
        #mother = Obsidian.relativelink(gv.vault, person, motherwiki)
    end
    if ! isempty(fatherlist)
        fatherwikilink = fatherlist[1].value
        father = replace(fatherwikilink, r"[\[\]]" => "")
        #father = Obsidian.relativelink(gv.vault, person, fatherwiki)
    end
    
    (birth = birth, death = death, mother = mother, father = father)
end