
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
