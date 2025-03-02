"""Recursively compose `index.qmd` files with lists of links for all directories beginning from `dir`.
$(SIGNATURES)
"""
function buildindexfiles(dir, outroot)
    #@info("Build index for $(outroot) from $(dir)")
    items = ["---", "engine: julia", "---", "", "# Index", ""]
    for name in readdir(dir)
        fullpath = joinpath(dir, name)
        if isdir(fullpath)
            @debug("Descend dir $(name) later...")
           
        elseif endswith(name, ".qmd") || endswith(name, ".md")
            if name != "index.qmd"
                @debug("index MD file $(name)")
                renamed = replace(replace(name, "_" => " "), r".q?md$" => "")
                target = replace(replace(name, r".q?md$" => ".html"), " " => "_")
                push!(items, string("- [$(renamed)](./$(target))"))
            end
        end
    end

    subdirs = []
    for name in readdir(dir)
        fullpath = joinpath(dir, name)
        outpath = joinpath(outroot, name)
        if isdir(fullpath)
            @debug("Descending dir $(name) later...")
            buildindexfiles(fullpath, outpath)
            push!(subdirs, name)
        end
    end
    
    if ! isempty(subdirs)
        push!(items, "\n")
        push!(items, "## Further documents\n\n")
        for dir in subdirs
            cleanname = replace(dir, " " => "_")
            push!(items, "- [$(dir)](./$(cleanname)/)")
        end
    end

    outdir = replace(outroot, " " => "_")
    indexfile = joinpath(outdir, "index.qmd")
    if ! isdir(outdir)
        mkdir(outdir)
    end
    open(indexfile,"w") do io
        write(io, join(items, "\n"))
    end
    @debug("Wrote $(indexfile)")
end


"""Export person records to Markdown, excluding records for living people.
$(SIGNATURES)
"""
function publicexport(gv::GenealogyVault, outdir)
    exported = 0
    for person in people(gv)
        @debug("Make page for $(person)")
        if deceased(gv, person)
            #@info("---")
            #@info("==> MAKE public page for $(person)")
            #@info("---")
            makepersonpage(gv, person,outdir)
            exported = exported + 1
        else
            placeholderpage(gv, person, outdir)
        end
    end
    @info("---")
    @info("==> EXPORTED $(exported) public pages")
    @info("---")
end

"""Export all person records to Markdown, including records for living people.
$(SIGNATURES)
"""
function privateexport(gv::GenealogyVault, outdir)
    for person in people(gv)
        @debug("Make page for $(person)")
        makepersonpage(gv, person,outdir)
    end
end


"""Compose index of persons by last name.
$(SIGNATURES)
"""
function lastnameindex(gv::GenealogyVault, outdir)
    #tags(gv.vault, "#lastname")
    pagelist = gv.vault.intags["#lastname"] |> sort
    destdir = joinpath(outdir,"last-names")
    if ! isdir(destdir)
        mkpath(destdir)
        @info("Created new directory $(destdir)")
    end
    for pg in pagelist
        pagetext = composenameindex(gv, pg)
        pagefile = joinpath(destdir, string(pg, ".qmd"))
        open(pagefile, "w") do io
            write(io, pagetext)
        end
    end


    indexheader = "---\nengine: julia\n---\n\n# Last names\n\n"
    indexpageitems = map(pagelist) do pg
        string("- [$(pg)](./$(pg).html)")
    end
    indexfile = joinpath(destdir, "index.qmd")
    #@info("INdex file is $(indexfile)")
    indexcontents = indexheader * join(indexpageitems,"\n")
    open(indexfile,"w") do io
        write(io, indexcontents)
    end

end


function composenameindex(gv::GenealogyVault, lastname)
    pagelines = ["---", "engine: julia", "---", ""]
    push!(pagelines, "# $(lastname)\n")
    
    if haskey(gv.vault.inlinks, lastname)
        for lnk in sort(gv.vault.inlinks[lastname])
            target = htmllinkedstring(gv, lastname, lnk)
            push!(pagelines, string("- ", target))
        end
    else
        push!(pagelines, "::: {.callout-caution}")
        push!(pagelines, "Index missing for $(lastname)")
        push!(pagelines, ":::")

    end

    join(pagelines, "\n")
end

"""Export a `GenealogyVault`.
$(SIGNATURES)
"""
function exportvault(genvault::GenealogyVault, outdir; publiconly = true)
    

    for img in images(genvault)
        exportmd(genvault.vault, img, outdir)   
    end

    for doc in documents(genvault)
        exportmd(genvault.vault, doc, outdir)   
    end
    
    if publiconly
        publicexport(genvault, outdir)
    else
        privateexport(genvault, outdir)
    end

    # add index of last names
    lastnameindex(genvault, outdir)

    # add indices to transcriptions:
    xcrsroot = joinpath(genvault.vault.root, "transcriptions")
    xcrsoutput = joinpath(outdir, "transcriptions")
    @warn("Add indices to $(xcrsoutput)")
    buildindexfiles(xcrsroot, xcrsoutput)
    
end


"""Format a page with privacy notice for person not identified as deceased.
$(SIGNATURES)
"""
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

"""Format a Markdown display of documentation for death of a person.
$(SIGNATURES)
"""
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

"""Format a Markdown display of documentation for parents of a person.
$(SIGNATURES)
"""
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

function checkdir(dest)
    destdir = dirname(dest)
    if ! isdir(destdir)
        mkpath(destdir)
        @info("Created new directory $(destdir)")
    end
    @debug("Dest is $(dest)")
end

function formatchildren(gv::GenealogyVault, person, spouse)
    pagelines = ["**Children with $(htmllinkedstring(gv, person, spouse))**:"]
    push!(pagelines, "\n")
    kids = childrecords(gv, person, dewikify(spouse))
    @debug("For $(person) and $(spouse), work with these kids $(kids)")
    for kid in kids
        item = string("- ", htmllinkedstring(gv, person, kid.name), "\n")
        push!(pagelines, item)
    end
    pagelines
end



function formatchildsources(gv::GenealogyVault, person, spouse)
    pagelines  = ["Sources for children with $(htmllinkedstring(gv, person, spouse))"]
    push!(pagelines, "\n")
    kids = childrecords(gv, person, dewikify(spouse))
    for rec in kids     
        item = string("- ", htmllinkedstring(gv, person, rec.source), "\n")
        push!(pagelines, item)
    end
    push!(pagelines, "\n")
    pagelines
end

function pageheader(person)
    pagelines = ["---","engine: julia", "---","","", ]
    push!(pagelines, "> *Page automatically generated.*")
    push!(pagelines, "")

    push!(pagelines,"# $(person)\n\n")
    pagelines
end

function outputfilename(gv, person, outputdir)
    srcpath = path(gv.vault, person; relative = true) 
    destfile = joinpath(outputdir, srcpath)
    qmd = replace(destfile, r".md$" => ".qmd")
    exportoutput = replace(qmd, " " => "_")
    checkdir(exportoutput)
    exportoutput
end

function embedancestordiagram(gv::GenealogyVault, person)
    pagelines = ["Documented ancestors:\n"]
    ancdiagram = ancestordiagram(gv, person) |> wrapmermaid
    for ln in split(ancdiagram, "\n")
        push!(pagelines, ln)
    end
    push!(pagelines, "\n")
    pagelines
end

function embeddescendantdiagram(gv::GenealogyVault, person)
    pagelines  = ["Documented descendants:\n"]
    descdiagram = descendantdiagram(gv, person) |> wrapmermaid
    for ln in split(descdiagram, "\n")
        push!(pagelines, ln)
    end
    push!(pagelines, "\n")
    pagelines
end

"""Compose a summary page of resources for a named person.
$(SIGNATURES)
"""
function makepersonpage(gv::GenealogyVault, person, outputdir)

    dest = outputfilename(gv, person, outputdir)
    pagelines = pageheader(person)

    basicdata = formatconclusions(gv, person)
    for ln in basicdata
        push!(pagelines, ln)
    end
    push!(pagelines, "")


    spice = partners(gv, person)
    if ! isempty(spice)
        for spouse in spice
            for childline in formatchildren(gv, person, spouse)    
                push!(pagelines, childline)
            end
        end
        push!(pagelines, "\n")
    end


    basics = conclusions(gv, person)
    if basics.father != "?" || basics.mother != "?"
        for ln in embedancestordiagram(gv, person)
            push!(pagelines, ln)
        end
    end

    if ! isempty(spice)
        for ln in embeddescendantdiagram(gv, person)
            push!(pagelines, ln)
        end
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
            for ln in formatchildsources(gv, person, spouse)
                push!(pagelines, ln)
            end
        end
    end


    pagetext = join(pagelines, "\n")
    open(dest, "w") do io
        write(io, pagetext)
    end 
 
    @info("Wrote page to $(dest)")  
end
