#!/usr/bin/env python3


"""
simpledaq.py


Aquisição simples de dados que vêm em forma 
"""


import threading
import serial
import time


class Acquiring(threading.Thread):
    def __init__(self, s, ttot=1, header=b'IPT'):
        self.s = s
        threading.Thread.__init__(self)
        self.ttot = ttot
        self.nsamples = 0
        self.x = None
        self.done = False
        self.header = header
        
    def run(self):
        if self.s.isOpen():
            self.s.close()
        self.s.open()
        self.s.flushOutput()
        self.s.flushInput()
        self.x = []

        h = self.header
        nh = len(h)+1 # Compensar o '\t'
        
        t1 = time.time()
        t2 = t1 + self.ttot
        self.tend = t2
        self.taq = 0.0
        
        while True:
            ll = self.s.readline()
            idx = ll.find(h)
            if idx >= 0:
                self.x.append(ll[(idx+nh):].decode('ascii'))
                self.nsamples += 1
                self.taq = time.time()
                if self.taq >= t2:
                    break
        
        self.s.close()
        self.done = True
        
        
class SerialDAQ(object):

    
    def __init__(self, dev, header=b'IPT'):
        self.s = serial.Serial(dev, 9600)
        self.s.close()
        self.thrd = None
        self.dev = dev
        self.header = header
        
    def start(self, ttot = 1):
        self.thrd = Acquiring(self.s, ttot, self.header)
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

    def timeremaining(self):
        if self.thrd is not None:
            return self.thrd.tend - self.thrd.taq
        return 0.0
    
        
    def isAcquiring(self):
        if self.thrd is not None:
            return not self.thrd.done
        return False
    
    def acquire(self, ttot=1):
        self.start(ttot)
        return self.finish()
    

class Anemometer(object):

    def __init__(self, devu="/dev/velocidade", devt="/dev/temperatura"):
        self.vel = SerialDAQ(devu, b'IPT')
        self.temp = SerialDAQ(devt, b'IPT')
        
    def start(self, ttot=1):
        self.vel.start(ttot)
        self.temp.start(ttot)

    def finish(self):
        xvel = self.vel.finish()
        xtemp = self.temp.finish()
        return(dict(U=xvel, T=xtemp))
    def samplesread(self):
        return self.vel.samplesread(), self.temp.samplesread()
    def timeremaining(self):
        return self.vel.timeremaining()
    
    def isAcquiring(self):
        return self.vel.isAcquiring() or self.temp.isAcquiring()
    
                   
if __name__ == "__main__":
    import xmlrpc.server
    import argparse
    
    parser = argparse.ArgumentParser(description="Medida de velocidade")
    parser.add_argument("-i", "--ipaddr", action="store", 
                        default="localhost", help="IP do servidor XML-RPC")
    parser.add_argument("-p", "--port", action="store", type=int,
                        default=9597, help="Porta usada no servidor")
    parser.add_argument("-t", "--temp-com", action="store",
                        default="/dev/temperatura", help="COM da temperatura")
    parser.add_argument("-u", "--vel-com", action="store",
                        default="/dev/velocidade", help="COM da velocidade")
    
    args = parser.parse_args()

    ipaddr = args.ipaddr
    port = args.port
    tdev = args.temp_com
    udev = args.vel_com

    print("Conectando com os microcontroladores...")
    anem = Anemometer(udev, tdev)

    print("Iniciando o servidor XML-RPC")
    server = xmlrpc.server.SimpleXMLRPCServer( (ipaddr, port), allow_none=True)
    server.register_instance(anem)
    print("Servidor inicializado")
    server.serve_forever()
    

    
    
