
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


function genealogyVault(f)
    Vault(f) |> GenealogyVault
end

function genealogyVault(v::Vault; docs = "transcriptions", people = "people")
    GenealogyVault(v, docs, people)
end

function documents(gv::GenealogyVault)
    filenames = values(gv.vault.filemap) |> collect
    relativepaths = map(f -> replace(f, gv.vault.root * "/" => ""), filenames)
    docs = filter(f -> startswith(f, gv.documents), relativepaths)
end


function people(gv::GenealogyVault)
    filenames = values(gv.vault.filemap) |> collect
    relativepaths = map(f -> replace(f, gv.vault.root * "/" => ""), filenames)
    docs = filter(f -> startswith(f, gv.people), relativepaths)
end