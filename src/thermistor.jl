

"""
Resistor Abstrato
"""
abstract type AbstractResistor end

doc"""
    R = Thermistor(R₀, B, T₀)

Modela um Termistor NTC (e também um resistor constante);
Neste construtor, `R₀` é a resistência na temperatura de referência `T₀`. 
No construtor a temperatura de referência deve estar em °C, por conveniência, 
mas é armazenado em K. `B` é um coeficiente que caracteriza como o termistor
varia de resistência com a temperatura. No modelo, utilizado, a resistência 
varia com a temperatura de acordo com o seguinte modelo:

```math
R = R₀ \exp\left(\frac{1}{T₀} - \frac{1}{T}\right)
```

onde  
 * R₀ é a resistência na temperatura de referência T₀
 * T₀ é a temperatura de referência em K, geralmente vale  293.15 K
 * T é a temperatura, em K, na qual se quer calcular a resistência
 * B é um coeficiente empírico que caracateriza a variação da resistência com a  temperatura (unidade 1/K)

    
    Construtor de objetos `Thermistor`. Cuidado que no construtor a unidade de `T₀` é °C e não K.

# Examples
```jldoctest
julia> R = Thermistor(5e3, 3200, 20) # Criar um objeto Thermistor
THW.Thermistor(5000.0, 3200.0, 293.15)

julia> resistance(R) # Resistência na temperatura de referência
5000.0

julia> resistance(R, 25) # Reistência a 25°C
4163.587774917559

julia> R() # Igual a resistance(R)
5000.0

julia> R(25) # Igual a resistance(R, 25)
4163.587774917559

julia> temperature(R)
20.0

julia> temperature(R, 4163.588)
24.999998498264233

```

"""
struct Thermistor <: AbstractResistor
    "Resistência na temperatura  T₀"
    R₀::Float64
    "Coeficiente empírico que modela o comportamento do termistor unidade 1/K"
    B::Float64
    "Temperatura de referência em K"
    T₀::Float64
    Thermistor(R₀=5e3, B=0.0, T₀=20.0) = new(R₀, B, T₀+273.15)
end




"""
    resistance(th::Thermistor)
    resistance(th::Thermistor, Tc)

Calcula a resistência a qualquer temperatura. 
Se a temperatura não for fornecida retorna a resistência de referência `R₀`

Ver [`Thermistor`](@ref) para ver mais detalhes da classe `Thermistor`.

"""
resistance(th::Thermistor) = th.R₀ 
resistance(th::Thermistor, T) = th.R₀ * exp( -th.B * (1/th.T₀ - 1/(T+273.15) ) )


(th::Thermistor)(T) = resistance(th, T)
(th::Thermistor)() = th.R₀

"""
    temperature(th::Thermistor, R)
    temperature(th::Thermistor)

Dada uma resitência, calcular a temperatura correspondente. Caso não seja fornecida a resistência, retornar a temperatura de referência.

"""
temperature(th::Thermistor) = th.T₀-273.15
temperature(th::Thermistor, R) = 1/( 1/th.T₀ + 1/th.B * log(R/th.R₀) ) - 273.15


"""
    r = Resistor(R0=1e3, α=0.0, T₀=20.0)

Um resistor cuja resistência varia linearmente com a temperatura segundo a seguinte equação:

```math
R = R₀ (1 + α (T - T₀))
```

**IMPORTANTE** No construtor o coeficiente `α` entra como um *porcentual*
 linear. 

# Exemples

```jldoctest
julia> R = Resistor(1e3, 0.01)
THW.Resistor(1000.0, 0.0001, 20.0)

julia> resistance(R)
1000.0

julia> resistance(R, 120)
1010.0

julia> R()
1000.0

julia> R(120)
1010.0

julia> temperature(R)
20.0

julia> temperature(R, 1010)
120.00000000000009

```
"""
struct Resistor <: AbstractResistor
    "Resistência na temperatura de referência"
    R₀::Float64
    "Coeficiente linear da resistência"
    α::Float64
    "Temperatura de referência"
    T₀::Float64
    Resistor(R0=1e3, α=0.0, T₀=20.0) = new(R0, α/100, T₀)
end

resistance(r::Resistor) = r.R₀ 
resistance(r::Resistor, T) = r.R₀ * (1 +  r.α*(T - r.T₀)) 
(r::Resistor)(T) = resistance(r, T)
(r::Resistor)() = resistance(r)

temperature(r::Resistor) = r.T₀
temperature(r::Resistor, R) = 1/r.α * (R/r.R₀ - 1) + r.T₀

"""
Uma ponte de Wheatstone composta de 4 resistores
"""
struct Wheatstone{RT<:Union{Resistor, Thermistor}}
    R::NTuple{4, RT}
end

Wheatstone(R1::RT, R2::RT, R3::RT, R4::RT)  where {RT<:Union{Resistor, Thermistor}} = Wheatstone( (R1, R2, R3, R4))
import Base.getindex
getindex(w::Wheatstone, i) = w.R[i]

Wheatstone(R::Vector{Thermistor}) = Wheatstone(R...)

resistance(w::Wheatstone, i) = w.R[i]()
resistance(w::Wheatstone, i, T) = w.R[i](T)
