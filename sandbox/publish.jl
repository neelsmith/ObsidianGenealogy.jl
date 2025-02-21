using Obsidian, ObsidianGenealogy
using Markdown

vaultdir = "/Users/nsmith/Dropbox/_obsidian/family-history"
gv = Vault(vaultdir) |> genealogyVault

# Choose one:
# Mac mini:
destdir = "/Users/nsmith/Desktop/famhist/quart-personal/familyhistory/sources"
# Laptop:
#destdir = "/Users/nsmith/Desktop/family-site/quart-personal/familyhistory/sources"


# Publish public:
exportvault(gv, destdir)

#privatedest = joinpath(pwd(), "scratch", "privateexport")
privatedest = "/Users/nsmith/Dropbox/_current_projects/_genealogy/_privateexport"
exportvault(gv, privatedest; publiconly = false)