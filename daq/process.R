process1 <- function(){

    vel <- c(1, 2.03, 5.06, 7, 10.04, 12.07, 16.01, 10.04, 6.04, 3)
    Tj <- c(19.50, 19.50, 19.80, 19.80, 19.80, 19.80, 19.90, 20.20, 20.20, 20.20)
    Tbs <- c(19.50, 19.50, 19.50, 19.60, 19.60, 19.50, 19.80, 20.20, 20.20, 20.20)
    Tbu <- c(15.40, 15.40, 15.50, 15.50, 15.50, 15.40, 15.40, 15.70, 15.70, 15.70)
    Pa <- c(93.451, 93.451, 93.446, 93.445, 93.444, 93.444, 93.442, 93.440, 93.440, 93.440)
    
    

    fbase <- c("ponto-01", "ponto-02", "ponto-05", "ponto-07", "ponto-10", "ponto-12", "ponto-16", "ponto-10b", "ponto-06b", "ponto-03b")
    fvel <- file.path('cal1', paste0(fbase, "-vel.txt"))
    ftemp <- file.path('cal1', paste0(fbase, "-temp.txt"))

        eraw <- t(sapply(fvel, function(f) colMeans(read.table(f)[,3:16])))
    temp <- t(sapply(ftemp, function(f)colMeans(read.table(f)[,3:6])))
    

    E <- (eraw/4096)*3.3 - 0.146
    colnames(eraw) <- paste0('P', 1:ncol(eraw))
    colnames(temp) <- paste0('T', 1:ncol(temp))
    colnames(E) <- paste0('E', 1:ncol(E))

    return(data.frame(V=vel, E, Tj=Tj, Tbs=Tbs, Tbu=Tbu, Pa=Pa, eraw, temp))

}



process2 <- function(){

    Tj <- c(21.10, 21.30, 21.10, 21.00, 21.00, 20.80, 20.90, 21.20, 21.30, 21.30, 21.20, 21.10, 21.10, 21.10, 21.50, 21.60)
    Tbs <- c(20.20, 20.50, 20.60, 20.60, 20.40, 20.40, 20.60, 21.10, 21.10, 21.10, 20.90, 20.80, 20.90, 21.00, 21.00, 21.20)
    Tbu <- c(15.40, 15.40, 15.50, 15.50, 15.50, 15.20, 15.20, 15.40, 15.50, 15.60, 15.50, 15.60, 15.60, 15.70, 15.70, 15.70)
    Pa <- c(93.102, 93.096, 93.097, 93.097, 93.096, 93.095, 93.095, 93.094, 93.090, 93.092, 93.090, 93.084, 93.085, 93.088, 93.088, 93.088)
    vel <- c(1.01, 2.05, 3.04, 5.04, 7.01, 10.03, 12.05, 16.04, 10.03, 5.04, 3.05, 1.01, 3.05, 5.04, 10.04, 16.06)

    fbase <- c("ponto-01", "ponto-02", "ponto-03", "ponto-05", "ponto-07", "ponto-10", "ponto-12", "ponto-16", "ponto-10b", "ponto-5b", "ponto-3b", "ponto-1b", "ponto-3c", "ponto-5c", "ponto-10c", "ponto-16c")
    
    fvel <- file.path('cal2', paste0(fbase, "-vel.txt"))
    ftemp <- file.path('cal2', paste0(fbase, "-temp.txt"))
    
    eraw <- t(sapply(fvel, function(f) colMeans(read.table(f)[,3:16])))
    temp <- t(sapply(ftemp, function(f)colMeans(read.table(f)[,3:6])))
    

    E <- (eraw/4096)*3.3 - 0.146
    colnames(eraw) <- paste0('P', 1:ncol(eraw))
    colnames(temp) <- paste0('T', 1:ncol(temp))
    colnames(E) <- paste0('E', 1:ncol(E))

    return(data.frame(V=vel, E, Tj=Tj, Tbs=Tbs, Tbu=Tbu, Pa=Pa, eraw, temp))

}

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

heatcond <- function(Tc) 1e-3 * (24.34607 + 0.07526*Tc)
prandtl <- function(Tc) 0.714296 - 0.000268*Tc
visc <- function(Tc){
	C = 120
	T0 <- 291.15
	mu0 <- 18.27e-6
	Tk <- Tc + 273.15
	return(mu0 * (T0 + C) / (Tk + C) * (Tk / T0)^1.5)
	      
}

density <- function(Tc, P=101325) P /(287.06 * (Tc+273.15))


