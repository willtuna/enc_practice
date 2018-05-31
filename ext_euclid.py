import numpy as np
from fractions import gcd

# remainder version
# vec1 = np.asarray([1,0])
# vec2 = np.asarray([0,1])
# 
# rem1 = 233
# rem2 = 144
# 
# while True:
#     quo1,rem1 = divmod(rem1,rem2)
#     vec1 = vec1 - quo1*vec2
# 
#     if(rem1 == 0 ):
#         print("GCD=",rem2,vec2)
#         break
#     quo2,rem2 = divmod(rem2,rem1)
#     vec2 = vec2 - quo2*vec1
# 
#     if(rem2 == 0 ):
#         print("GCD=",rem1,vec1)
#         break

# Polynomial Version
from numpy.polynomial import Polynomial as P
#q = 2
#R1 = [1,0,0,0,0,1]
#R2 = [1,1,0,0,1]

q = 73
R1 = [1,0,0,0,0,0,0,0,0,0,0,0,1]
R2 = [-1,0,1,-1,0,0,0,0,1,0,1]
rem_poly1 = P(R1)
rem_poly2 = P(R2)

vec1 = [P([1]),P([0])]
vec2 = [P([0]),P([1])]

while True:
    quo1,rem_poly1 = divmod(rem_poly1,rem_poly2)
    rem_list =[]
    for idx,val in enumerate(rem_poly1.coef):
        rem_list.append( val % q)

    print("quo1", quo1, 'rem_poly1', rem_poly1)
    vec1[0] = vec1[0] - quo1*vec2[0]
    vec1[1] = vec1[1] - quo1*vec2[1]

    rem_poly1 = P(rem_list)
    a = rem_poly1.coef[-1]
    b = rem_poly2.coef[-1]
    rem_poly2 = rem_poly2*(a*b/gcd(a,b))

    if(rem_poly1 == P(0)):
        print("GCD = ", rem_poly2)
        print("Weight",vec2[0].coef, vec2[1].coef)
        break
    
    rem_list =[]
    quo2,rem_poly2 = divmod(rem_poly2,rem_poly1)
    for idx,val in enumerate(rem_poly2.coef):
        rem_list.append( val % q)



    rem_poly2 = P(rem_list)
    a = rem_poly1.coef[-1]
    b = rem_poly2.coef[-1]
    rem_poly1 = rem_poly1*(a,b/gcd(a,b))

    print("quo2", quo2, 'rem_poly2', rem_poly2)
    vec2[0] = vec2[0] - quo2*vec1[0]
    vec2[1] = vec2[1] - quo2*vec1[1]

    if(rem_poly2 == P(0)):
        print("GCD = ", rem_poly1)
        print('Weight', vec1[0].coef, vec1[1].coef)
        break


