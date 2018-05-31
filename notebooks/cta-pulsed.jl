module CTA

using ThermistorHW

"""
    PulsedCTA(Rt::Thermistor, Ri=200.0, Rf=10e3, Cf=10e-6, Vi=24.0, freq=490.0, duty=0.5)

Modela os componentes do circuito primário do anemômetro  de termistor pulsado.

"""
struct PulsedCTA
    "Termistor usado como sensor"
    Rt::Thermistor
    "Resistência usada para media a corrente"
    Ri::Float64
    "Resistência do filtro passa baixa"
    Rf::Float64
    "Capacitor do filtro passa baixa"
    Cf::Float64
    "Tensão de alimentação"
    Vi::Float64
    "Frequência do PWM"
    freq::Float64
    PulsedCTA(Rt::Thermistor, Ri=200.0, Rf=10e3, Cf=10e-6, Vi=24.0,
              freq=490.0, duty=0.5) = new(Rt, Ri, Rf, Cf, Vi, freq)
end

"""
    voltage(cta::PulsedCTA, t=0.0, duty=0.5)

Calcula a tensão ao longo do tempo dado o duty cycle do PWM
"""
function voltage(cta::PulsedCTA, t=0.0, duty=0.5)
    T = 1/cta.freq
    p = mod(t, T) / T

    return cta.Vi * ((p<duty) ? 1.0 : 0.0)
end

(cta::PulsedCTA)(t=0.0, duty=0.5) = voltage(cta, t, duty)

"""
    HeatTrans(Dmm, Ta=20.0, Pa=101.325) 

Principais parâmetros de transferência de calor.
"""
struct HeatTrans
    "Diâmetro do termistor"
    D::Float64
    "Temperatura ambiente"
    Ta::Float64
    "Pressão atmosférica"
    Pa::Float64
    "Área superficial externa do termistos"
    A::Float64
    HeatTrans(Dmm, Ta=20.0, Pa=101.325) = new(Dmm/1000, Ta, Pa, 4π*(Dmm/2000)^2)
end

"""
    hafun(htrans::HeatTrans, U, T)

Calcula `h⋅A` onde `h` é o coeficiente de convecção e `A` é a área externa do termistor.
"""
hafun(htrans::HeatTrans, U, T) = hconvect(U, htrans.D, T, htrans.Ta, htrans.Pa) * htrans.A
(htrans::HeatTrans)(U,T) = hafun(htrans, U, T)

"""
    mcpfun(s::Solid, D)

Calcula `m⋅cₚ` onde `m` é a massa do termistor e `cₚ` é o calor específico do termistor.
"""
mcpfun(s::Solid, D) = s.cₚ * s.ρ * 4π*(D/2)^3/3


"""
    pulsedcta(dy, y, p, t)

Monta o sistema de equações diferenciais do CTA pulsado:

```math
dEₐᵢ/dt = 1/RC⋅( EᵢRᵢ / (Rₜ(T) +Rᵢ) - Eₐᵢ )

```
```math
dT/dt = -hA/mcₚ⋅(T - Tₐ)  + 1/mcₚ * Eᵢ²(t) / Rₜ(T)

```

"""
function pulsedcta(dy, y, p, t)
    cta = p[1]
    duty = p[2]
    U = p[3](t)
    htrans = p[4]
    mcp = p[5]

    hA = htrans(U, y[2])
    Rt = cta.Rt(y[2])
    Rt = (Rt < 20.0)?20.0 : Rt
    
    Ta = htrans.Ta
    
    Ei = cta(t, duty)
    Ri = cta.Ri
    RC = cta.Rf * cta.Cf
    
    dy[1] = 1/RC * ( Ei * Ri/(Rt + Ri) - y[1] )
    dy[2] = -hA/mcp * (y[2] - Ta) + Ei*Ei / Rt / mcp

    return
end

    
end
