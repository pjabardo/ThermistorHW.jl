
"""
    ThermistorHW

Cálculo de propriedades de termistores e sua aplicação em 
termo-anemometria.

O que é um termoanemômetro? 

O termoanemometro é um sensor que mede a velocidade de fluidos a partir da transferência de calor
de um elemento aquecido. Este módulo implementa funções e estrutura de dados que permitem
simular e projetar termoanemômetros, em particular, sensores que usam um termistor como 
elemento aquecido. 

O termistor é um dispositivo semicondutor cuja resistência varia de maneira acentuada 
com a temperatura, geralmente de maneira não linear. Em particular, os termistores NTC 
(negative temperature coefficient

ₒ
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


