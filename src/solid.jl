
"""
    Thermodynamic properties of solids
"""
struct Solid <: AbstractSubstance
    ρ::Float64
    cₚ::Float64
    k::Float64
end

const Fe2O3 = Solid(3e3, 650.0, 0.58)

thermaldiff(x::AbstractSubstance) = x.k / (x.ρ*x.cₚ)
density(x::AbstractSubstance) = x.ρ
specheat(x::AbstractSubstance) = x.cₚ
thermalcond(x::AbstractSubstance) = x.k


