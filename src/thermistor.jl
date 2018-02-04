


abstract type AbstractResistor end

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
struct Thermistor <: AbstractResistor
    "resistance at temperature T₀"
    R₀::Float64
    "Empirical coefficient that models the behavior of the thermistor, unit 1/K"
    B::Float64
    "Reference temperature in K"
    T₀::Float64
    Thermistor(R₀=5e3, B=0.0, T₀=20.0) = new(R₀, B, T₀+273.15)
end

Resistor(R₀) = Thermistor(R₀, 0.0, 20.0)

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
temperature(th::Thermistor) = th.T₀-273.15
temperature(th::Thermistor, R) = 1/( 1/th.T₀ + 1/th.B * log(R/th.R₀) ) - 273.15


