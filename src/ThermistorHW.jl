module THW

# package code goes here

abstract type Resistance end

"""
Models a NTC Thermistor
===================

In this model, the resistance obeys the following equation:

$$
R = R₀ \exp\left(\frac{1}{T₀} - \frac{1}{T}\right)
$$

where 
 * R₀ is the resistance at temperature T₀
 * T₀ is the reference temperature in K, usually 293.15 K
 * T is the temperature in K for which the resistance should be calculated
 * B empirical coefficient that models the behavior of the thermistor, unit 1/K
"""
struct Thermistor <: Resistance
    "resistance at temperature T₀"
    R₀::Float64
    "Empirical coefficient that models the behavior of the thermistor, unit 1/K"
    B::Float64
    "Reference temperature in K"
    T₀::Float64
    Thermistor(R₀=5e3, B=0.0, T₀=20.0) = new(R₀, B, T₀+273.15)
end

"""
Calculates the resistance of a thermistor
=========================================

If the temperature is not provided, this function returns the reference resistance
"""
resistance(th::Thermistor) = th.R₀ 
resistance(th::Thermistor, T) = th.R₀ * exp( -th.B * (1/th.T₀ - 1/(T+273.15) ) )

"""
Uses the call interface to compute the resistance 

"""
(th::Thermistor)(T) = resistance(th, T)
(th::Thermistor)() = th.R₀

"""
Given a resistance, compute the temperature of the thermistor.

If resistance is not provided, the reference temperature is returned.
"""
temperature(th::Thermistor) = th.T₀
temperature(th::Thermistor, R) = 1/( 1/th.T₀ + 1/th.B * log(R/th.R₀) )



abstract type Substance end


struct Solid <: Substance
    ρ::Float64
    cₚ::Float64
    k::Float64
    
end

const Fe2O3 = Solid(3e3, 650.0, 0.58)

thermaldiff(x::Substance) = x.k / (x.ρ*x.cₚ)
density(x::Substance) = x.ρ
specheat(x::Substance) = x.cₚ
thermalcond(x::Substance) = x.k



struct Gas <:Substance
    R::Float64
    M::Float64
    cₚ::Float64
    k::Float64
    μ::Float64
    Gas(M,cp, k, mu) = new(ℜ/M, M, cp, k, mu)
end

const Air = Gas(28.97, 1005.0, 2.6e-2, 1.84e-5)

density(x::Gas, T=20.0, P=Patm) = P/(x.R*(T + 273.15))
density(T=20.0, P=Pamb) = density(Air, T, P)

thermaldiff(x::Gas, T=20.0, P=Patm) = x.k / (density(x,T,P)*x.cp)
thermaldiff(T=20.0, P=Patm) = thermaldiff(Air, T, P)

Prandtl(x::Gas) = x.μ * x.cₚ / x.k

visc(x::Gas=Air) = x.μ
kvisc(x::Gas, T=20.0, P=Patm) = x.μ / density(x,T,P)
kvisc(T=20.0, P=Patm) = kvisc(Air, T, P)








struct HeatTransf
    gas::Gas
    D::Float64
    A::Float64
    function HeatTransf(gas, D, rho, cp)
        r = D/2
        A = 4π*r^2
        new(gas, D, A)
    end
end

Nu_sphere(Re, Pr, μrat=1.0) = 2 + (0.4Re^0.5 + 0.06Re^0.6667)*Pr^0.4*μrat^0.25

function hconvect(gas::Gas, U=5.0, D=3e-3, Ta=20.0, P0=101325.0)
    # Calcular Reynolds
    Pr = Prandtl(gas)
    μ = visc(gas)
    ρ = density(gas, Ta, P0)

    Re = ρ*U*D / μ
    # Calcular Nusselt:
    Nu = Nu_sphere(Re, Pr)

    h = Nu*thermalcond(gas)/D

    return h

end


function const_current(mA, R::Resistance, U=5.0, d=3, gas=Air, Ta=20, P0=101e3, dterr=1e-4, nmax=1000)

    I = mA/1000

    D = d/1000
    r = D/2
    A = 4π*r^2

    
    h = hconvect(gas, U, D, Ta, P0)
    i = 0
    Tw = Ta
    P = 0.0
    for i = 1:nmax
        P = R(Tw)*I^2
        Tw1 = P/(h*A) + Ta
        dt = Tw1-Tw
        #=
        println()
        println("i = ", i)
        println("Tw  = ", Tw)
        println("Tw1 = ", Tw1)
        println("P   = ", P)
        println("-----------------------------------------------")
        =#
        if abs(dt) < dterr
            Tw = Tw1
            break
        end
        Tw = Tw + 0.2*dt
    end

    res = R(Tw)
    E = res*I
    return Tw, E, P, res, i
end


function const_temperature(U, R::Resistance, d=3, Tw=80.0, gas=Air, Ta=20.0, P0=101e3,
                           err=1e-4, nmax=1000)
    
    D = d/1000
    r = D/2
    A = 4π*r^2

    Rw = R(Tw)
    h = hconvect(gas, U, D, Ta, P0)
    P = h*A*(Tw - Ta)

    I = sqrt(P/Rw)
    E = Rw*I
    P = E*I
    return I*1000, E, P
    
end
struct Wheatstone
    R::Vector{Thermistor}
    Wheatstone(R1::Thermistor, R2::Thermistor, R3::Thermistor, R4::Thermistor)  = new([R1, R2, R3, R4])
end

import Base.getindex
getindex(w::Wheatstone, i) = w.R[i]

Wheatstone(R::Vector{Thermistor}) = Wheatstone(R...)

resistance(w::Wheatstone, i) = w.R[i]()
resistance(w::Wheatstone, i, T) = w.R[i](T)


function wcta(U::Float64, W::THW.Wheatstone, d=2.5, Tw=80, gas=Air, Ta=20.0, P0=101e3)


    D = d/1000
    r = D/2
    A = 4π*r^2

    Rw = resistance(W, 4, Tw)
    h = hconvect(gas, U, D, Ta, P0)
    P = h*A*(Tw - Ta)

    ib = sqrt(P/Rw)
    Eb = Rw*ib

    R1 = resistance(W,1)
    R2 = resistance(W,2)
    R3 = resistance(W,3)
    
    Eb1 = ib * R2
    E = Eb1 + Eb

    ia = E/(R1+R3)
    Ea = R3*ia
    
    return E, Ea, Eb, ia*1000, ib*1000
    

end


    
end # module


