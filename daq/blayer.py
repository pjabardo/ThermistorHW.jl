import anemometer as A
import xmlrpc.client
import time


def guardar(x, base):

    f1 =  base + "-vel.txt"
    f2 = base + "-temp.txt"

    fp1 = open(f1, "w")
    fp2 = open(f2, "w")

    u = [y for y in x["U"] if y[0:3]=="IPT"]
    t = [y for y in x["T"] if y[0:3]=="IPT"]

    
    fp1.writelines(u)
    fp1.close()
    
    fp2.writelines(t)
    fp2.close()

class BLayer(object):
    def __init__(self):
        self.dev = A.Anemometer("/dev/ttyUSB0", "/dev/ttyUSB1")
        self.robo = xmlrpc.client.ServerProxy("http://192.168.0.101:9595")
    def move(self, z, zref=30):
        self.robo.move(0,0,z-zref, False, False, True)
    def acquire(self, pt=0, ttot=30):
        self.dev.start(ttot)
        x = self.dev.finish()
        fbase = "ponto-" + str(pt+1000)[1:]
        guardar(x, fbase)
    def blayer(self, zh=[30, 40, 80, 100, 120, 140, 160, 180, 200, 240, 280, 320, 360, 400, 440, 460, 500], ttot=60):

        for z in zh:
            print("z = "+ str(z))
            self.move(z)
            time.sleep(5)
            self.acquire(z, ttot)
            
        

