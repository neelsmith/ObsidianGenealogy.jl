

function wikify(s)
    Obsidian.iswikilink(s) ? s : string("[[", s, "]]")
end

function dewikify(s)
    replace(s, r"[\[\]]" => "")
end


function htmllink(gv::GenealogyVault, n1, n2)
    htmllink(gv.vault, n1, n2)
end

function htmllink(v::Vault, n1, n2)
    relative = Obsidian.relativelink(v, dewikify(n1), dewikify(n2))
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


function htmllinkedstring(gv::GenealogyVault, n1, n2)
    htmllinkedstring(gv.vault, n1, n2)
end

"""
$(SIGNATURES)
"""
function htmllinkedstring(v::Vault, n1, n2)
    string("[",dewikify(n2),"](", htmllink(v, n1, n2), ")")
end