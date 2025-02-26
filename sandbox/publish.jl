using Obsidian, ObsidianGenealogy
using Markdown

# To publish public:
destdir = "/Users/nsmith/Desktop/family-site/quart-personal/familyhistory/sources"
# To publish private:
privatedest = "/Users/nsmith/Dropbox/_current_projects/_genealogy/_privateexport/familyhistory/sources"

vaultdir = "/Users/nsmith/Dropbox/_obsidian/family-history"

gv = Vault(vaultdir) |> genealogyVault

# Publish public data:
exportvault(gv, destdir)

# Publish all including private:
exportvault(gv, privatedest; publiconly = false)

