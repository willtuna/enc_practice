#! /usr/bin/python3
import random 
import numpy as np
from numpy.polynomial import Polynomial as P

random.seed(100)
# print ("current state of prng: " + str(random.getstate()) )
# undone customize exception handling 
'''
class Param_Error (Exception):
    def __init__(self,message, errors):
        super().__init__(message)
        self.errors = errors
'''
# Ternary Function
# Comment: 
# Having a better version : Shuffling the concatenate [1]*d1 + [-1]*d2 + [0]*(N-d1-d2)
def coefficient_init (degree_int,d1_int,d2_int):
    if(degree_int < (d1_int + d2_int)):
        print("Error : degree_int < d1_int + d2_int")

    r_seq = [0]*degree_int
    idx = 0
    while True:
        if(idx == degree_int):
            idx = 0

        if(r_seq[idx] == 0):
            if(d1_int & d2_int):
                die_rollout=(random.randint(0,2))
                if(die_rollout%3 == 0):
                    r_seq[idx] = -1
                    d2_int -=1
                elif(die_rollout%3 == 1):
                    pass
                else:
                    r_seq[idx] = 1
                    d1_int -=1
            elif(d1_int):
                die_rollout=(random.randint(0,1))
                if(die_rollout%2):
                    r_seq[idx] = 1
                    d1_int -= 1
                else:
                    pass
            elif(d2_int):
                die_rollout=(random.randint(0,1))
                if(die_rollout%2):
                    r_seq[idx] = -1
                    d2_int -= 1
                else:
                    pass
            else:# both be 0
                break

        idx +=1
        if(d1_int ==0 and d2_int ==0):
            break

    print("Return Sequence :\n"+'  '.join(str(c) for c in r_seq ))
    return r_seq


# Modulus Inverse
def inv_mod_N(a,N):
    vec1 = np.asarray([1,0])
    vec2 = np.asarray([0,1])
    rem1 = a % N
    rem2 = N
    
    while True:
        quo1,rem1 = divmod(rem1,rem2)
        vec1 = vec1 - quo1*vec2
    
        if(rem1 == 0 ):
            if(rem2 != 1):
                print('No Inverse')
                return N# Use as flag
            return vec2[0]

        quo2,rem2 = divmod(rem2,rem1)
        vec2 = vec2 - quo2*vec1
    
        if(rem2 == 0 ):
            if(rem1 != 1):
                print('No Inverse')
                return N
            return vec1[0]

def poly_modN(polya, N):
    li = []
    for val in polya.coef:
        li.append(val % N)
    return P(li)

# Polynomial Division By Polynomial Ring
def polynomial_div_modN(dividend, divisor, N):
    print("dividend:",dividend)
    print("divisor :",divisor)
    acc  = P(0)
    while True:
        dividend = poly_modN(dividend,N)
        divisor  = poly_modN(divisor,N)
        deg_diff = dividend.degree() - divisor.degree()
        if(deg_diff < 0 or dividend == P(0)):
            return acc ,dividend
        else:
            if inv_mod_N(divisor.coef[-1],N) == N :# No Inverse Flag
                coef =dividend.coef[-1]/divisor.coef[-1]
            else:# coef must be coprime to N
                coef = dividend.coef[-1] * inv_mod_N(divisor.coef[-1],N)
            print('inverse  of',divisor.coef[-1],':',coef)

            mult = [0]*(deg_diff+1)# from x^deg_diff to x^0
            mult[-1] = coef
            poly_mult = P(mult)
            acc += poly_mult
            #acc = poly_modN(acc,N)
            #print(" A  ",dividend.coef)
            #print("-B: ",poly_modN(poly_mult*divisor,N).coef,'=',poly_mult.coef,'x',divisor.coef)
            dividend = dividend - poly_mult*divisor
            #print(" Remainder  ",dividend.coef)

#            print("LEN Dividend:",len(dividend.coef),"  LEN divisor:",len(divisor.coef))
#            if len(dividend.coef) == len(divisor.coef):
#                print("EQUAL")
#                return acc ,dividend

# Ring Multiplication
def poly_ring_mult_over_q_with_irr(poly1,poly2,irr,q):
    tmp_poly = poly1*poly2
    tmp_irr  = irr
    quo,rem = divmod(tmp_poly,tmp_irr)

    result = np.zeros_like(rem.coef)
    for idx,val in enumerate(rem.coef):
        val = val % q
        if(val < 0):
            result[idx] = val + q
        else:
            result[idx] = val
    return result

# Ring Polynomial Inverse
def inv_poly(rem_poly1,rem_poly2,q):
    vec1 = [P([1]),P([0])]
    vec2 = [P([0]),P([1])]

    while True:
        quo1,rem_poly1 = polynomial_div_modN(rem_poly1,rem_poly2,q)
        rem_list =[]

        for idx,val in enumerate(rem_poly1.coef):
            rem_list.append( val % q)

        rem_poly1 = P(rem_list)
        #print("quo1", quo1.coef, 'rem_poly1', rem_poly1.coef)
        vec1[0] = vec1[0] - quo1*vec2[0]
        vec1[1] = vec1[1] - quo1*vec2[1]
        #print("vec1[0]", vec1[0].coef, 'vec1[1]', vec1[1].coef)


        if(rem_poly1.degree() == 0):
            print("GCD = ", rem_poly1.coef)
            inv = inv_mod_N(rem_poly1.coef[0],q)
            return poly_modN(vec1[1]*inv,q)

        rem_list =[]
        quo2,rem_poly2 = polynomial_div_modN(rem_poly2,rem_poly1,q)
        for idx,val in enumerate(rem_poly2.coef):
            rem_list.append( val % q)

        rem_poly2 = P(rem_list)

        #print("quo2", quo2.coef, 'rem_poly2', rem_poly2.coef)
        vec2[0] = vec2[0] - quo2*vec1[0]
        vec2[1] = vec2[1] - quo2*vec1[1]
        #print("vec2[0]", vec2[0].coef, 'vec2[1]', vec2[1].coef)

        if(rem_poly2.degree() == 0):
            print("GCD = ", rem_poly2.coef)
            inv = inv_mod_N(rem_poly2.coef[0],q)
            return (poly_modN(vec2[1]*inv,q))

# Encryption
# msg = "Hello This is test"
# hex_msg = ''.join(r'\x'+str(ord(c)) for c in msg)
# hex_msg_arr = [str(ord(c)) for c in msg]
# print(hex_msg)
# print(hex_msg_arr)
# 
# 
# print ("Coeffiecient Init")
# degree = int( input("Enter degree :") )
# d1     = int( input("Enter d1 :")     )
# d2     = int( input("Enter d2 :")     )
# random_seq = coefficient_init(degree_int=degree,d1_int=d1, d2_int=d2)

#  Introduction to Cryptography Textbook
#print('public_param:')
#N = 7
#p = 3
#q =41
#d = 2
#g        =  [ 0,-1,-1, 0, 1, 0, 1]
#f        =  [-1, 0, 1, 1,-1, 0, 1]
#f_inv_q  =  [37, 2,40,21,31,26, 8]
#f_inv_p  =  [ 1, 1, 1, 1, 0, 2, 1]
#key_pub  =  [30,26, 8,38, 2,40,20]
#message  =  [1 ,-1, 1, 1, 0,-1]
#rand_sel =  [-1, 1, 0, 0, 0,-1, 1]
def main():
    N = 11
    q = 32
    p = 3
#         0 1 2 3 4  5 6 7 8 9 10 11
    f = [-1,1,1,0,-1,0,1,0,0,1,-1]
    g = [-1,0,1,1,0,1,0,0,-1,0,-1]
#             0 1 2 3 4 5 6 7 8 9 10 11
    irr_l = [-1,0,0,0,0,0,0,0,0,0,0 ,1]

    f_inv_p = inv_poly(P(irr_l),P(f),p)
    print("f_inv_p",f_inv_p.coef)
    check = poly_ring_mult_over_q_with_irr(f_inv_p,f,P(irr_l),p)
    print("Check",check)

#   First Doing the inv_poly in p then extend to p^e
    exponent = 5
    base_prime = 2
    f_inv_base_prime = inv_poly(P(irr_l),P(f), base_prime)
    n_tmp = 2
    b_poly = f_inv_base_prime
    while exponent > 0:
        b_square = b_poly * b_poly
        b_poly = 2*b_poly- poly_ring_mult_over_q_with_irr(P(f),b_square,P(irr_l),base_prime**n_tmp)
        exponent = exponent // 2
        n_tmp = 2*n_tmp
    f_inv_q = poly_modN(b_poly,q)
     
    print("f_inv_q",f_inv_q.coef)
    check = poly_ring_mult_over_q_with_irr(f_inv_q,f,P(irr_l),q)
    print("Check",check)
    return 0
    key_pub = p*f_inv_q*P(g)
    print("Pulic Key:",key_pub.coef)


    irr_l =[]
    for i in range(N+1):
        if(i == N):
            irr_l.append(1)
        elif(i==0):
            irr_l.append(-1)
        else:
            irr_l.append(0)
    irr = P(irr_l)



    # e(x) = p*r(x)*h(x) + m(x) (mod q)scalmul
    print("encryption ...")
    r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
    cipher  = poly_ring_mult_over_q_with_irr(poly1=r_ccov_h,poly2=P([1]),irr=P(irr_l),q=q)
    print('cipher:',cipher)


    # f(x)*e(x)
    print("decryption ....")
    fq_mult_e = poly_ring_mult_over_q_with_irr(poly1=P(f), poly2=P(cipher) , irr=P(irr_l),q=q)
    print("f(x)*e(x)",fq_mult_e)
    aft_cent_lift_q = []
    for idx,val in enumerate(fq_mult_e):
        if(val > q//2):
            aft_cent_lift_q.append(val-q)
        else:
            aft_cent_lift_q.append(val)
    print("center lifting over q",aft_cent_lift_q)

    fp_mult_a = poly_ring_mult_over_q_with_irr(poly1=P(aft_cent_lift_q), poly2=P(f_inv_p) , irr=P(irr_l),q=p)
    print("Fp mult a", fp_mult_a)

    aft_cent_lift_p = []
    for idx,val in enumerate(fp_mult_a):
        if(val > p//2):
            aft_cent_lift_p.append(val-p)
        else:
            aft_cent_lift_p.append(val)
    print("center lifting over p",aft_cent_lift_p)


#irr_l =[]
#for i in range(N+1):
#    if(i == N):
#        irr_l.append(1)
#    elif(i==0):
#        irr_l.append(-1)
#    else:
#        irr_l.append(0)
#irr = P(irr_l)
#
#
#
## e(x) = p*r(x)*h(x) + m(x) (mod q)scalmul
#print("encryption ...")
#r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
#cipher  = poly_ring_mult_over_q_with_irr(poly1=r_ccov_h,poly2=P([1]),irr=P(irr_l),q=q)
#print('cipher:',cipher)
#
#
## f(x)*e(x)
#print("decryption ....")
#fq_mult_e = poly_ring_mult_over_q_with_irr(poly1=P(f), poly2=P(cipher) , irr=P(irr_l),q=q)
#print("f(x)*e(x)",fq_mult_e)
#aft_cent_lift_q = []
#for idx,val in enumerate(fq_mult_e):
#    if(val > q//2):
#        aft_cent_lift_q.append(val-q)
#    else:
#        aft_cent_lift_q.append(val)
#print("center lifting over q",aft_cent_lift_q)
#
#fp_mult_a = poly_ring_mult_over_q_with_irr(poly1=P(aft_cent_lift_q), poly2=P(f_inv_p) , irr=P(irr_l),q=p)
#print("Fp mult a", fp_mult_a)
#
#aft_cent_lift_p = []
#for idx,val in enumerate(fp_mult_a):
#    if(val > p//2):
#        aft_cent_lift_p.append(val-p)
#    else:
#        aft_cent_lift_p.append(val)
#print("center lifting over p",aft_cent_lift_p)
#
if __name__ == "__main__":
    main()