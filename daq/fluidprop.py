


class Gas(object):
    def __init__(self, R, ak, bk, ap, bp, C, T0, mu0):
        self.R = R
        self.ak = ak
        self.bk = bk
        self.ap = ap
        self.bp = bp
        self.C = C
        self.T0 = T0
        self.mu0 = mu0
        
        
    def heatcond(self, Tc=20.0, P=101.325):
        return 1e-3 * (self.ak + self.bk*Tc)
    def prandtl(self, Tc=20.0, P=101.325):
        return self.ap + self.bp*Tc
    def viscosity(self, Tc=20.0, P=101.325):
        C = self.C
        T0 = self.T0
        mu0 = self.mu0
        Tk = Tc + 273.15
        return mu0 * (T0 + C) / (Tk + C) * (Tk/T0)**1.5
    def density(self, Tc=20.0, P=101.325):
        return 1000*P / (self.R * (Tc + 273.15))
    def kinvis(self, Tc=20., P=101.325):
        return self.viscosity(Tc) / self.density(Tc, P)


air = Gas(287.06, 24.34607, 0.07526, 0.714296, -0.000268, 120.0, 291.15, 18.27e-6)


    
