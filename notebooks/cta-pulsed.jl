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
    PulsedCTA(Rt::Thermistor, Ri=100.0, Rf=10e3, Cf=47e-6, Vi=24.0,
              freq=1000.0, duty=0.5) = new(Rt, Ri, Rf, Cf, Vi, freq)
end

"""
    voltage(cta::PulsedCTA, t=0.0, duty=0.5)

Calcula a tensão ao longo do tempo dado o duty cycle do PWM
"""
function voltage(cta::PulsedCTA, t=0.0, duty=0.5, tmin=0.0)
    if t < tmin
        return cta.Vi
    end
    
    T = 1/cta.freq
    p = mod(t, T) / T

    return cta.Vi * ((p<=duty) ? 1.0 : 0.0)
end

(cta::PulsedCTA)(t=0.0, duty=0.5, tmin=0.0) = voltage(cta, t, duty, tmin)

"""
    HeatTrans(Dmm, Ta=20.0, Pa=101.325) 

Principais parâmetros de transferência de calor.
"""
struct HeatTrans
    "Temperatura de operação do termistor"
    Tw::Float64
    "Diâmetro do termistor"
    D::Float64
    "Temperatura ambiente"
    Ta::Float64
    "Pressão atmosférica"
    Pa::Float64
    "Área superficial externa do termistos"
    A::Float64
    "Propriedades de transferência de calor do termistor"
    S::Solid
    m::Float64
    mcp::Float64
    function HeatTrans(Tw=85.0, Dmm=2.0,  Ta=20.0, Pa=93.0, S=Fe₂O₃)
        D = Dmm/1000
        R = D/2
        A = 4π*R^2
        Vol = A*R/3
        m = Vol * S.ρ
        mcp = m * S.cₚ
        
        new(Tw, D, Ta, Pa, A, S, m, mcp)
    end
    
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
mcpfun(s::Solid, D) = s.cₚ * s.ρ * 4π/3*(D/2)^3


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
    tmin = p[6]
    
    hA = htrans(U, y[2])
    Rt = cta.Rt(y[2])
    #Rt = (Rt < 20.0)?20.0 : Rt

    Ta = htrans.Ta
    
    Ei = cta(t, duty, tmin)
    Ri = cta.Ri
    RC = cta.Rf * cta.Cf
    I = Ei / (Rt + Ri)
    
    dy[1] = 1/RC * ( Ei * Ri/(Rt + Ri) - y[1] )
    dy[2] = -hA/mcp * (y[2] - Ta) + Rt/mcp * I*I

    return
end

    
abstract type AbstractVelocity end


struct VelConst <: AbstractVelocity
    v::Float64
    VelConst(v=10.0) = new(v)
end


velocity(v::VelConst, t=0.0) = v.v
(v::VelConst)(t=0.0) = velocity(v,t)

struct VelFreq <: AbstractVelocity
    vmean::Float64
    freq::Float64
    ampl::Float64
    VelFreq(vmean=10.0, freq=0.5, ampl=0.5) = new(vmean, freq, ampl)
end
velocity(v::VelFreq, t=0.0) = v.vmean + v.ampl * sin(2π*v.freq*t)
(v::VelFreq)(t=0.0) = velocity(v,t)
    
struct VelRamp <: AbstractVelocity
    α::Float64
    VelRamp(α=1.0) = new(α)
end

velocity(v::VelRamp, t=0.0) = v.α * t
(v::VelRamp)(t=0.0) = velocity(v,t)

struct VelRampConst <: AbstractVelocity
    t0::Float64
    V0::Float64
    VelRampConst(V0=10.0, t0=10.0) = new(V0, t0)
end
velocity(v::VelRampConst, t=0.0) = (t < v.t0) ? t*v.V0/v.t0 : v.V0
(v::VelRampConst)(t=0.0) = velocity(v, t)
    
struct VelStep <: AbstractVelocity
    t0::Float64
    V0::Float64
    V1::Float64
    VelStep(t0=10.0, V1=10.0, V0=0.0) = new(t0, V0, V1)
end
velocity(v::VelStep, t=0.0) = (t < v.t0) ? v.V0 : v.V1
(v::VelStep)(t=0.0) = velocity(v, t)

struct VelUpDown <: AbstractVelocity
    t0::Float64
    t1::Float64
    t2::Float64
    V0::Float64
    VelUpDown(V0=10.0, t0=6.0, t1=12, t2=18.0) = new(t0, t1, t2, V0)
end
function velocity(v::VelUpDown, t=0.0)
    if t < v.t0
        return v.V0*t/v.t0
    elseif t >= v.t0 && t < v.t1
        return v.V0
    elseif t >= v.t1 && t < v.t2
        return (1.0 - (t-v.t1)/(v.t2-v.t1)) * v.V0
    else
        return 0.0
    end
end
(v::VelUpDown)(t=0.0) = velocity(v, t)

    
hamcpfun(htrans::HeatTrans, vel::AbstractVelocity, t=0.0, Tw=htrans.Tw) = hafun(htrans, vel(t), Tw)/htrans.mcp

hamcpfun(htrans::HeatTrans, U::Number, t=0.0, Tw=htrans.Tw) = hafun(htrans, U, Tw)/htrans.mcp


end

