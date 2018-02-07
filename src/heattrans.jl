

reynolds(fl::AbstractFluid, L, U, Tc=20.0, Pa=101.325) = density(fl, Tc, Pa) * U*L/viscosity(fl, Tc)

nusphere(Re, Pr, μrat=1.0) = 2 + (0.4Re^0.5 + 0.06Re^0.6667)*Pr^0.4*μrat^0.25

nucylinder(Re, Pr) = 0.75 * Re^0.4 * Pr^0.37

function grashof(Air::AirType, Ts, Ta, L, Pa=101.325, g=9.80665)

    ν = kinviscosity(Air, Ta, Pa)
    β = volthermalexpansion(Air, Ta)

    return g * β * (Ts-Ta) * L^3 / (ν^2)
end


function rayleigh(Air::AirType, Ts, Ta, L, Pa=101.325, g=9.80665)
    return grashof(Air, Ts, Ta, L, Pa) * prandtl(Air, Ta)
end

nuspherefree(Ra, Pr) = 2.0 + 0.589*Ra^0.25 / (1 + (0.469/Pr)^(9/16))^(4/9)


function hconvect(U=5.0, D=3e-3, Ts=80.0, Ta=20.0, Pa=101.325 )

    Pr = prandtl(Air, Ta)
    relim = 20.0
    if U==0.0
        Ra = rayleigh(Air, Ts, Ta, D, Pa)
        Nu = nuspherefree(Ra, Pr)
    else
        Re = reynolds(Air, D, U, Ta, Pa)
        μ = viscosity(Air, Ta)
        μₛ = viscosity(Air, Ts)
        if Re < relim
            Ra = rayleigh(Air, Ts, Ta, D, Pa)
            Nu1 = nuspherefree(Ra, Pr)
            Nu2 = nusphere(relim, Pr, μ/μₛ)
            Nu = Nu1 * (relim-Re)/relim + Nu2 * Re/relim
        else
            Nu = nusphere(Re, Pr, μ/μₛ)
        end
    end
    
    h = Nu*heatcond(Air, Ta)/D

    return h

end



function hconvectcyl(U=5.0, D=5e-6, Ts=80.0, Ta=20.0, Pa=101.325 )

    Pr = prandtl(Air, Ta)
    Re = reynolds(Air, D, U, Ta, Pa)
    Nu = nucylinder(Re, Pr)
    
    h = Nu*heatcond(Air, Ta)/D
    return h

end


    
