using Obsidian, ObsidianGenealogy
using Markdown

# Publish public:
destdir = "/Users/nsmith/Desktop/family-site/quart-personal/familyhistory/sources"
# Publish private:
privatedest = "/Users/nsmith/Dropbox/_current_projects/_genealogy/_privateexport/familyhistory/sources"

vaultdir = "/Users/nsmith/Dropbox/_obsidian/family-history"

gv = Vault(vaultdir) |> genealogyVault
exportvault(gv, destdir)


exportvault(gv, privatedest; publiconly = false)

