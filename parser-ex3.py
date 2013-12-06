import re
import os

# record example
# - 0.1 0 2 cbr 500 ------- 0 0.0 3.0 0 0
# + 3.905333 3 8 cbr 1000 ------- 4 3.0 7.0 10 10

result = {}
ends = [['11','5'],['10','6'],['10','4'],['9','7']]

files =  [ open("out-ex3-flow1.csv", 'wb') 
, open("out-ex3-flow2.csv",'wb') 
, open("out-ex3-flow3.csv",'wb')
, open("out-ex3-flow4.csv",'wb') ]

bandas = [ 0 , 0 , 0 , 0 ] 
tempos = [ 0 , 0 , 0 , 0 ]

with open("out-ex3.tr") as f:
    for line in f:
        inf = line.split()
        if inf[0] == 'r':
            origin = inf[2]
            dest = inf[3]
            flow = int(inf[7])
            if [origin,dest] in ends:
                bandas[flow-1] += float(inf[5]) * 8
                if float(inf[1]) >= tempos[flow-1]:
                    files[flow-1].write(str(tempos[flow-1]) + "," + format(bandas[flow-1]/1000000.0,'.5f') + "\n")
                    tempos[flow-1] += 1
                    bandas[flow-1] = 0

for f in files:
    f.close()

os.system("gnuplot 'out-graph-ex3.gnu'")

print result