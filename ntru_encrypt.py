import random 

random.seed(100)
# print ("current state of prng: " + str(random.getstate()) )
# undone customize exception handling 
'''
class Param_Error (Exception):
    def __init__(self,message, errors):
        super().__init__(message)
        self.errors = errors
'''

#Need Think the algorithm to build up this ring multiplication
def ring_mult(poly_arr_a, poly_arr_b, irr_poly,mod_int_N):
    degree = len(irr_poly)
    result = [0]*(degree-1)
    for idx_a,a_int in enumerate(poly_arr_a):
        for idx_b,b_int in enumerate(poly_arr_b):
            tmp_idx = idx_a + idx_b
            if tmp_idx >= degree:
                tmp_idx = tmp_idx % degree
                for idx_irr, val_irr in enumerate(irr_poly):
                    if(idx_irr == (degree -1)):
                        break
                    result[(idx_irr+tmp_idx)%degree] += (-val_irr*(a_int*b_int) )%mod_int_N
            else:
                print("degree:"+str(degree))
                print("tmp_idx:"+str(tmp_idx))
                result[tmp_idx] += (a_int * b_int)%mod_int_N
    print("mult result:")
    print(result)
    return result

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
poly_arr_a = [1 ,-2,0 ,4 ,-1]
poly_arr_b = [3 ,4 ,-2,5 ,2 ]
irr_poly =   [-1,0 ,0 ,0 ,0 ,1 ]

mod_int_N = 11
result = ring_mult(poly_arr_a, poly_arr_b, irr_poly,mod_int_N)





































