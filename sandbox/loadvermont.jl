using ObsidianGenealogy

districts = [:addison,:bridport, :ferrisburg, :panton, :vergennes]


data1850 = map(districts) do district
    cens = census1850table(district)
end 

vt1850 = vcaxt(data1850...)


data1880 = map(districts) do district
    cens = census1880table(district)
end 
vt1880 = vcat(data1880...)