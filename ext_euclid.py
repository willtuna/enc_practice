import numpy as np
from fractions import gcd
from numpy.polynomial import Polynomial as P

def inv_mod_N(a,N):
    vec1 = np.asarray([1,0])
    vec2 = np.asarray([0,1])
    
    rem1 = a
    rem2 = N
    
    while True:
        quo1,rem1 = divmod(rem1,rem2)
        vec1 = vec1 - quo1*vec2
    
        if(rem1 == 0 ):
            return vec2[0]

        quo2,rem2 = divmod(rem2,rem1)
        vec2 = vec2 - quo2*vec1
    
        if(rem2 == 0 ):
            return vec1[0]
def poly_modN(polya, N):
    li = []
    for val in polya.coef:
        li.append(val % N)
    return P(li)

# Polynomial Version
def polynomial_div_modN(dividend, divisor, N):
    acc  = P(0)
    while True:
        dividend = poly_modN(dividend,N)
        divisor  = poly_modN(divisor,N)
        deg_diff = dividend.degree() - divisor.degree()
        if(deg_diff < 0 or dividend == P(0) ):
            return acc ,dividend
        else:
            coef = dividend.coef[-1] * inv_mod_N(divisor.coef[-1],N)
            mult = [0]*(deg_diff+1)
            mult[-1] = coef
            poly_mult = P(mult)
            acc += poly_mult
            acc = poly_modN(acc,N)
            print(" A  ",dividend.coef)
            print("-B: ",(poly_mult*divisor).coef)
            dividend = dividend - poly_mult*divisor


q = 73
R1 = [-1,0,0,0,0,0,0,0,0,0,0,0,1]
R2 = [-1,0,1,-1,0,0,0,0,1,0,1]
# Test Pass
rem_poly1 = P(R1)
rem_poly2 = P(R2)
#quo,rem = polynomial_div_modN(rem_poly1,rem_poly2,q)
#print("R1",rem_poly1.coef ,'divide R2',rem_poly2.coef)
#print("Quotient",quo.coef)
#print("Remainder",rem.coef)

vec1 = [P([1]),P([0])]
vec2 = [P([0]),P([1])]

while True:
    quo1,rem_poly1 = polynomial_div_modN(rem_poly1,rem_poly2,q)
    rem_list =[]
    for idx,val in enumerate(rem_poly1.coef):
        rem_list.append( val % q)

    print("quo1", quo1.coef, 'rem_poly1', rem_poly1.coef)
    vec1[0] = vec1[0] - quo1*vec2[0]
    vec1[1] = vec1[1] - quo1*vec2[1]

    rem_poly1 = P(rem_list)

    if(rem_poly1 == P(0)):
        print("GCD = ", rem_poly2)
        print("Weight", poly_modN(vec2[0],q))
        break
    
    rem_list =[]
    quo2,rem_poly2 = polynomial_div_modN(rem_poly2,rem_poly1,q)
    for idx,val in enumerate(rem_poly2.coef):
        rem_list.append( val % q)

    rem_poly2 = P(rem_list)

    print("quo2", quo2.coef, 'rem_poly2', rem_poly2.coef)
    vec2[0] = vec2[0] - quo2*vec1[0]
    vec2[1] = vec2[1] - quo2*vec1[1]

    if(rem_poly2 == P(0)):
        print("GCD = ", rem_poly1)
        print('Weight', poly_modN(vec1[0],q))
        break


