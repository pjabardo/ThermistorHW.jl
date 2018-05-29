
"""
    reynolds(fl::AbstractFluid, L, U, Tc=20.0, Pa=101.325)

Calcula o número de Reynolds para um fluido `fl`, uma escala de comprimento `L` em m, 
temperatura em °C e pressão em kPa.

```jldoctest
julia> reynolds(Air, 3e-3, 10)
1966.4892978721982

julia> reynolds(Air, 3e-3, 1)
196.64892978721983

julia> reynolds(Air, 2e-3, 1, 85.0, 93)
84.4083527295806
```
"""
reynolds(fl::AbstractFluid, L, U, Tc=20.0, Pa=101.325) = density(fl, Tc, Pa) * U*L/viscosity(fl, Tc)

"""
    nusphere(Re,Pr,μrat)

Número de Nusselt de uma esfera para número de Reynolds `Re`, número de Prandtl `Pr` e 
razão de viscosidade na superfíce e ao longe. 

O número de Nusselt permite calcular o coeficiente de convecção a partir da condutividade 
térmica e um comprimento característico:

```math
Nu = h L/k
```


```jldoctest
julia> nusphere(100, 0.7)
6.589121562852225

julia> nusphere(100, 0.7, 1.3)
6.90021798681175
```

"""
nusphere(Re, Pr, μrat=1.0) = 2 + (0.4Re^0.5 + 0.06Re^0.6667)*Pr^0.4*μrat^0.25

"""
    nucylinder(Re,Pr)

Número de Nusselt de um cilindro para número de Reynolds `Re`, número de Prandtl `Pr`.

O número de Nusselt permite calcular o coeficiente de convecção a partir da condutividade 
térmica e um comprimento característico:

```math
Nu = h L/k
```

```jldoctest
julia> nucylinder(3.0, 0.7)
1.0199902962373502
```

"""
nucylinder(Re, Pr) = 0.75 * Re^0.4 * Pr^0.37

"""
    grashof(Air, Ts, Ta, L, Pa, g)

Número de Grashof para ar seco, onde `Ts` é a temperatura do fluido em °C, `Ta` é a 
temperatura ao longe, L é um comprimento em m, Pa a pressão em kPa e g é a aceleração
da gravidade em m/s²

O número de Grashof é usado em convecção natural.

```jldoctest
julia> grashof(Air, 80, 20, 2e-3, 101.325, 9.8)
68.9474295156832

julia> grashof(Air, 80, 20, 2e-1, 101.325, 9.8)
6.89474295156832e7
```
"""
function grashof(Air::AirType, Ts, Ta, L, Pa=101.325, g=9.80665)

    ν = kinviscosity(Air, Ta, Pa)
    β = volthermalexpansion(Air, Ta)

    return g * β * (Ts-Ta) * L^3 / (ν^2)
end


"""
    rayleigh(Air, Ts, Ta, L, Pa, g)

Número de Rayleigh para ar seco, onde `Ts` é a temperatura do fluido em °C, `Ta` é a 
temperatura ao longe, L é um comprimento em m, Pa a pressão em kPa e g é a aceleração
da gravidade em m/s²

O número de Rayleigh é usado em convecção natural e vale:

```math
Ra = Gr Pr
```

```jldoctest
julia> rayleigh(Air, 80, 20, 2e-3, 101.325, 9.8)
49.491941991306895

julia> rayleigh(Air, 80, 20, 1e-3, 101.325, 9.8)
6.186492748913362
```
"""
function rayleigh(Air::AirType, Ts, Ta, L, Pa=101.325, g=9.80665)
    return grashof(Air, Ts, Ta, L, Pa) * prandtl(Air, Ta)
end

"""
    nuspherefree(Ra, Pr)

Número de Nusselt para uma esfera em convecção natural. 
Utiliza o número de Rayleigh `Ra` e o número de Prandtl `Pr`

O número de Nusselt permite calcular o coeficiente de convecção a partir da condutividade 
térmica e um comprimento característico:

```math
Nu = h L/k
```

"""
nuspherefree(Ra, Pr) = 2.0 + 0.589*Ra^0.25 / (1 + (0.469/Pr)^(9/16))^(4/9)

"""
    hconvect(U=5.0, D=3e-3, Ts=80.0, Ta=20.0, Pa=101.325 )

Calcula o coeficiente de convecção forçada em uma esfera aquecida dentro de uma corrente de ar.

  * `U` Velocidade em m/s
  * `D` Diâmetro em m
  * `Ts` Temperatura da esfera em °C
  * `Ta` Temperatura do ar ao longe e °C
  * `Pa` Pressão atmosférica em kPa

Se a velocidade for baixa, admite convecção natural. 


```math
h = Nu(Re ou Ra, Pr) k(T) / L
```
```jldoctest
julia> hconvect(1.0, 3e-3, 80, 20, 101)
72.37579698816417

julia> hconvect(5.0, 3e-3, 80, 20, 101)
150.73181000789378

julia> hconvect(10.0, 3e-3, 80, 20, 101)
213.4926385463913

julia> hconvect(10.0, 2e-3, 80, 20, 101)
260.7448248784586

julia> hconvect(10.0, 2e-3, 160, 20, 101)
252.09076590966555
```
"""
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


    
