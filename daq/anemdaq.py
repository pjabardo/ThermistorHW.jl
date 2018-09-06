"""
simpledaq.py


Aquisição simples de dados que vêm em forma 
"""


import threading
import serial
import time


class Acquiring(threading.Thread):
    def __init__(self, s, ttot=1):
        self.s = s
        threading.Thread.__init__(self)
        self.ttot = ttot
        self.nsamples = 0
        self.x = None
        self.done = False
        
    def run(self):
        if self.s.isOpen():
            self.s.close()
        self.s.open()
        self.x = []
        t1 = time.time()
        t2 = t1 + self.ttot
        while True:
            self.x.append(self.s.readline())
            self.nsamples += 1
            if time.time() >= t2:
                break
        self.s.close()
        self.done = True
        
        
class SerialDAQ(object):

    
    def __init__(self, dev):
        self.s = serial.Serial(dev, 9600)
        self.s.close()
        self.thrd = None
        self.dev = dev
        return None

    def start(self, ttot = 1):
        self.thrd = Acquiring(self.s, ttot)
        self.thrd.start()
        return None
    
    def finish(self):
        if self.thrd is not None:
            self.thrd.join()
            x = self.thrd.x
            self.thrd = None
            return x
        # Deveria jogar uma exceção?
        return None
    
    def samplesread(self):
        if self.thrd is not None:
            return self.thrd.nsamples
        return 0
    def isAcquiring(self):
        if self.thrd is not None:
            return not self.thrd.done
        return False
    
    def acquire(self, ttot=1):
        if self.s.isOpen():
            self.s.close()
        self.s.open()
        x = []
        t1 = time.time()
        t2 = t1 + ttot
        while True:
            x.append(self.s.readline())
            if time.time() >= t2:
                break
        self.s.close()
        return x
    

class Anemometer(object):

    def __init__(self, devu="/dev/velocidade", devt="/dev/temperatura"):
        self.vel = SerialDAQ(devu)
        self.temp = SerialDAQ(devt)
        
    def start(self, ttot=1):
        self.vel.start(ttot)
        self.temp.start(ttot)

    def finish(self):
        xvel = self.vel.finish()
        xtemp = self.temp.finish()
        xvel = [x.decode('ascii') for x in xvel]
        xtemp = [x.decode('ascii') for x in xtemp]
        return(dict(U=xvel, T=xtemp))
    def samplesread(self):
        return self.vel.samplesread(), self.temp.samplesread()
    
    def isAcquiring(self):
        return self.vel.isAcquiring() or self.temp.isAcquiring()
    
                   
