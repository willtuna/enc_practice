#%%
import random 
import numpy as np
#from numpy.polynomial.polynomial import polyval # This is for polynomial evaluation

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

# test ring_mult
#poly_arr_a = [1 ,-2,0 ,4 ,-1]
#poly_arr_b = [3 ,4 ,-2,5 ,2 ]
#irr_poly =   [-1,0 ,0 ,0 ,0 ,1 ]
#
#mod_int_N = 11
#result = ring_mult(poly_arr_a, poly_arr_b, irr_poly,mod_int_N)

print('public_param:')
N = 7
p = 3
q =41
d = 2

g        =  [ 0,-1,-1, 0, 1, 0, 1]
f        =  [-1, 0, 1, 1,-1, 0, 1]
f_inv_q  =  [37, 2,40,21,31,26, 8]
f_inv_p  =  [ 1, 1, 1, 1, 0, 2, 1]
key_pub  =  [30,26, 8,38, 2,40,20]
message  =  [1 ,-1, 1, 1, 0,-1]
rand_sel =  [-1, 1, 0, 0, 0,-1, 1]
irr_l =[]
for i in range(N+1):
    if(i == N):
        irr_l.append(1)
    elif(i==0):
        irr_l.append(-1)
    else:
        irr_l.append(0)
irr = P(irr_l)

# Polynomial Mult for Irr = X^6-1 Only
#tmp_poly = P(f_inv_q)*P(g)
#tmp_poly_7_13  = np.zeros((7,))
#tmp_poly_0_6 = tmp_poly.coef[:7]
#for idx,val in enumerate(tmp_poly.coef[7:]):
#    tmp_poly_7_13[idx] = val
#
#sum = tmp_poly_7_13+tmp_poly_0_6
#for idx,val in enumerate(sum):
#    val = val % q
#    if(val < 0):
#        sum[idx] = val + p
#    else:
#        sum[idx] = val
#print("f_inv_q conv g", sum)
#print("ans:          ", P(key_pub))

def poly_ring_mult_over_q_with_irr(poly1_l,poly2_l,irr_l,q):
    tmp_poly = P(poly1_l)*P(poly2_l)
    tmp_irr  = P(irr_l)
    quo,rem = divmod(tmp_poly,tmp_irr)
    #if(q == q):
    #    print("mult:",tmp_poly.coef)
    #    print("rem :",rem.coef)
    result = np.zeros_like(rem.coef)
    for idx,val in enumerate(rem.coef):
        val = val % q
        if(val < 0):
            result[idx] = val + q
        else:
            result[idx] = val
    return result

# e(x) = p*r(x)*h(x) + m(x) (mod q)scalmul
print("encryption ...")
r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
cipher  = poly_ring_mult_over_q_with_irr(poly1_l=r_ccov_h.coef,poly2_l=[1],irr_l=irr_l,q=q)
print('cipher:',cipher)


# f(x)*e(x)
print("decryption ....")
fq_mult_e = poly_ring_mult_over_q_with_irr(poly1_l=f, poly2_l=cipher , irr_l=irr_l,q=q)
print("f(x)*e(x)",fq_mult_e)
aft_cent_lift_q = []
for idx,val in enumerate(fq_mult_e):
    if(val > q//2):
        aft_cent_lift_q.append(val-q)
    else:
        aft_cent_lift_q.append(val)
print("center lifting over q",aft_cent_lift_q)

fp_mult_a = poly_ring_mult_over_q_with_irr(poly1_l=aft_cent_lift_q, poly2_l=f_inv_p , irr_l=irr_l,q=p)
print("Fp mult a", fp_mult_a)

aft_cent_lift_p = []
for idx,val in enumerate(fp_mult_a):
    if(val > p//2):
        aft_cent_lift_p.append(val-p)
    else:
        aft_cent_lift_p.append(val)
print("center lifting over p",aft_cent_lift_p)


        
