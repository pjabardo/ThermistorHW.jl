#=

Models anemometers

=#



function const_current(mA, R::Thermistor, U=5.0, d=3.0, Ta=20.0, Pa=101e3, dterr=1e-6, nmax=20000)

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
    #return Tw, E, P, res, i
    return Tw
end


function const_temperature(Tw, R::Thermistor, U=5.0, d=3.0, Ta=20.0, Pa=101e3)



    D = d/1000
    r = D/2
    A = 4π*r^2

    Rw = R(Tw)
    h = hconvect(U, D, Tw, Ta, Pa)
    i = sqrt(h*A*(Tw-Ta)/Rw)

    return i*1000
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

