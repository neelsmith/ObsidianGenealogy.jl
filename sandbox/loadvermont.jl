using ObsidianGenealogy

districts = [:addison,:bridport, :ferrisburg, :panton, :vergennes]


data1850 = map(districts) do district
    cens = census1850table(district)
end 

vt1850 = vcat(data1850...)

data1870 = map(districts) do district
    cens = census1870table(district)
end 
vt1870 = vcat(data1870...)



data1880 = map(districts) do district
    cens = census1880table(district)
end 
vt1880 = vcat(data1880...)

vt19thc = vcat(vt1850, vt1870, vt1880)



