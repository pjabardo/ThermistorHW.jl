module THW

# package code goes here


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


