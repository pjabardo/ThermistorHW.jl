
"Constante universal dos gases em J / (kmol.K)"
const ℜ = 8314.472 #472 # Universal gas constant

"""
    myhorner(x, a, n)

Usa o método de Horner ara calcular o valor do polinômio
`y = a[1] + a[2]*x + a[3]*x^2 + ... + a[n]*x^(n-1)`

# Examples
```jldoctest
julia> a = [1, 2, 3];

julia> myhorner(0, a, 3)
1

julia> myhorner(1, a, 3)
6

julia> myhorner(2, a, 3)
17
```
"""
function myhorner(x, a, n)
    p = one(x) * a[n]
    
    for i = (n-1):-1:1
        p = muladd(x,p,a[i])
    end
    return p
end

"""
    IdealGas

Armazena um gás perfeito.
"""
struct IdealGas <: AbstractIdealGas
    "Massa molecular em kg/kmol"
    M::Float64
    "Coeficientes de polinômio representando o calor específico a pressão constante"
    cpcoefs::Vector{Float64}
end

"""
 Singleton to calculate Air properties.
"""
struct AirType <: AbstractIdealGas
end

"Massa molecular do Ar seco em kg/kmol"
const Mair = 28.9647 #kg/kmol

"Constante do gas para o ar"
const Rair = ℜ/Mair

"Constante representando o ar"
const Air = AirType()


"""
    heatcond(Air, 20.0)

Calcula a condutividade do ar em W/m.K

# Examples
```jldoctest
julia> heatcond(Air, 0.0)
0.02413198631696768

julia> heatcond(Air, 20.0)
0.025723538599749837

julia> heatcond(Air, 50.0)
0.028063733135454103
```
"""
function heatcond(Air::AirType, Tc=20.0)
    T = Tc + 273.15
    @evalpoly(T, 5.890e-02, 9.542e-02, -2.397e-05, -1.126e-08, 4.853e-12) * 1e-3
end

"""
    viscosity(Air, Tc)

Calcula a viscosidade dinâmica do ar em Pa.s usando a equação de Sutherland.

# Examples
```jldoctest
julia> viscosity(Air, 0.0)
1.7362296862138683e-5

julia> viscosity(Air, 20.0)
1.8369221075668256e-5

julia> viscosity(Air, 50.0)
1.982070679101198e-5
```
"""
function viscosity(Air::AirType, Tc)
    T = Tc + 273.15
    C = 120.0
    T₀ = 291.15
    μ₀ = 18.27e-6
    return μ₀ * (T₀ + C) / (T + C) * ( T/T₀ )^1.5
end

"""
    density(gas, Tc, Pk)

Calcula a densidade do ar em kg/m³ admitindo que o ar seja um gás perfeito. A temperatura `Tc` deve ser em °C e a pressão deve ser em kPa.

"""
function density(gas::IdealGas, Tc=20.0, Pk=101.325)
    return Pk*1000 * gas.M / (ℜ * (Tc + 273.15))
end

"""
    density(Air, Tc, Pk)

Calcula a densidade do ar em kg/m³ admitindo que o ar seja um gás perfeito. A temperatura `Tc` deve ser em °C e a pressão deve ser em kPa.

# Examples
```jldoctest
julia> density(Air, 0.0, 101.325)
1.2922595999236681

julia> density(Air, 20.0, 101.325)
1.2040958885183353

julia> density(Air, 20.0, 93)
1.105165730394327
```
"""
function density(Air::AirType, Tc=20.0, Pk=101.325)
    return Pk*1000 / (Rair * (Tc + 273.15))
end

"""
    kinviscosity(Air, Tc, Pk)

Calcula a viscosidade cinemática em m²/s do ar usando a equação de Sutherland.

# Examples
```jldoctest
julia> kinviscosity(Air, 20.0, 101.325)
1.5255613154091872e-5

julia> kinviscosity(Air, 0.0, 101.325)
1.3435610664578733e-5

julia> kinviscosity(Air, 20.0, 93)
1.6621236589659775e-5
```
"""
function kinviscosity(Air::AirType, Tc=20.0, P=101.325)
    return viscosity(Air, Tc) / density(Air, Tc, P)
end

"""
    specheat(Air, Tc)

Calcula o calor específico a pressão constante do ar em J/kg.K.

# Examples
```jldoctest
julia> specheat(Air, 0)
1003.6206378797417

julia> specheat(Air, 20)
1004.5273968591591
```
"""
function specheat(Air::AirType, Tc=20.0)
    T = Tc + 273.15
    return @evalpoly(T, 3.56839620E+00, -6.78729429E-04, 1.55371476E-06, -3.29937060E-12, -4.66395387E-13) * Rair  #, -1.06234659E+03,  3.71582965E+00) * Rair
end

"""
    thermaldiff(Air, Tc, Pk)

Calcula a difusividade térmica do ar seco em m²/s:

```math
α = k/(ρ.cₚ)
```

```jldoctest
julia> thermaldiff(Air, 0.0, 101.325)
1.8606886990841108e-5

julia> thermaldiff(Air, 20.0, 101.325)
2.1267079360835945e-5

julia> thermaldiff(Air, 20.0, 93)
2.3170825981039807e-5
```
"""
thermaldiff(Air::AirType, Tc=20.0, Pk=101.325) = heatcond(Air, Tc) / (density(Air, Tc, Pk) * specheat(Air, Tc))


"""
    prandtl(Air, Tc)

Número de Prandtl para o ar seco:

```math
Pr = ν/α = cₚμ/k
```

```jldoctest
julia> prandtl(Air, 0.0)
0.7220772970348109

julia> prandtl(Air, 20.0)
0.7173346605451432
```
"""
prandtl(Air::AirType, Tc=20.0) = viscosity(Air, Tc) * specheat(Air, Tc) / heatcond(Air, Tc)

"""
    volthermalexpansion(gas::AbstractIdealGas, Tc)

Coeficiente de expansão volumétrica em 1/K.
"""
volthermalexpansion(gas::AbstractIdealGas, Tc) = 1/(Tc + 273.15)

