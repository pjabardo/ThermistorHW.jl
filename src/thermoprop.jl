

abstract type ThermoProp end

abstract type Viscosity <: ThermoProp end

struct Sutherland <: Viscosity
    C::Float64
    T₀::Float64
    μ₀::Float64
end

viscosity(v::Sutherland, T) = v.μ₀ * (v.T₀ + v.C) / (T + v.C) * (T/v.T₀)^1.5
viscosity(v::Sutherland) = viscosity(v, 293.15)

ViscosityTable = Dict{Symbol, Sutherland}()


ViscosityTable[:Air] = Sutherland(120.0, 291.15, 18.27e-6)
ViscosityTable[:N2] = Sutherland(111.0, 300.55, 17.81e-6)
ViscosityTable[:O2] = Sutherland(127.0, 292.25, 20.18e-6)
ViscosityTable[:CO2] = Sutherland(240.0, 293.15, 14.8e-6)
ViscosityTable[:CO] = Sutherland(118.0, 288.15, 17.2e-6)
ViscosityTable[:H2] = Sutherland(72.0, 293.85, 8.76e-6)
ViscosityTable[:NH3] = Sutherland(370.0, 293.15, 9.82e-6)
ViscosityTable[:SO2] = Sutherland(416.0, 293.65, 12.54e-6)
ViscosityTable[:He] = Sutherland(79.4, 273.0, 19.0e-6)


viscosity(gas::Symbol) = viscosity(ViscosityTable[gas])
viscosity(gas::Symbol, T) = viscosity(ViscosityTable[gas], T)


const ℜ = 8314.459848
const Patm = 101_325.0

