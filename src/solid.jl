struct Solid <: AbstractSubstance
    ρ::Float64
    cₚ::Float64
    k::Float64
    
end

const Fe2O3 = Solid(3e3, 650.0, 0.58)

thermaldiff(x::Substance) = x.k / (x.ρ*x.cₚ)
density(x::Substance) = x.ρ
specheat(x::Substance) = x.cₚ
thermalcond(x::Substance) = x.k


