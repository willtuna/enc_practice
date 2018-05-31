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

typedef struct Poly Poly;// forward declaration

typedef void  (*func_p)(Poly *);
typedef void  (*func_p_arr_i)(Poly *,int [], int);
typedef Poly* (*func_p_i)(Poly*, int);
typedef Poly* (*func_p_p_i)(Poly *, Poly *, int);
typedef Poly* (*func_p_p_p_i)(Poly *, Poly *, Poly *,int);

struct Poly {
    int * coef;
    int degree;
    func_p free,print;
    func_p_i scalar_mult;
    func_p_p_i add;
    func_p_p_p_i mult;
    func_p_arr_i set;
};


int table_size = 30;
int  poly_count = 0;

int  Poly_init(Poly** pt2pt);

void Poly_free(Poly* ptr);
void Poly_print(Poly* self);
Poly * Poly_scalar_mult(Poly * self, int multiplier);
Poly * Poly_add(Poly * self, Poly *ptr_b, int field_N);
Poly * Poly_mult(Poly *self, Poly *ptr_b, Poly* ptr_irr,int q);
void Poly_set(Poly *self, int [], int degree); 



/* ref 
print("encryption ...")
r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
cipher  = poly_ring_mult_over_q_with_irr(poly1_l=r_ccov_h.coef,poly2_l=[1],irr_l=irr_l,q=q)
print('cipher:',cipher)
*/
Poly ** poly_table = NULL;

int main(int argc , char** argv){
    poly_table = malloc(sizeof(Poly*) * table_size);
    Poly * poly_g;
    Poly * poly_f      ; 
    Poly * poly_f_inv_q; 
    Poly * poly_f_inv_p; 
    Poly * poly_key_pub; 
    Poly * poly_message; 
    Poly * poly_rand_sel;
    Poly * poly_irr_l  ; 

    Poly_init(& poly_g       );
    Poly_init(& poly_f       );
    Poly_init(& poly_f_inv_q );
    Poly_init(& poly_f_inv_p );
    Poly_init(& poly_key_pub );
    Poly_init(& poly_message );
    Poly_init(& poly_rand_sel);
    Poly_init(& poly_irr_l   );

    poly_g          -> set (poly_g        ,g        ,sizeof(g        )/sizeof(int) - 1 );
    poly_f          -> set (poly_f        ,f        ,sizeof(f        )/sizeof(int) - 1 );
    poly_f_inv_q    -> set (poly_f_inv_q  ,f_inv_q  ,sizeof(f_inv_q  )/sizeof(int) - 1 );
    poly_f_inv_p    -> set (poly_f_inv_p  ,f_inv_p  ,sizeof(f_inv_p  )/sizeof(int) - 1 );
    poly_key_pub    -> set (poly_key_pub  ,key_pub  ,sizeof(key_pub  )/sizeof(int) - 1 );
    poly_message    -> set (poly_message  ,message  ,sizeof(message  )/sizeof(int) - 1 );
    poly_rand_sel   -> set (poly_rand_sel ,rand_sel ,sizeof(rand_sel )/sizeof(int) - 1 );
    poly_irr_l      -> set (poly_irr_l    ,irr_l    ,sizeof(irr_l    )/sizeof(int) - 1 );


    printf("message:  ");
    poly_message -> print(poly_message);

    Poly* poly_scalmul = poly_rand_sel -> scalar_mult(poly_rand_sel, p) ;

    Poly* poly_mult    = poly_scalmul  -> mult(poly_scalmul, poly_key_pub, poly_irr_l, q);

    printf("mult:  ");
    poly_mult -> print(poly_mult);

    Poly* poly_cipher = poly_mult -> add ( poly_mult, poly_message, q);
    printf("Cipher:  ");
    poly_cipher -> print(poly_cipher);

    while(poly_count){
        int idx = --poly_count;
	poly_table[idx] -> free(poly_table[idx]);
        poly_table[idx] = NULL;
    }

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


int Poly_init(Poly** self){
    if(NULL == (*self= malloc(sizeof(Poly))) ) return EXIT_FAILURE;

    poly_table[poly_count] = (*self);
    poly_count++;
    if(poly_count == table_size){
	printf("Table is full\n");
        return EXIT_FAILURE;
    }
    

    (*self) ->coef   = NULL;
    (*self) ->degree = 0;

    (*self) ->free = Poly_free;   
    (*self) ->print = Poly_print;
    (*self) ->scalar_mult = Poly_scalar_mult;
    (*self) ->add   = Poly_add;
    (*self) ->mult  = Poly_mult;
    (*self) ->set   = Poly_set;
    return 0;
}




void Poly_free(Poly* ptr){
    if(ptr->coef != NULL ){
        free(ptr->coef);
        ptr->coef = NULL;
        ptr->degree = 0;
    }
}
void Poly_print(Poly* self){
    printf("Poly Coef:   ");
    printf("{");
    for(int idx=0; idx <= self->degree ; ++idx){
        if(idx != self->degree ){
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
        rtn->coef[idx]= (multiplier * self->coef[idx])%N;
    }
    return rtn;
}

Poly * Poly_add(Poly * ptr_a, Poly *ptr_b, int field_N){
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


Poly * Poly_mult(Poly *ptr_a, Poly *ptr_b, Poly* ptr_irr,int q){

    int rtn_idx = 0;
    int N = ptr_irr -> degree;
    int tmp;


    Poly * poly_rtn;
    Poly_init(& poly_rtn);
    poly_rtn -> coef = malloc(sizeof(int)*N);
    poly_rtn -> degree = N-1;

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
    for (int idx = N-1 ; idx >= 0 ; idx--){
	if(poly_rtn->coef[idx] != 0 ){
	    poly_rtn->degree = idx;
	    break;
        }
    }
    return poly_rtn;
}
void Poly_set(Poly *self, int arr[], int degree){
    self->coef = malloc(sizeof(int)*(degree+1) );
    for (int i = 0 ; i <= degree ; ++i){
        self->coef[i]=arr[i];
    }
    self->degree = degree;

} 
