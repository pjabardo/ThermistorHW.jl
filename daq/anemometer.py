import numpy as np
from fluidprop import air
import curvefit

class CCACalibr(object):

    def __init__(self, R, U, Eo, Ta=20.0, Pa=93.0, i0=12.3e-3, alpha=7.66667, fluid=air):

        
        Rw = alpha * Eo / i0
        Tw = R.temp(Rw)
        Tf = (Ta + Tw) / 2

        Pr = fluid.prandtl(Tf, Pa)
        k = fluid.heatcond(Tf, Pa)
        rho = fluid.density(Tf, Pa)
        mu = fluid.viscosity(Tf, Pa)

        Re = rho * U  / mu
        Nu = alpha * Eo * i0/ (Pr**0.333333 * k * (Tw - Ta))

        self.alpha = alpha
        self.i0 = i0
        self.R = R
        self.Ta = np.mean(Ta)
        self.Pa = np.mean(Pa)
        self.fluid = fluid
        self.fit =  curvefit.PowerFit(Re, Nu)
        
    def value(self, E, Ta=None, Pa=None, i0=None, fluid=None):
        if Ta is None:
            Ta = self.Ta
        if Pa is None:
            Pa = self.Pa
        if i0 is None:
            i0 = self.i0
        if fluid is None:
            fluid = self.fluid

        Rw = self.alpha * E / self.i0
        Tw = self.R.temp(Rw)
        Tf = (Ta + Tw)

        Pr = fluid.prandtl(Tf, Pa)
        k = fluid.heatcond(Tf, Pa)
        rho = fluid.density(Tf, Pa)
        mu = fluid.viscosity(Tf, Pa)

        Nu = self.alpha * E * self.i0 / (Pr**0.333333 * k * (Tw - Ta))
        a = self.fit.a
        b = self.fit.b

        return mu/rho * (Nu/a)**(1/b)
    
    def __call__(self, E, Ta=None, Pa=None, i0=None, fluid=None):
        return self.value(E, Ta, Pa, i0, fluid)
    

def readmeasfile(fname, head='IPT'):

    nh = len(head)
    with open(fname, "r") as fp:
        lines = fp.readlines()
        lines = [ll.strip() for ll in lines]
        lines = [ll for ll in lines if ll[0:nh]==head]
        vstr = np.array([ll.split("\t")[1:] for ll in lines])
        vals = vstr.astype(np.float)
    return vals

def readcal1():
    tunel = np.loadtxt("cal1/tunel.txt", delimiter=",").transpose()
    fbase = ["ponto-01", "ponto-02", "ponto-05", "ponto-07", "ponto-10", "ponto-12",
             "ponto-16", "ponto-10b", "ponto-06b", "ponto-03b"]

    ftemp = ["cal1/" + f + "-temp.txt" for f in fbase]
    fvel = ["cal1/" + f + "-vel.txt" for f in fbase]

    temp = np.array([readmeasfile(f, 'IPT').mean(0) for f in ftemp])[:,1:]
    E =  np.array([readmeasfile(f, 'IPT').mean(0) for f in fvel])[:,1:] * 3.3/4095.0 - 0.146

    T = tunel[:,0]
    Pa = tunel[:,3]
    U = tunel[:,4]

    
    return U, E, T, Pa, temp
# Erro da temperatura: T1 = 0.645
# Erro da temperatura: T2 = 0.386
# Erro da temperatura: T3 = 0.423
# Erro da temperatura: T4 = 0.493

def readcal2():
    tunel = np.loadtxt("cal2/tunel.txt", delimiter=",").transpose()
    fbase = ["ponto-01", "ponto-02", "ponto-03", "ponto-05", "ponto-07",
             "ponto-10", "ponto-12", "ponto-16", "ponto-10b", "ponto-5b",
             "ponto-3b", "ponto-1b", "ponto-3c", "ponto-5c", "ponto-10c", "ponto-16c"]
    
    ftemp = ["cal2/" + f + "-temp.txt" for f in fbase]
    fvel = ["cal2/" + f + "-vel.txt" for f in fbase]

    temp = np.array([readmeasfile(f, 'IPT').mean(0) for f in ftemp])[:,1:]
    E =  np.array([readmeasfile(f, 'IPT').mean(0) for f in fvel])[:,1:] * 3.3/4095.0 - 0.146

    T = tunel[:,0]
    Pa = tunel[:,3]
    U = tunel[:,4]

    
    return U, E, T, Pa, temp


# Erro da temperatura: T1 = 0.50
# Erro da temperatura: T2 = 0.24
# Erro da temperatura: T3 = 0.27
# Erro da temperatura: T4 = 0.33


    
    

    

    
