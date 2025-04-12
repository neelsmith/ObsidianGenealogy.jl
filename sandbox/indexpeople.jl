using ObsidianGenealogy, Obsidian 
using UUIDs
# Base indexing on 1880 records.
#enumlist = [
#    "Addison, Addison, Vermont",
#    "Bridport, Addison, Vermont",
#    "Ferrisburg, Addison, Vermont"
#]
#censuslabels
for district in [:addison, :bridport, :ferrisburg]
    label = ObsidianGenealogy.censuslabels[district]
    @info(label)
    records = census1880table(district)
    people = map(records) do rec
        CensusPerson(
             rec.givenname,
             rec.surname,
             rec.gender,
             rec.birthyear,
             UUIDs.uuid4()
         )
    end
    rawfile = string(district, "-raw.cex")
    open(rawfile, "w") do io
        write(io, join(delimited.(people), "\n") )
    end

end

