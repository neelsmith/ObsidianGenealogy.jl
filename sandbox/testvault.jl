using Obsidian, ObsidianGenealogy
using Markdown

vaultdir = "/Users/nsmith/Dropbox/_obsidian/family-history"
v = Vault(vaultdir)
v isa Vault


gv = genealogyVault(v)


deaths = deathrecords(gv)
births = birthrecords(gv)

dude = "Horatio Nelson White"

(path(gv.vault, dude) |> Obsidian.parsefile).body |> Markdown.parse
(path(gv.vault, "Horatio Nelson White death") |> Obsidian.parsefile).body |> Markdown.parse


####


destdir = "/Users/nsmith/Desktop/famhist/quart-personal/familyhistory/sources"