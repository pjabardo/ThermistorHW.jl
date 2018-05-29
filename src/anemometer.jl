#=

Modela diferentes tipos de anemômetros

=#

"""
    HWSensor(I, E, R, T)

Condições de operação do sensor de um anemômetro de fio quente.
"""
struct HWSensor
    "Corrente passando no sensor"
    I::Float64
    "Tenão no sensor"
    E::Float64
    "Resistência do sensor"
    R::Float64
    "Temmperatura do sensor"
    T::Float64
    "Potência dissipada no sensor"
    P::Float64
    HWSensor(I, E, R, T) = new(I, E, R, T, I*E)
end

"""
    const_current(mA, R::Thermistor, U=5.0, d=3.0, Ta=20.0, Pa=101.3, dterr=1e-6, nmax=20000)

Modela um anemômetro trabalhando a corrente constante. Não simula circuitos elétricos. 
Utiliza um esquema iterativo.


Argumentos:
 * `mA` Corrente em mA
 * `R` Objeto que modela o termistor
 * `U` Velocidade em m/s
 * `d` Diâmetro em mm
 * `Ta` Temperatura ao longe em °C
 * `Pa` Pressão atmosférica em kPa
 * `dterr` Erro admissível para convergência da temperatura.
 * `nmax` Número máximo de iterações.

```jldoctest
julia> R = Thermistor(5e3, 3200, 20)
THW.Thermistor(5000.0, 3200.0, 293.15)

julia> const_current(20, R, 5.0, 2.0)
THW.HWSensor(0.02, 9.395209322307162, 469.7604661153581, 101.07772779650266, 0.18790418644614323)

julia> const_current(20, R, 1.0, 2.0)
THW.HWSensor(0.02, 5.872996120670518, 293.64980603352586, 122.8352988426391, 0.11745992241341036)

julia> const_current(20, R, 10.0, 2.0)
THW.HWSensor(0.02, 11.70131737284239, 585.0658686421194, 91.71177677466494, 0.2340263474568478)

julia> const_current(20, R, 10.0, 10.0)
THW.HWSensor(0.02, 44.971641701710844, 2248.582085085542, 43.15632417996514, 0.8994328340342169)
```
"""
function const_current(mA, R::Thermistor, U=5.0, d=3.0, Ta=20.0, Pa=101.3, dterr=1e-6, nmax=20000)

    I = mA/1000

    D = d/1000
    r = D/2
    A = 4π*r^2

    Tw = Ta + 0.01
    
    i = 0
    P = 0.0
    for i = 1:nmax
        h = hconvect(U, D, Tw, Ta, Pa)
        #println(h)
        P = R(Tw)*I^2
        Tw1 = P/(h*A) + Ta
        dt = Tw1-Tw
        if abs(dt) < dterr
            Tw = Tw1
            break
        end
        Tw = Tw + 0.4*dt
    end

    res = R(Tw)
    E = res*I
    return HWSensor(I, E, res, Tw)
end


"""
    const_temperature(Tw, R::Thermistor, U=5.0, d=3.0, Ta=20.0, Pa=101.3)

Modela um anemômetro trabalhando a temperatura constante. Não simula circuitos elétricos. 


Argumentos:
 * `Tw` Temperatura de operação do sensor
 * `R` Objeto que modela o termistor
 * `U` Velocidade em m/s
 * `d` Diâmetro em mm
 * `Ta` Temperatura ao longe em °C
 * `Pa` Pressão atmosférica em kPa


```jldoctest
julia> R = Thermistor(5e3, 3200, 20)
THW.Thermistor(5000.0, 3200.0, 293.15)

julia> const_temperature(100.0, R, 5.0, 2.0)
THW.HWSensor(0.019627341883449854, 9.45069202339691, 481.50646580247894, 100.0, 0.18549196337840362)

julia> const_temperature(100.0, R, 1.0, 2.0)
THW.HWSensor(0.01383013241982859, 6.65929818305195, 481.50646580247894, 100.0, 0.09209897569473241)

julia> const_temperature(100.0, R, 10.0, 2.0)
THW.HWSensor(0.023241402160834233, 11.190885414757389, 481.50646580247894, 100.0, 0.26009186846019067)

julia> const_temperature(100.0, R, 20.0, 2.0)
THW.HWSensor(0.027741857167247384, 13.357883599398457, 481.50646580247894, 100.0, 0.3705724988712284)

julia> const_temperature(100.0, R, 20.0, 3.0)
THW.HWSensor(0.037797691428912955, 18.19983281542853, 481.50646580247894, 100.0, 0.6879116648153717)
```
"""
function const_temperature(Tw, R::Thermistor, U=5.0, d=3.0, Ta=20.0, Pa=101.3)



    D = d/1000
    r = D/2
    A = 4π*r^2

    Rw = R(Tw)
    h = hconvect(U, D, Tw, Ta, Pa)
    i = sqrt(h*A*(Tw-Ta)/Rw)
    
    return HWSensor(i, Rw*i, Rw, Tw)
end


function const_temperature_cyl(Tw, R::AbstractResistor, U=5.0, d=5.0, l=3, Ta=20.0, Pa=101.325)
    


    D = d/1e6
    L = l / 1000
    
    r = D/2
    
    A = L * π * D

    Rw = R(Tw)
    h = hconvectcyl(U, D, Tw, Ta, Pa)
    i = sqrt(h*A*(Tw-Ta)/Rw)

    return i*1000
end

