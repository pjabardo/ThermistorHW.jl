# ThermistorHW

Cálculo de propriedades de termistores e sua aplicação em 
termo-anemometria.

## O que é um termoanemômetro? 

O termoanemometro é um sensor que mede a velocidade de fluidos a partir da transferência de calor
de um elemento aquecido. Este módulo implementa funções e estrutura de dados que permitem
simular e projetar termoanemômetros, em particular, sensores que usam um termistor como 
elemento aquecido. 

## Termistor NTC

O termistor é um dispositivo semicondutor cuja resistência varia de maneira acentuada 
com a temperatura, geralmente de maneira não linear. Em particular, nos termistores NTC 
(negative temperature coefficient), a resistência diminui quando a temperatura aumenta.

Um modelo semiempírico para a variação da resistência do termistor com a temperatura é dada
pela seguinte equação:

```
R = R₀ exp(B (1/T - 1/T₀) )
```

No módulo `ThermistorHW`, um termistor é modelado utilizando a estrutura de dados `Thermistor`
que é inicializado utilizando a seguinte relação:

```julia
R = Thermistor(R₀, B, T₀)
```
Exemplo de uso do pacote `ThermistorHW`:

```
julia> R = Thermistor(5e3, 3000.0, 20.0) # Cria um objeto Thermistor com resistência
                                         # 5000 Ω a 20°C
THW.Thermistor(5000.0, 3000.0, 293.15)

julia> R(90) # Calcular a resistência a 90°C
695.4600537422674

julia> R(80) # Calcular a resistência a 80°C
878.7480537478157

julia> resistance(R, 80) # Outra forma de calcular a resistência a 80°C
878.7480537478157

julia> temperature(R, 1e3) # Calcular a temperatura quando a resistência vale 1000 Ω.
74.7071074288607
```


## Funcionamento do termoanemômetro

Quando uma corrente elétrica passa por termistor NTC, existe dissipação de calor (efeito Joule) valendo $R I²$. Este calor gerado é transmitido ao ar por convecção:

```
R I² = h A (T - Tₒₒ)
```

onde
 * `R` é a resistência elétrica do termistor
 * `I` é a corrente elétrica passando pelo termistor
 * `h` é o coeficiente de convecção
 * `A` é a área superficial externa do termistor
 * `T` é a temperatura do termistor
 * `Tₒₒ` é a temperatura ao longe

Tradicionalmente existem dois modos básicos de operação do termoanemômetro:

 * Corrente constante
 * Temperatura constante

### Corrente constante

Quando operando a corrente constante, uma fonte de corrente constante é usada para alimentar
o elemento sensor, como resultado da convecção do fluido ao passar pelo sensor, a temperatura
do mesmo muda e assim a voltagem no sensor muda, o que pode ser correlacionado com a velocidade
do escoamento. Uma vantagem do modo corrente constante é que o circuito eletrônico é bastante
simples: uma fonte de corrente!

A função `const_current` simula um termistor operando em corrente constante
em escoamento no ar seco.

### Temperatura constante

Este outro modo de operação é o mais comum na prática. No modo temperatura constante,
a temperatura do sensor é mantida constante. Como a resistência muda com a temperatura,
manter a temperatura constante corresponde a manter a resistência constante. Isto é feito
utilizando um sistema de controle, o que torna o anemômetro mais complexo.

A função `const_temperature` simula um termistor a temperatura constante em
escoamento no ar seco.


## Transferência de calor e convecção

O que é desconhecido neste modelo é o coeficiente de convecção `h` que pode ser obtido
a partir de correlações empíricas disponíveis em livros e manuais de transferência
de calor (vale lembrar que a incerteza destas correlações é significativa). Estas
correlações são geralmente fornecidas através de equações como:

```
Nu = Nu(Re, Pr)
```
onde `Nu=hL/k` é o número de Nusselt, `Re = ρVD/μ` é o número de Reynolds e `Pr = ν/α` é
o número de Prandtl. As funções `nusphere` e `nucylinder` calculam o número de Nusselt para
uma esfera e um cilindro respectivamente. Caso a velocidade seja muito baixa, a convecção
passa a ser natural, resultado da diferença de densidade do fluido com a temperatura em
um campo gravitacional. Neste caso, as correlações geralmente têm a seguinte forma:

```
Nu = Nu(Ra, Pr)
```
onde `Ra = Gr Pr = g β (T-Tₒₒ)L³/ν² Pr` é o número de Rayleigh. A função `nuspherefree` fornece
uma correlação para convecção livre em uma esfera.

A função `hconvect` utiliza as correlações acima para calcular diretamente o coeficiente de
convecção para uma esfera colocada no ar.

Este coeficiente de convecção também pode ser medido diretamente e a calibração do sensor
é basicamente uma medição do coeficiente mesmo que não se use a mesma terminologia.



## Propriedades termodinâmicas e de transporte

Todas estas relações de transferência de calor e termodinâmica utilizam propriedades
termodinâmicas do fluido e do termistor. As seguintes funções estão disponíveis neste pacote:

 * `heatcond`: condutividade térmica (k)
 * `viscosity`: viscosidade dinâmica (μ)
 * `kinviscosity`: viscosidade cinemática (ν)
 * `density`: densidade (ρ)
 * `specheat`: calor específico a pressão constante (cₚ)
 * `thermaldiff`: difusividade térmica (α)
 * `prandtl`: Número de Prandtl (Pr)
 * `reynolds`: Número de Reynolds (Re)
 * `volthermalexpansion`: Coeficiente de expansão volumétrica (β)

## Exemplos

Os notebooks a seguir apresentam exemplos


 * [Simulação simples de um anemômetro a temperatura e corrente constantes](https://github.com/pjabardo/ThermistorHW.jl/blob/master/notebooks/termistor.ipynb).
 * [Constante de tempo do termistor](https://github.com/pjabardo/ThermistorHW.jl/blob/master/notebooks/thermistor-time-const.ipynb)
 * [Exemplo de simulação do CTA pulsado - eletrônica + térmica(https://github.com/pjabardo/ThermistorHW.jl/blob/master/notebooks/cta-pulsed.ipynb)
 