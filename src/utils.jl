

function wikify(s)
    Obsidian.iswikilink(s) ? s : string("[[", s, "]]")
end

function dewikify(s)
    replace(s, r"[\[\]]" => "")
end