#include <stdio.h>
#include <stdlib.h>
//#define DBG 0
int N = 7;
int p = 3;
int q =41;
int d = 2;

int g        []=  { 0,-1,-1, 0, 1, 0, 1};
int f        []=  {-1, 0, 1, 1,-1, 0, 1};
int f_inv_q  []=  {37, 2,40,21,31,26, 8};
int f_inv_p  []=  { 1, 1, 1, 1, 0, 2, 1};
int key_pub  []=  {30,26, 8,38, 2,40,20};
int message  []=  {1 ,-1, 1, 1, 0,-1   };
int rand_sel []=  {-1, 1, 0, 0, 0,-1, 1};
int irr_l    []=  {-1, 0, 0, 0, 0, 0, 0, 1};

typedef Poly* (*func_p)(Poly *);
typedef Poly* (*func_p_i)(Poly *. Poly*, int);
typedef Poly* (*func_p_p_i)(Poly *, Poly *, int);
typedef Poly* (*func_p_p_p_i)(Poly *, Poly *, Poly *,int);

typedef struct {
    int * coef;
    int degree;
    func_p free,print;
    func_p_i scalar_mult;
    func_p_p_i add;
    func_p_p_p_i mult;
}Poly;


void Poly_init(Poly** pt2pt);

void Poly_free(Poly* ptr);
void Poly_print(Poly* self);
Poly * Poly_scalar_mult(Poly * self, int multiplier);
Poly * Poly_add(Poly * self, Poly *ptr_b, int field_N);
Poly * Poly_mult(Poly *self, Poly *ptr_b, Poly* ptr_irr,int q);



/* ref 
print("encryption ...")
r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
cipher  = poly_ring_mult_over_q_with_irr(poly1_l=r_ccov_h.coef,poly2_l=[1],irr_l=irr_l,q=q)
print('cipher:',cipher)
*/


int main(int argc , char** argv){
    Poly poly_g;
    Poly poly_f      ; 
    Poly poly_f_inv_q; 
    Poly poly_f_inv_p; 
    Poly poly_key_pub; 
    Poly poly_message; 
    Poly poly_rand_sel;
    Poly poly_irr_l  ; 

    Poly poly_scalmul; 
    Poly poly_mult   ;
    Poly poly_cipher ;
    Poly_init(&poly_scalmul, NULL , 6);   
    Poly_init(&poly_mult, NULL , 6);   
    Poly_init(&poly_cipher, NULL , 6);   

    int n = sizeof(rand_sel)/sizeof(rand_sel[0]);
    Poly_init(&poly_rand_sel, rand_sel, n-1);

    n = sizeof(key_pub)/sizeof(key_pub[0]);
    Poly_init(&poly_key_pub,  key_pub , n-1);

    n = sizeof(irr_l)/sizeof(irr_l[0]);
    Poly_init(&poly_irr_l,  irr_l , n-1);

    n = sizeof(message)/sizeof(message[0]);
    Poly_init(&poly_message ,  message, n-1);
    printf("message:  ");
    Poly_print(&poly_message);

    Poly_scalar_mult(&poly_scalmul,&poly_rand_sel, p);
    Poly_mult( &poly_mult, &poly_scalmul, &poly_key_pub, & poly_irr_l,q);

    printf("mult:  ");
    Poly_print(&poly_mult);

    Poly_add ( &poly_cipher , &poly_mult, &poly_message, q);
    printf("Cipher:  ");
    Poly_print(&poly_cipher);


    Poly_free(&poly_rand_sel);
    Poly_free(&poly_cipher);
    Poly_free(&poly_key_pub);
    Poly_free(&poly_irr_l);

    Poly_free(&poly_scalmul);
    Poly_free(&poly_mult);
    return 0;
}





/* ref
typedef struct {
    int * coef;
    int degree;

    func_p free,
           print;
    func_p_i scalar_mult;
    func_p_p_i add;
    func_p_p_p_i mult;
}Poly;
*/


void Poly_init(Poly** self){
    if(NULL == *self= malloc(sizeof(Poly)) ) return -1;

    (*self) ->coef   = NULL;
    (*self) ->degree = 0;

    (*self) ->free = Poly_free;   
    (*self) ->print = Poly_print;
    (*self) ->scalar_mult = Poly_scalar_mult;
    (*self) ->add   = Poly_scalar_mult;
    (*self) ->mult  = Poly_mult;
}




void Poly_free(Poly* ptr){
    if(ptr->coef != NULL ){
        free(ptr->coef);
        ptr->coef = NULL;
        ptr->degree = 0;
    }
}
void Poly_print(Poly* self);
    printf("Poly Coef:   ");
    printf("{");
    for(int idx=0; idx <= self->degree ; ++idx){
        if(idx != ptr->degree ){
            printf("%d ,",self ->coef[idx]);
        }
        else{
            printf("%d }\n",self->coef[idx]);
        }
    }
}


Poly * Poly_scalar_mult(Poly * self, int multiplier){
    Poly * rtn;
    Poly_init(&rtn);   
    rtn -> coef = malloc( sizeof(int)*(self->degree+1) );
    rtn -> degree = self->degree;
    for(int idx=0;idx <= self->degree ; ++idx){
        rtn->coef[idx]= (multiplier * ptr->coef[idx])%N;
    }
    return rtn;
}

Poly * Poly_add(Poly * self, Poly *ptr_b, int field_N);
    Poly * large_ptr = (ptr_a -> degree > ptr_b -> degree ) ? ptr_a  : ptr_b ;
    Poly * small_ptr = (ptr_a -> degree > ptr_b -> degree ) ? ptr_b : ptr_a;

    Poly * rtn;
    Poly_init(&rtn);   
    rtn -> coef = malloc( sizeof(int)*(large_ptr->degree+1) );
    rtn -> degree = large_ptr->degree;

    for(int idx =0 ; idx <= large_ptr -> degree ; ++idx){
        if ( idx > small_ptr-> degree)
            rtn -> coef[idx] = large_ptr -> coef[idx];
        else
            rtn -> coef[idx] = (large_ptr->coef[idx]+ small_ptr->coef[idx]) % field_N;
    }
    return rtn;
}


Poly * Poly_mult(Poly *self, Poly *ptr_b, Poly* ptr_irr,int q){
    int rtn_idx = 0;
    int N = ptr_irr -> degree;
    int tmp;
#ifdef DBG
    printf("poly rnt:"); Poly_print(poly_rtn);
    printf("ptr_a");     Poly_print(ptr_a);
    printf("ptr_b");     Poly_print(ptr_b);
    printf("ptr_irr");   Poly_print(ptr_irr);
#endif

    for (int idx = 0 ; idx <= ptr_a -> degree ; ++idx){
        for(int idy = 0 ; idy <= ptr_b -> degree ; ++ idy){
            rtn_idx = (idx + idy)%N;
#ifdef DBG
            printf("\n(%d + %d * %d )mod N ",  poly_rtn -> coef[rtn_idx], ptr_a -> coef[idx], ptr_b->coef[idy]);
#endif
            tmp  = (poly_rtn->coef[rtn_idx] + ptr_a->coef[idx] * ptr_b->coef[idy])%q;
            if(tmp <0)
                poly_rtn->coef[rtn_idx] = tmp + q;
            else
                poly_rtn->coef[rtn_idx] = tmp;
#ifdef DBG
            printf("poly_rtn[%d] = %d \n", rtn_idx, poly_rtn -> coef[rtn_idx]);
#endif
        }
    }
}