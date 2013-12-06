import re

result = {
          '1' : 0 ,
          '2' : 0 
        }

# record example
# - 0.1 0 2 cbr 500 ------- 0 0.0 3.0 0 0

regex1 = re.compile(
    r"""^r.+\s0\s2.+-------\s1.+$""", re.VERBOSE)

regex2 = re.compile(
    r"""^r.+\s2\s3.+-------\s1.+$""", re.VERBOSE)

banda1 = 0
banda2 = 0

with open("exercicio_1.tr") as f:
    for line in f:
        match1 = regex1.match(line.strip())
        if match1:
            banda1 += 500.0
        match2 = regex2.match(line.strip())
        if match2:
            banda2 += 500.0

# print str(result)
print banda1 * 8
print banda2 * 8

result = (banda1 - banda2) / banda1

print result