function htmllink(v::Vault, n1, n2)
    relative = Obsidian.relativelink(v, n1, n2)
    nospace = replace(relative, " " => "_")
    replace(nospace, r".md$" => ".html")
end

"""Export a `GenealogyVault`.
$(SIGNATURES)
"""
function exportvault(genvault::GenealogyVault, outdir)
   
    for doc in documents(genvault)
        exportmd(genvault.vault, doc, outdir)   
    end
    
    for person in people(genvault)
        @debug("Make page for $(person)")
        makepersonpage(genvault, person,outdir)
    end
    
end


function formatvitals(gv::GenealogyVault, person)
    tpl = vitals(gv, person)
    #motherrel = Obsidian.relativelink(gv.vault, person, tpl.mother)
    motherrel = htmllink(gv.vault, person, tpl.mother)
    motherlink = string("[", tpl.mother, "](", motherrel, ")")

    #fatherrel = Obsidian.relativelink(gv.vault, person, tpl.father)
    fatherrel = htmllink(gv.vault, person, tpl.father)
    fatherlink = string("[", tpl.father, "](", fatherrel, ")")

    [   
        "*born* $(tpl.birth) : *died* $(tpl.death)",
        "",
        "**Mother**: $(motherlink)",
        "",
        "**Father**: $(fatherlink)"
    ]
end

function formatbirthsources(gv, person)
    pagelines = []
    push!(pagelines, "## Sources for birth\n\n")
    birthsrcs = birthrecords(gv, person)
    push!(pagelines, "| Date | Source | Type |")
    push!(pagelines, "| --- | --- | --- |")
    for tpl in birthsrcs

        sourcewikiname = replace(tpl.source,r"[\[\]]" => "")
        #sourcerel  = Obsidian.relativelink(gv.vault, person, sourcewikiname)
        sourcerel  = htmllink(gv.vault, person, sourcewikiname)
        sourcelink = string("[", sourcewikiname, "](", sourcerel, ")")
        push!(pagelines, "| $(tpl.date) | $(sourcelink) | $(tpl.sourcetype) |")
    end
    pagelines
end


"""Compose a summary page of resources for a named person.
$(SIGNATURES)
"""
function makepersonpage(gv::GenealogyVault, person, outputdir)

    srcpath = path(gv.vault, person; relative = true) 
    @debug("Source path is $(srcpath)")
    dest = joinpath(outputdir, srcpath)
    @debug("Yielding $(dest)")
    
    qmd = replace(dest, r".md$" => ".qmd")
    dest = replace(qmd, " " => "_")
    destdir = dirname(dest)
    if ! isdir(destdir)
        mkpath(destdir)
    end
    @debug("Dest is $(dest)")

    pagelines = ["---","engine: julia", "---","","", ]

    push!(pagelines, "> *Page automatically generated.*")
    push!(pagelines, "")
    push!(pagelines,"# $(person)\n\n")#, "", ""   
    basicdata = formatvitals(gv, person)
    for ln in basicdata
        push!(pagelines, ln)
    end
    push!(pagelines, "")

    basics = vitals(gv, person)
    
    if basics.birth != "?"
        for ln in formatbirthsources(gv, person)
            push!(pagelines, ln)
       end
    end
    push!(pagelines, "")

    


    pagetext = join(pagelines, "\n")

    open(dest, "w") do io
        write(io, pagetext)
    end
    
end