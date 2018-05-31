import numpy as np

vec1 = np.asarray([1,0])
vec2 = np.asarray([0,1])

rem1 = 233
rem2 = 144

while True:
    quo1,rem1 = divmod(rem1,rem2)
    vec1 = vec1 - quo1*vec2

    if(rem1 == 0 ):
        print("GCD=",rem2,vec2)
        break
    quo2,rem2 = divmod(rem2,rem1)
    vec2 = vec2 - quo2*vec1

    if(rem2 == 0 ):
        print("GCD=",rem1,vec1)
        break

