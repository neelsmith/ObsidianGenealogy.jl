abstract type CensusRecord end

function enumeration(rec::T) where T <: CensusRecord
    @warn("enumeration is not implemented for $(typeof(rec))")
    return nothing
 end

 function page(rec::T) where T <: CensusRecord
    @warn("page is not implemented for $(typeof(rec))")
    return nothing
 end


 function line(rec::T) where T <: CensusRecord
    @warn("line is not implemented for $(typeof(rec))")
    return nothing
 end


function dwelling(rec::T) where T <: CensusRecord
    @warn("dwelling is not implemented for $(typeof(rec))")
    return nothing
 end
function family(rec::T) where T <: CensusRecord
   @warn("family is not implemented for $(typeof(rec))")
   return nothing
end

"""Catch all for dispatch of CensusRecord types.
$(SIGNATURES)
"""
function givenname(rec::T) where T <: CensusRecord
   @warn("givenname is not implemented for $(typeof(rec))")
   return nothing
end

function surname(rec::T) where T <: CensusRecord
    @warn("surname is not implemented for $(typeof(rec))")
    return nothing
 end


function birthyear(rec::T) where T <: CensusRecord
   @warn("birthyear is not implemented for $(typeof(rec))")
   return nothing
end 

function birthplace(rec::T) where T <: CensusRecord
    @warn("birthplace is not implemented for $(typeof(rec))")
    return nothing
 end 

function gender(rec::T) where T <: CensusRecord
    @warn("gender is not implemented for $(typeof(rec))")
    return nothing
end

function race(rec::T) where T <: CensusRecord
    @warn("race is not implemented for $(typeof(rec))")
    return nothing
end
function occupation(rec::T) where T <: CensusRecord
    @warn("occupation is not implemented for $(typeof(rec))")
    return nothing
end

function hohlist(reclist::Vector{T}) where T <: CensusRecord
    @warn("hoh is not implemented for $(typeof(reclist))")
    return nothing
end

