import re
import csv
import os

# record example
# - 0.1 0 2 cbr 500 ------- 0 0.0 3.0 0 0

regex = re.compile(
    r"""^d\s(?P<tempo>.+)\s\d\s\d\s.+$""", re.VERBOSE)

files = [
  'out-ex2-w=20-q=10.tr',
  'out-ex2-w=20-q=30.tr',
  'out-ex2-w=40-q=10.tr',
  'out-ex2-w=40-q=30.tr'
]
def parse(file):
  result = {}
  tempo = 0;

  with open(file) as f:
      for line in f:
          match = regex.match(line.strip())
          if match:
              key = str(round(float(match.group("tempo")),1))
              if key in result:
                result[key] += 1.0
              else:
                result[key] = 1.0

  with open(file + ".csv", 'wb') as out:
    for k,v in sorted(result.iteritems()):
      out.write(str(k) + "," + str(v) + "\n")

for f in files:
  parse(f)

os.system("gnuplot 'out-graph.gnu'")