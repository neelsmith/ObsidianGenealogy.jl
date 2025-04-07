using ObsidianGenealogy, Obsidian 
using UUIDs


# Base indexing on 1880 records.
v1880 = census1880table(:vergennes)

people = map(v1880) do rec
   CensusPerson(
        rec.givenname,
        rec.surname,
        rec.birthyear,
        UUIDs.uuid4()
    )
end


