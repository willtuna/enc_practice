#include <stdio.h>
#include <stdlib.h>
#include "bit2tritCon/char2trit_lib.h"
//#define DBG 0
int N = 7;
int p = 3;
int q =128;
int d = 2;

int f        []=  {-1,0,0,-1,1,0,1,0,0,1,-1,0,0,1,0,-1,1,1,0,1,0,-1,0,0,0,0,-1};
int g        []=  {0,1,0,-1,0,0,1,0,0,-1,1,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,-1,-1,-1,-1 };

int f_inv_q  []= { 43,118,82,111,124,16,107,97,61,34,60,48,52,18,25,92,83,32,34,36,9,81,3,111,41,45,80,70,30,65,124,51,67,35,103,44,101,102,3,19,98,97,120,85,59,94,67,104,92,18,34,76,72,70,119,100,112,0,93,91,18,31,74,72,65,69,122,88,40,66,72,48,68,55,39,58,67,89,68,110,98,107,110,62,92,56,58,34,83,31,39,35,93,125,40,127,105,53,118,12,50,119,114,127,55,19,25,67,61,80,85,70,114,121,109,14,77,36,91,81,48,50,54,61,14,12,86,91,22,54,70,104,95,26,42,75,93,21,80,47,34,89,52,71,81,66,20,17,63,7,61,100,125,25,51,78,97,27,109,50,7,26,21,11,77,100,113,83,27,78,35,34,27,123,25,54,95,77,83,108,38,68,6,26,0,38,50,55,87,33,75,31,24,29,65,75,39,81,50,21,85,88,2,63,126,82,23,110,90,47,12,78,1,93,9,122,19,35,126,1,22,71,86,28,6,13,113,5,125,40,83,53,111,44,76,108,51,55,101,40,1,93,16,87,43,103,18,97,72,65,2 };


int f_inv_p  []= { 2,2,1,2,0,1,2,0,1,1,0,1,2,1,0,2,2,1,1,0,2,0,1,0,0,0,0,2,1,1,2,1,0,0,1,0,2,1,2,0,0,2,1,0,1,0,2,1,2,0,0,0,0,2,2,2,0,2,0,1,0,0,1,0,1,1,0,0,0,1,1,0,2,1,0,1,0,1,0,0,1,2,1,1,0,0,1,1,0,2,0,1,0,2,2,0,0,2,0,0,2,2,0,0,0,2,1,0,0,2,0,2,0,1,2,0,0,1,0,0,1,1,1,0,0,0,0,1,1,0,0,0,0,2,2,2,0,2,0,2,0,2,1,2,0,2,0,1,2,1,2,1,0,1,0,1,1,1,1,0,1,0,2,0,0,0,2,0,1,2,2,1,0,1,2,1,1,2,0,1,0,1,1,1,0,1,1,1,2,1,1,0,1,2,2,2,0,2,1,0,1,0,0,2,1,1,2,2,2,1,0,2,0,1,1,1,1,2,1,1,1,2,0,0,0,1,2,1,0,2,2,1,1,0,1,0,0,0,0,1,0,0,2,2,2,1,2,2,1,2,2 };

int key_pub  []=  {30,26, 8,38, 2,40,20};
int rand_sel []=  {-1, 1, 0, 0, 0,-1, 1};
int irr_l    []=  { -1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
};



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
    func_p_i scalar_mult,center_lift;
    func_p_p_i add;
    func_p_p_p_i mult;
    func_p_arr_i set;
};


int table_size = 30;
int  poly_count = 0;
int  Poly_init(Poly** pt2pt);

void Poly_free(Poly* ptr);
void Poly_print(Poly* self);
Poly * Poly_CenterLift(Poly *ptr_a, int q);
Poly * Poly_scalar_mult(Poly * self, int multiplier);
Poly * Poly_add(Poly * self, Poly *ptr_b, int field_N);
Poly * Poly_mult(Poly *self, Poly *ptr_b, Poly* ptr_irr,int q);
void Poly_set(Poly *self, int [], int size); 
void File_export(FILE * fptr_out,Poly* self);


/* ref 
print("encryption ...")
r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
cipher  = poly_ring_mult_over_q_with_irr(poly1_l=r_ccov_h.coef,poly2_l=[1],irr_l=irr_l,q=q)
print('cipher:',cipher)
*/
Poly ** poly_table = NULL;

int main(int argc , char** argv){

    char * cipherpathh  =  argv[1];
    char * plainTextPath =  argv[2];

    Message * arr_trit_msg = NULL;
    int num_block=0;
    FILE * fptr_out = NULL;
    FILE * fptr_in  = NULL;
    fptr_out = fopen(plainTextPath,"w");
    fptr_in  = fopen(cipherpathh,"r");
    
    int tmpdegree,tmpcoef;

    fscanf(fptr_in,"LINE:[%d]\n",&num_block);

    int ** PolyArr = malloc(sizeof(int*)*num_block);
    int * degArr = malloc(sizeof(int)*num_block);

    for( int blk_idx =0; blk_idx < num_block ; ++blk_idx  ){
        fscanf(fptr_in,"degree[%d]: ",&tmpdegree);
        degArr[blk_idx]  = tmpdegree;
        PolyArr[blk_idx] = malloc(sizeof(int)*(tmpdegree+1));

        for( int coef_idx=0; coef_idx <= tmpdegree; ++coef_idx){
            fscanf(fptr_in,"%d ",& tmpcoef);
            PolyArr[blk_idx][coef_idx]=tmpcoef;
        }
    }
/*
    for( int blk_idx =0; blk_idx < num_block ; ++blk_idx  ){
        printf("blk_idx: %d : degree[%d]",blk_idx,degArr[blk_idx]);
        for( int coef_idx=0; coef_idx <= degArr[blk_idx]; ++coef_idx){
            printf("%d ",PolyArr[blk_idx][coef_idx]);
        }
        printf("\n");
    }
*/

    poly_table = malloc(sizeof(Poly*) * table_size);
    // param shared
    Poly * poly_irr_l  ; 
    Poly_init(& poly_irr_l   );
    poly_irr_l      -> set (poly_irr_l    ,irr_l    ,sizeof(irr_l    )/sizeof(int));
    // param decryption
    Poly * poly_g;
    Poly * poly_f      ; 
    Poly * poly_f_inv_q; 
    Poly * poly_f_inv_p; 

    Poly_init(& poly_g       );
    Poly_init(& poly_f       );
    Poly_init(& poly_f_inv_q );
    Poly_init(& poly_f_inv_p );

    poly_g          -> set (poly_g        ,g        ,sizeof(g        )/sizeof(int));
    poly_f          -> set (poly_f        ,f        ,sizeof(f        )/sizeof(int));
    poly_f_inv_q    -> set (poly_f_inv_q  ,f_inv_q  ,sizeof(f_inv_q  )/sizeof(int));
    poly_f_inv_p    -> set (poly_f_inv_p  ,f_inv_p  ,sizeof(f_inv_p  )/sizeof(int));

    printf("Decryption:\n");

    Poly * poly_cipher; 
    Poly_init(& poly_cipher);

    Poly* poly_fq_mult_e   ; 
    Poly* poly_centerlift_q; 
    Poly* f_inv_p_center   ; 
    Poly* decrypted        ; 

    Message * decrypted_msg_arr = malloc(sizeof(Message)*num_block);

    unsigned long long int tmp_8byte_decode;
    for( int blk_idx =0; blk_idx < num_block ; ++blk_idx  ){
        printf("--------------- DBG blk_idx: %d ------------------\n",blk_idx);
        if(poly_cipher-> coef != NULL){// has previous message
             poly_cipher            -> free(poly_cipher       ); 
             poly_fq_mult_e         -> free(poly_fq_mult_e    ); 
             poly_centerlift_q      -> free(poly_centerlift_q ); 
             f_inv_p_center         -> free(f_inv_p_center    ); 
             decrypted              -> free(decrypted         ); 
        }
        poly_cipher       -> set (poly_cipher, PolyArr[blk_idx] , degArr[blk_idx]+1);
        poly_fq_mult_e    = poly_cipher -> mult( poly_cipher, poly_f , poly_irr_l, q );
        poly_centerlift_q = poly_fq_mult_e -> center_lift(poly_fq_mult_e, q);
        f_inv_p_center    =  poly_centerlift_q  -> mult( poly_centerlift_q, poly_f_inv_p, poly_irr_l, p);
        decrypted         =  f_inv_p_center -> center_lift(f_inv_p_center, p);
        for (int t_idx = 0; t_idx <= (decrypted -> degree) ; ++ t_idx){
            int trit = decrypted->coef[t_idx];
            printf("%d ",trit);
//      Convert -1 0 1 to 2 0 1
            trit = (trit == -1)? 2 : trit;
            decrypted_msg_arr[blk_idx].trit_poly[t_idx] = trit;
        }
        for (int t_idx = decrypted->degree +1 ; t_idx < NUM_TRITS ; ++t_idx){
            decrypted_msg_arr[blk_idx].trit_poly[t_idx] = 0;
        }
        printf("\n");
    }
    trit2char(decrypted_msg_arr,num_block);
/*
    Poly* poly_fq_mult_e = poly_cipher -> mult( poly_cipher, poly_f , poly_irr_l, q );
    printf("Poly fq mult cipher\n");
    poly_fq_mult_e -> print(poly_fq_mult_e);

    printf("Center Lifting\n");
    Poly* poly_centerlift_q = poly_fq_mult_e -> center_lift(poly_fq_mult_e, q);
    poly_centerlift_q -> print(poly_centerlift_q);

    printf("Poly f_inv_q mult center_lift q\n");
    Poly* f_inv_p_center =  poly_centerlift_q  -> mult( poly_centerlift_q, poly_f_inv_p, poly_irr_l, p);
    f_inv_p_center -> print(f_inv_p_center);

    printf("Center Lifting\n");
    Poly* decrypted =  f_inv_p_center -> center_lift(f_inv_p_center, p);
    decrypted -> print(decrypted);
*/


    // free the polynomial
    //while(poly_count){
    //    int idx = --poly_count;
	//poly_table[idx] -> free(poly_table[idx]);
    //    poly_table[idx] = NULL;
    //}
    fclose(fptr_out);

    return 0;
}



int Poly_init(Poly** self){
    if(NULL == (*self= malloc(sizeof(Poly))) ) return EXIT_FAILURE;

    poly_table[poly_count] = (*self);
    poly_count++;
    if(poly_count == table_size){
	    printf("Table is full\n");
        Poly ** new_table = NULL;
        new_table = malloc(sizeof(Poly*) * table_size*2);
        table_size*=2;
        for(int idx=0; idx < poly_count ; ++idx){
            new_table[idx] = poly_table[idx];
        }
        free(poly_table);
        poly_table = NULL;
        poly_table = new_table;
    }
    

    (*self) ->coef   = NULL;
    (*self) ->degree = 0;

    (*self) ->free = Poly_free;   
    (*self) ->print = Poly_print;
    (*self) ->scalar_mult = Poly_scalar_mult;
    (*self) ->add   = Poly_add;
    (*self) ->mult  = Poly_mult;
    (*self) ->set   = Poly_set;
    (*self) ->center_lift= Poly_CenterLift;
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
    //printf("Poly Coef:   ");
    //printf("{");
    for(int idx=0; idx <= self->degree ; ++idx){
        if(idx != self->degree ){
            printf("%d ",self ->coef[idx]);
        }
        else{
            printf("%d\n",self->coef[idx]);
        }
    }
}

void File_export(FILE * fptr_out,Poly* self){
    for(int idx=0; idx <= self->degree ; ++idx){
        if(idx != self->degree ){
            fprintf(fptr_out,"%d ",self ->coef[idx]);
        }
        else{
            fprintf(fptr_out,"%d\n",self->coef[idx]);
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

Poly * Poly_CenterLift(Poly *ptr_a, int q){

    Poly * rtn;
    Poly_init(&rtn);   
    rtn -> coef = malloc( sizeof(int)*(ptr_a->degree + 1) );
    rtn -> degree = ptr_a -> degree;

    int tmp;
    for(int i =0 ; i <= (ptr_a -> degree) ; ++i){
        tmp = ptr_a->coef[i];
        if( tmp > (q/2))
            rtn -> coef[i] = tmp - q;
        else 
            rtn -> coef[i] = tmp ;
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
    // update degree
    for (int idx = N-1 ; idx >= 0 ; idx--){
	if(poly_rtn->coef[idx] != 0 ){
	    poly_rtn->degree = idx;
	    break;
        }
    }
    return poly_rtn;
}
void Poly_set(Poly *self, int arr[], int size){
    for (int idx=size-1 ; idx >=0 ; -- idx){
        if(arr[idx] != 0){
            self -> degree = idx;
            break;
        }
    }
    self->coef = malloc(sizeof(int)*size );
    for (int i = 0 ; i <= self->degree ; ++i){
        self->coef[i]=arr[i];
    }
} 

