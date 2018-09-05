import numpy as np

class Thermistor(object):

    def __init__(self, R0=5e3, B=3470.0, T0=25.0):
        self.R0 = R0
        self.T0 = T0
        self.T0k = T0 + 273.15
        self.B = B

    def resistance(self, T=25.0):
        return self.R0 * np.exp(self.B * (1.0/(T+273.15) - 1/self.T0k))
    
    def __call__(self, T=25.0):
        return self.resistance(T)

    def temp(self, R):
        B = self.B
        T0 = self.T0k
        R0 = self.R0
        Tk = (1.0 / (1/B * np.log(R/R0) + 1/T0)) 
        return Tk - 273.15
        
        
