def guardar(x, base):

    f1 =  base + "-vel.txt"
    f2 = base + "-temp.txt"

    fp1 = open(f1, "w")
    fp2 = open(f2, "w")

    u = [y for y in x["U"] if y[0:3]=="IPT"]
    t = [y for y in x["T"] if y[0:3]=="IPT"]

    
    fp1.writelines(u)
    fp1.close()
    
    fp2.writelines()
    fp2.close()


    
