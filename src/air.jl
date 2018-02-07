

const ℜ = 8314.472 #472 # Universal gas constant

function myhorner(x, a, n)
    p = one(x) * a[n]
    
    for i = (n-1):-1:1
        p = muladd(x,p,a[i])
    end
    return p
end

struct IdealGas <: AbstractIdealGas
    M::Float64
    cpcoefs::Vector{Float64}
end

"""
 Singleton to calculate Air properties.
"""
struct AirType <: AbstractIdealGas
end

const Mair = 28.9647 #kg/kmol
const Rair = ℜ/Mair
const Air = AirType()


"""
Calculates the heat conductivity of air.
"""
function heatcond(Air::AirType, Tc=20.0)
    T = Tc + 273.15
    @evalpoly(T, 5.890e-02, 9.542e-02, -2.397e-05, -1.126e-08, 4.853e-12) * 1e-3
end

"""
Calculates the dynamic viscosity of air using Sutherland's equation
"""
function viscosity(Air::AirType, Tc)
    T = Tc + 273.15
    C = 120.0
    T₀ = 291.15
    μ₀ = 18.27e-6
    return μ₀ * (T₀ + C) / (T + C) * ( T/T₀ )^1.5
end

"""
Calculates the density of an ideal gas
"""
function density(gas::IdealGas, Tc=20.0, Pk=101.325)
    return Pk*1000 * gas.M / (ℜ * (Tc + 273.15))
end

"""
Calculates the density of air
"""
function density(Air::AirType, Tc=20.0, Pk=101.325)
    return Pk*1000 / (Rair * (Tc + 273.15))
end

"""
Kinematic viscosity of air
"""
function kinviscosity(Air::AirType, Tc=20.0, P=101.325)
    return viscosity(Air, Tc) / density(Air, Tc, P)
end

"""
Specific heat at constant pressure of air
"""
function specheat(Air::AirType, Tc=20.0)
    T = Tc + 273.15
    return @evalpoly(T, 3.56839620E+00, -6.78729429E-04, 1.55371476E-06, -3.29937060E-12, -4.66395387E-13) * Rair  #, -1.06234659E+03,  3.71582965E+00) * Rair
end

"""
Thermal diffusivity of air
"""
thermaldiff(Air::AirType, Tc=20.0, Pk=101.325) = heatcond(Air, Tc) / (density(Air, Tc, Pk) * specheat(Air, Tc))


"""
Prandtl number of air
"""
prandtl(Air::AirType, Tc=20.0) = viscosity(Air, Tc) * specheat(Air, Tc) / heatcond(Air, Tc)


volthermalexpansion(gas::AbstractIdealGas, Tc) = 1/(Tc + 273.15)

