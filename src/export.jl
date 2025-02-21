

"""Export a `GenealogyVault`.
$(SIGNATURES)
"""
function exportvault(genvault::GenealogyVault, outdir)
   
    for doc in documents(genvault)
        exportmd(genvault.vault, doc, outdir)   
    end
    
    for person in people(genvault)
        @debug("Make page for $(person)")
        if deceased(genvault, person)
            makepersonpage(genvault, person,outdir)
        else
            placeholderpage(genvault, person, outdir)
        end
    end
    
end

function placeholderpage(gv, person, outputdir)
    srcpath = path(gv.vault, person; relative = true) 
    dest = joinpath(outputdir, srcpath)

    qmd = replace(dest, r".md$" => ".qmd")
    dest = replace(qmd, " " => "_")
    destdir = dirname(dest)
    if ! isdir(destdir)
        mkpath(destdir)
    end
    @debug("Dest is $(dest)")

    pagelines = ["---","engine: julia", "---","","", ]


    push!(pagelines,"# $(person)\n\n")
    push!(pagelines, "\n")
    push!(pagelines, "Private information: $(person) not identified as deceased.")
    pagetext = join(pagelines, "\n")

    open(dest, "w") do io
        write(io, pagetext)
    end 
end


"""Format a Markdown display of documented conclusions for a person.
$(SIGNATURES)
"""
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


"""Format a Markdown display of documentation of birth for a person.
$(SIGNATURES)
"""
function formatbirthsources(gv, person)
    pagelines = []
    birthsrcs = birthrecords(gv, person)
    push!(pagelines, "| Date | Source | Place | Type |")
    push!(pagelines, "| --- | --- | --- | --- |")
    for tpl in birthsrcs

        sourcewikiname = dewikify(tpl.source) #replace(tpl.source,r"[\[\]]" => "")
        #sourcerel  = Obsidian.relativelink(gv.vault, person, sourcewikiname)
        sourcerel  = htmllink(gv.vault, person, sourcewikiname)
        sourcelink = string("[", sourcewikiname, "](", sourcerel, ")")
        push!(pagelines, "| $(tpl.date) | $(tpl.place) | $(sourcelink) | $(tpl.sourcetype) |")
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
    dest = joinpath(outputdir, srcpath)

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


    spice = partners(gv, person)
    if ! isempty(spice)
        for spouse in spice
            
            push!(pagelines, "**Children with $(htmllinkedstring(gv, person, spouse))**:")
            push!(pagelines, "\n")
            kids = childrecords(gv, person, dewikify(spouse))
            @debug("For $(person) and $(spouse), work with these kids $(kids)")
            for kid in kids
                item = string("- ", htmllinkedstring(gv, person, kid.name), "\n")
                push!(pagelines, item)
            end
        end
        push!(pagelines, "\n")
    end



    basics = conclusions(gv, person)

    if basics.father != "?" || basics.mother != "?"
        push!(pagelines, "Documented ancestors:\n")
        ancdiagram = ancestordiagram(gv, person) |> wrapmermaid
        for ln in split(ancdiagram, "\n")
            push!(pagelines, ln)
        end
        push!(pagelines, "\n")
    end
   
    if ! isempty(spice)
        push!(pagelines, "Documented descendants:\n")
        descdiagram = descendantdiagram(gv, person) |> wrapmermaid
        for ln in split(descdiagram, "\n")
            push!(pagelines, ln)
        end
        push!(pagelines, "\n")
    end
    
    
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
        push!(pagelines, "Sources for parents:\n\n")
        for ln in formatparentsources(gv, person)
            push!(pagelines, ln)
       end
       push!(pagelines, "")
    end
    

    if ! isempty(spice)
        
        for spouse in spice
            push!(pagelines, "Sources for children with $(htmllinkedstring(gv, person, spouse))")
            push!(pagelines, "\n")
            kids = childrecords(gv, person, dewikify(spouse))
            for rec in kids     
                item = string("- ", htmllinkedstring(gv, person, rec.source), "\n")
                push!(pagelines, item)
            end
            push!(pagelines, "\n")
        end
    end

    


    pagetext = join(pagelines, "\n")

    open(dest, "w") do io
        write(io, pagetext)
    end   
end
