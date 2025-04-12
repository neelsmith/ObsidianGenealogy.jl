using ObsidianGenealogy, Obsidian 
using UUIDs


# Base indexing on 1880 records.
v1880 = census1880table(:vergennes)

people = map(v1880) do rec
   CensusPerson(
        rec.givenname,
        rec.surname,
        rec.gender,
        rec.birthyear,
        UUIDs.uuid4()
    )
end

vermontdir = joinpath(dirname(pwd()), "Vermont.jl")
f = joinpath(vermontdir, "data", "vermonters.cex")

isfile(f)

folks = CensusPerson[]
for ln in readlines(f)[2:end]
    (givenname, surname, gender, yearraw, id) = split(ln, "|")
    birthyear = try
        parse(Int,yearraw)
    catch
        @warn("Couldn't parse year from $(yearraw)")
        nothing
    end
    push!(folks, CensusPerson(givenname, surname, gender[1], birthyear, UUID(id)))
end