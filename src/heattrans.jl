

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

