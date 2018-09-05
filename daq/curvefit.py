import numpy as np


class PolyFit(object):

    def __init__(self, x, y, n=1):
        self.p = np.polyfit(x, y, n)

    def value(self, x):
        return np.polyval(self.p, x)
    def __call__(self, x):
        return self.value(x)
    def coefs(self):
        return self.p
    
class PowerFit(object):
    def __init__(self, x, y):
        lnx = np.log(x)
        lny = np.log(y)
        
        fit = np.polyfit(lnx, lny, 1)
                
        self.a = np.exp(fit[1])
        self.b = fit[0]
    def value(self, x):
        return self.a * x ** self.b
    def __call__(self, x):
        return self.value(x)
    
    def coefs(self):
        return [self.a, self.b]

class LogFit(object):
    def __init__(self, x, y):
        lnx = np.log(x)
        fit = np.polyfit(lnx, y, 1)
        self.a = fit[1]
        self.b = fit[0]
    def value(self, x):
        return self.a + self.b * np.log(x)
    def __call__(self, x):
        return self.value(x)
    
    def coefs(self):
        return [self.a, self.b]
    
        
        
    
        
