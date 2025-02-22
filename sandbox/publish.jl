using Obsidian, ObsidianGenealogy
using Markdown

vaultdir = "/Users/nsmith/Dropbox/_obsidian/family-history"
gv = Vault(vaultdir) |> genealogyVault

# Publish public:
destdir = "/Users/nsmith/Desktop/family-site/quart-personal/familyhistory/sources"

exportvault(gv, destdir)

# Publish private:
privatedest = "/Users/nsmith/Dropbox/_current_projects/_genealogy/_privateexport/familyhistory/sources"

exportvault(gv, privatedest; publiconly = false)