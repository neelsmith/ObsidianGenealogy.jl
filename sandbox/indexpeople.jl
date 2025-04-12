using ObsidianGenealogy, Obsidian 
using UUIDs

for district in [:addison, :bridport, :ferrisburg, :panton, :vergennes]
    label = ObsidianGenealogy.censuslabels[district]
    @info(label)
    records = census1880table(district)
    people = map(records) do rec
        cperson = CensusPerson(
             rec.givenname,
             rec.surname,
             rec.gender,
             rec.birthyear,
             UUIDs.uuid4()
         )
         string(delimited(cperson), "|$(label)|$(rec.page)|$(rec.line)")
    end
    rawfile = string(district, "-raw.cex")
    open(rawfile,"w") do io
        write(io, join(people, "\n"))
    end
end

