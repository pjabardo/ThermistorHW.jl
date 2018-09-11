require(wutils)

Runiversal <- 8314.459848
Gas <- function(name="Air", M=28.9647, ak=24.34607, bk=0.07526, ap=0.714296, bp=-0.000268,
                C=120.0, T0=291.15, mu0=18.27e-6){

    R = Runiversal / M
    gas <- list(fluid=name, R=R, M=M, ak=ak, bk=bk, ap=ap, bp=bp, C=C, T0=T0, mu0=mu0)
    class(gas) <- 'fluidprop'
    return(gas)

}


Air <- Gas()

heatcond <- function(fl=Air, Tc=20, P=101.325) 1e-3*(fl$ak + fl$bk*Tc)
prandtl <- function(fl=Air, Tc=20, P=101.325) fl$ap + fl$bp*Tc
viscosity <- function(fl=Air, Tc=20, P=101.325) fl$mu0 * (fl$T0 + fl$C) / (Tc + 273.15 + fl$C) *
    ((Tc+273.15)/fl$T0)^1.5

specmass <- function(fl=Air, Tc=20, P=101.325) 1000*P / (fl$R * (Tc+273.15))
kinvis <- function(fl=Air, Tc=20, P=101.325) viscosity(fl,Tc,P) / specmass(fl,Tc,P)


Thermistor <- function(R0=5e3, B=3470, T0=25){
	x <- list(R0=R0, B=B, T0=T0)
	class(x) <- "thermistor"
	return(x)
}

resistance <- function(th, temp=25){
	T0 <- th$T0 + 273.15
	T1 <- temp + 273.15
	B <- th$B
	
	return(th$R0 * exp( B * (1/T1 - 1/T0 )))
}

temperature <- function(th, R=5000){
	T0 <- th$T0 + 273.15
	R0 <- th$R0
	B <- th$B
	T1 <- 1 / (1/B * log(R/R0) + 1/T0) - 273.15
	return(T1)
}


CCACalibr <- function(R, U, Eo, Ta=20.0, Pa=93.0, i0=12.3e-3, alpha=7.66667, fluid=Air){
    Rw <- alpha * Eo / i0
    Tw <- temperature(R, Rw)
    Tf <- (Ta + Tw) / 2
    Pr <- prandtl(fluid, Tf, Pa)
    k <- heatcond(fluid, Tf, Pa)
    rho <- specmass(fluid, Tf, Pa)
    mu <- viscosiyty(fluid, Tf, Pa)

    Re <- rho * U / mu
    Nu <- alpha * Eo * i0 / (Pr^0.33333 * k * (Tw-Ta))
    fit <- powerFit(Re, Nu)
    cal <- list(alpha=alpha, i0=i0, R=R, Ta=mean(Ta), Pa=mean(Pa), fluid=fluid, fit=fit)

    class(cal) <- "ccacalibr"
    return(cal)
}

velocity <- function(cal, E, Ta=NULL, Pa=NULL, i0=NULL, fluid=NULL){

    if (is.null(Ta)) Ta <- cal$Ta
    if (is.null(Pa)) Pa <- cal$Pa
    if (is.null(i0)) i0 <- cal$i0
    if (is.null(fluid)) fluid <- cal$fluid

    Rw <- cal$alpha * E / i0
    Tw <- temperature(cal$R, Rw)
    Tf <- (Ta + Tw)/2

    Pr <- prandtl(fluid, Tf, Pa)
    k <- heatcond(fluid, Tf, Pa)
    rho <- specmass(fluid, Tf, Pa)
    mu <- viscosiyty(fluid, Tf, Pa)

    Nu <- cal$alpha * E * i0 / (Pr^0.33333 * k * (Tw-Ta))
    a <- cal$fit$a
    b <- cal$fit$b

    return mu / rho * (Nu/a)^(1/b)
}


    

    
