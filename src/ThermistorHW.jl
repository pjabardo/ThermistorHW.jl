
"""
    ThermistorHW

Cálculo de propriedades de termistores e sua aplicação em 
termo-anemometria.


"""
module THW

# package code goes here

export Thermistor, Resistor, resistance, temperature
export myhorner, IdealGas, AirType, Air, heatcond, viscosity, density, kinviscosity, specheat
export thermaldiff, prandtl, volthermalexpansion
export reynolds, nusphere, nucylinder, grashof, rayleigh, nuspherefree, hconvect, hconvectcyl
export Solid, Fe2O3, Fe₂O₃, const_current, const_temperature

abstract type AbstractSubstance end
abstract type AbstractFluid <: AbstractSubstance end
abstract type AbstractGas <: AbstractFluid end
abstract type AbstractIdealGas <: AbstractGas end

include("thermistor.jl")
include("air.jl")
include("solid.jl")
include("heattrans.jl")
include("anemometer.jl")

    
end # module


