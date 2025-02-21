function htmllink(gv::GenealogyVault, n1, n2)
    htmllink(gv.vault, n1, n2)
end
function htmllink(v::Vault, n1, n2)
    relative = Obsidian.relativelink(v, n1, n2)
    @debug("Link from $(n1) to $(n2) is:")
    @debug(relative)
    if isnothing(relative)
        ""
    else
        relative = replace(relative, r"^\.\./" => "./")
        nospace = replace(relative, " " => "_")
        replace(nospace, r".md$" => ".html")
    end
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


function hasconclusions(record)
    noconclusions = record.birth == "?" && 
    record.death  == "?" &&
    record.mother  == "?" &&
    record.father  == "?"

    ! noconclusions
end

function formatconclusions(gv::GenealogyVault, person)
    tpl = conclusions(gv, person)
    #motherrel = Obsidian.relativelink(gv.vault, person, tpl.mother)
    motherrel = htmllink(gv.vault, person, tpl.mother)
    @debug("So link to mother is $(motherrel)")
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


function formatdeathsources(gv, person)
    pagelines = []
    deathsrcs = deathrecords(gv, person)
    push!(pagelines, "| Date | Source | Type |")
    push!(pagelines, "| --- | --- | --- |")
    for tpl in deathsrcs

        sourcewikiname = replace(tpl.source,r"[\[\]]" => "")
        #sourcerel  = Obsidian.relativelink(gv.vault, person, sourcewikiname)
        sourcerel  = htmllink(gv.vault, person, sourcewikiname)
        sourcelink = string("[", sourcewikiname, "](", sourcerel, ")")
        push!(pagelines, "| $(tpl.date) | $(sourcelink) | $(tpl.sourcetype) |")
    end
    pagelines
end


function formatparentsources(gv, person)
    pagelines = []
    
   
    parentsrcs = parentrecords(gv, person)
    push!(pagelines, "| Father | Mother | Source | Type |")
    push!(pagelines, "| --- | --- | --- | --- |")
    for tpl in parentsrcs

        sourcewikiname = replace(tpl.source,r"[\[\]]" => "")
        sourcerel  = htmllink(gv.vault, person, sourcewikiname)
        sourcelink = string("[", sourcewikiname, "](", sourcerel, ")")


        fatherwikiname = replace(tpl.father,r"[\[\]]" => "")
        fatherrel = htmllink(gv.vault, person, fatherwikiname)
        fatherlink =  string("[", fatherwikiname, "](", fatherrel, ")")

        motherwikiname = replace(tpl.mother,r"[\[\]]" => "")
        motherrel = htmllink(gv.vault, person, motherwikiname)
        motherlink =  string("[", motherwikiname, "](", motherrel, ")")

        push!(pagelines, "| $(fatherlink) | $(motherlink) | $(sourcelink) | $(tpl.sourcetype) |")
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
    basicdata = formatconclusions(gv, person)
    for ln in basicdata
        push!(pagelines, ln)
    end
    push!(pagelines, "")


   
    basics = conclusions(gv, person)
    
    if hasconclusions(basics)
        push!(pagelines, "## Sources")
    end
    if basics.birth != "?"
        push!(pagelines, "Sources for birth:\n\n")
        for ln in formatbirthsources(gv, person)
            push!(pagelines, ln)
       end
       push!(pagelines, "")
    end
    if basics.death != "?"
        push!(pagelines, "Sources for death:\n\n")
        for ln in formatdeathsources(gv, person)
            push!(pagelines, ln)
       end
       push!(pagelines, "")
    end
    
    if basics.father != "?" || basics.mother != "?"
        push!(pagelines, "## Sources for parents:\n\n")
        for ln in formatparentsources(gv, person)
            push!(pagelines, ln)
       end
       push!(pagelines, "")
    end
    

    children = map(rec -> rec.name, childrecords(gv, person))
    

    


    pagetext = join(pagelines, "\n")

    open(dest, "w") do io
        write(io, pagetext)
    end   
end
