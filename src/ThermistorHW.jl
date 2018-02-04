module THW

# package code goes here

include("thermistor.jl")


abstract type AbstractSubstance end
abstract type AbstractGas <: AbstractSubstance end

abstract type IdealGas <: AbstractGas end

"""
 Singleton to calculate Air properties.
"""
struct Air <: IdealGas end


include("air.jl")
include("solid.jl")








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


