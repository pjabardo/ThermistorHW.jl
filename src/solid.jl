
"""
   Solid(ρ, cₚ, k)

Propriedades termodinâmicas de sólidos
"""
struct Solid <: AbstractSubstance
    "Massa específica em kg/m³"
    ρ::Float64
    "Calor específico em J/kg.K"
    cₚ::Float64
    "Condutividade térmica W/m.K"
    k::Float64
end

"Óxido de ferro. Usado nos termistores NTC (?)"
const Fe2O3 = Solid(3e3, 650.0, 0.58)

"""
    thermaldiff(x::AbstractSubstance)

Difusividade térmica em m²/s
"""
thermaldiff(x::AbstractSubstance) = x.k / (x.ρ*x.cₚ)

"""
    densidade(x::AbstractSubstance)

Densidade em kg/m³
"""
density(x::AbstractSubstance) = x.ρ

"""
    specheat(x::AbstractSubstance)

Calor específico em J/kg.K 
"""
specheat(x::AbstractSubstance) = x.cₚ

"""
    thermalcond(x::AbstractSubstance)

Condutividade térmica em W/m.K
"""
thermalcond(x::AbstractSubstance) = x.k

"Óxido de ferro. Usado nos termistores NTC (?)"
const Fe₂O₃ = Solid(5242.0, 650.6, 0.58)


