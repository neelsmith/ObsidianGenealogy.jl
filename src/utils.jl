

"""True if string s consists only of whitespace characters.
$(SIGNATURES)
"""
function allwhitespace(s)
    wsre = r"^[\s]*$"
    # Result of nothing on regex match means no match.
    # We want true if there IS a match so:
    ! isnothing(match(wsre, s))
end


"""True if string s has non-whitespace content and is not equal to `"?"`.
$(SIGNATURES)
"""
function hasdata(s)
    isnothing(s) == false &&
    isempty(s) == false &&
    allwhitespace(s) == false &&
    (s == "?") == false
end

function wikify(s)
    @debug("wikify $(s)")
    Obsidian.iswikilink(s) ? s : string("[[", s, "]]")
end

function dewikify(s)
    
    replaced = replace(s, r"[\[\]]" => "")
    @debug("Dewikify $(s) to $(replaced)")
    replaced
end


function htmllink(gv::GenealogyVault, n1, n2)
    htmllink(gv.vault, n1, n2)
end

function htmllink(v::Vault, n1, n2)
    @debug("Link nodes $(n1) and $(n2)")
    @debug("n2 is #$(n2)#")
    if isempty(n2)
        n1
    else
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