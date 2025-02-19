

function father(gv::GenealogyVault)
    tripls = gv.vault |> kvtriples
    fathers = filter(tripls) do t
        t.key == "father"
    end 

    fatherstructure.(fathers)
end

function father(gv::GenealogyVault, person)
    #filter(t ->  father(gv))
end


function fatherstructure(note::NoteKV)
    split(note.value, "|")
end