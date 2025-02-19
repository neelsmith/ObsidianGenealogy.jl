
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

    pagelines = ["---","engine: julia", "---","","", "# $(person)", "", ""]

    push!(pagelines, "## Page automatically generated")




    


    pagetext = join(pagelines, "\n")

    open(dest, "w") do io
        write(io, pagetext)
    end
    
end