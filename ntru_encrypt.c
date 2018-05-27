#include <stdio.h>
#include <stdlib.h>

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
int irr_l    []=  {-1, 0, 0, 0, 0, 0, 1};

typedef struct {
    int * coef;
    int degree;
}Poly;

void Poly_init(Poly* ptr,int coef[], int deg ){
       ptr->degree = deg;
       ptr->coef = malloc(deg*sizeof(int));
       for(int idx=0;idx < deg ; ++idx){
           ptr->coef[idx] = coef[idx];
       }
}
void Poly_free(Poly* ptr){
    if(ptr->degree > 0){
        free(ptr->coef);
        ptr->degree = 0;
    }
}
void Poly_print(Poly* ptr){
    printf("Poly Coef:\n");
    printf("{");
    for(int idx=0; idx < ptr->degree ; ++idx){
        if(idx != ptr->degree -1){
            printf("%d ,",ptr->coef[idx]);
        }
        else{
            printf("%d },",ptr->coef[idx]);
        }
    }
}
void Poly_scalar_mult(Poly *rtn,Poly *ptr, int multiplier){
    for(int idx=0;idx < ptr->degree ; ++idx){
        rtn->coef[idx]= (multiplier * ptr->coef[idx])%N;
    }
}

void Poly_add(Poly *rtn,Poly *ptr_a, Poly *ptr_b){
    for(int idx =0 ; idx < ptr_a->degree ; ++idx)
        rtn->coef[idx] = (ptr_a->coef[idx]+ptr_b->coef[idx]) %N;
}

void Poly_mult(Poly * poly_rtn , Poly *ptr_a, Poly * ptr_b, Poly * ptr_irr){
    int rtn_idx = 0;

    for (int idx = 0 ; idx < ptr_a -> degree ; ++idx){
        for(int idy = 0 ; idy < ptr_b -> degree ; ++ idy){
            rtn_idx = (idx + idy)%N;
            poly_rtn->coef[rtn_idx] = (poly_rtn->coef[rtn_idx] + ptr_a->coef[idx] * ptr_b->coef[idx])%N;
        }
    }
}


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

    Poly poly_scalmul = {
        .degree=N-1 , 
        .coef= malloc((N-1)*sizeof(int))
    };
    Poly poly_mult= {
        .degree=N-1 , 
        .coef= malloc((N-1)*sizeof(int))
    };
    Poly poly_cipher= {
        .degree=N-1 , 
        .coef= malloc((N-1)*sizeof(int))
    };
    int n = sizeof(rand_sel)/sizeof(rand_sel[0]);
    Poly_init(&poly_rand_sel, rand_sel, n);

    n = sizeof(key_pub)/sizeof(key_pub[0]);
    Poly_init(&poly_key_pub,  key_pub , n);

    n = sizeof(irr_l)/sizeof(irr_l[0]);
    Poly_init(&poly_irr_l,  irr_l , n);

    n = sizeof(message)/sizeof(message[0]);
    Poly_init(&poly_message ,  message, n);

    Poly_scalar_mult(&poly_scalmul,&poly_rand_sel, p);
    Poly_print(&poly_scalmul);

    Poly_mult( &poly_mult, &poly_scalmul, &poly_key_pub, &poly_irr_l);
    Poly_print(&poly_mult);

    printf("DEBUG poly_mult\n");
    Poly_add ( &poly_cipher , &poly_mult, &poly_message);
    Poly_print(&poly_cipher);


    Poly_free(&poly_rand_sel);
    Poly_free(&poly_cipher);
    Poly_free(&poly_key_pub);
    Poly_free(&poly_irr_l);

    Poly_free(&poly_scalmul);
    Poly_free(&poly_mult);
    return 0;
}