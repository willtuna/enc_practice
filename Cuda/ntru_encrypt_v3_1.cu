#include <stdio.h>
#include <stdlib.h>
#include "bit2tritCon/char2trit_lib.h"
#include <cuda.h>//**************************************************
#include <cuda_runtime.h>//**************************************************
//#define DBG 0
int N = 7;
int p = 3;
int q =128;
int d = 2;

int g        []=  { 0,-1,-1, 0, 1, 0, 1};
int f        []=  {-1, 0, 1, 1,-1, 0, 1};
int f_inv_q  []=  {37, 2,40,21,31,26, 8};
int f_inv_p  []=  { 1, 1, 1, 1, 0, 2, 1};
int key_pub  []=  {30,26, 8,38, 2,40,20};
int rand_sel []=  {-1, 1, 0, 0, 0,-1, 1};
int irr_l    []=  {-1, 0, 0, 0, 0, 0, 0, 1};

int message  []=  {1 ,-1, 1, 1, 0,-1   };

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

__global__ void encrypt(Message * arr_trit_msg, int num_block, Cipher * poly_cipher_arr, Poly * poly_irr_l, Poly * poly_key_pub, Poly * poly_rand_sel, int NUM_TRITS, int p, int q){
	//int blk_idx = blockIdx.x*blockDim.x+threadIdx.x;
	int blk_idx=0;
	int TotalThread = blockDim.x*gridDim.x;
	int stripe = num_block / TotalThread;
	int head   = (blockIdx.x*blockDim.x + threadIdx.x)*stripe;
	int LoopLim = head+stripe;

	Poly* poly_message; 
    Poly* poly_scalmul ;
    Poly* poly_mult    ;
    Poly* poly_cipher  ;
	
	for(blk_idx=head ; blk_idx<LoopLim ; blk_idx++ ){
		if(poly_message -> coef != NULL){// has previous message
			poly_message -> free(poly_message); 
			poly_scalmul -> free(poly_scalmul); 
			poly_mult    -> free(poly_mult   ); 
			poly_cipher  -> free(poly_cipher ); 
		}
		poly_message -> set (poly_message  , arr_trit_msg[blk_idx].trit_poly, NUM_TRITS);
		for(int i = 0, i <= NUM_TRITS, i++){
			if(poly_message -> coef[i] < 0){
				poly_message -> coef[i] += 3;
			}
		}
		poly_scalmul = poly_rand_sel -> scalar_mult(poly_rand_sel, p) ;
		poly_mult    = poly_scalmul  -> mult(poly_scalmul, poly_key_pub, poly_irr_l, q);
		poly_cipher  = poly_mult -> add ( poly_mult, poly_message, q);
		
		Cipher_set(poly_cipher_arr[blk_idx].Cipher_poly, poly_cipher)
		poly_cipher_arr[blk_idx].degree = poly_cipher -> degree;
		//弄成array type => poly_cipher_arr[blk_idx]
		//File_export(fptr_out,poly_cipher)移到main;
	}
}

float GPU_kernel(Message * arr_trit_msg, int num_block, Cipher * poly_cipher, Poly * poly_irr_l, Poly * poly_key_pub, Poly * poly_rand_sel, int NUM_TRITS, int p, int q){
	
	Message * darr_trit_msg;
	Poly * dpoly_irr_l, * dpoly_key_pub, * dpoly_rand_sel;
	Cipher * dpoly_cipher;
	IndexSave* dInd;
	//int * poly_irr_l_coef, 
	// Creat Timing Event
  	cudaEvent_t start, stop;
	cudaEventCreate (&start);
	cudaEventCreate (&stop); 	

	// Allocate Memory Space on Device******************
	cudaMalloc((void**)&darr_trit_msg      ,sizeof(Message)*num_block);
	cudaMalloc((void**)&dpoly_irr_l        ,sizeof(Poly)*1);
	cudaMalloc((void**)&dpoly_irr_l_coef   ,sizeof(int)*(poly_irr_l->degree));
	cudaMalloc((void**)&dpoly_key_pub      ,sizeof(Poly)*1);
	cudaMalloc((void**)&dpoly_key_pub_coef ,sizeof(int)*(poly_key_pub->degree));
	cudaMalloc((void**)&dpoly_rand_sel     ,sizeof(Poly)*1);
	cudaMalloc((void**)&dpoly_rand_sel_coef,sizeof(int)*(poly_rand_sel->degree));
	cudaCalloc((void**)&dpoly_cipher       ,sizeof(Cipher)*num_block);//initialize
	// Allocate Memory Space on Device (for observation)
	//cudaMalloc((void**)&dInd,sizeof(IndexSave)*SIZE);

	// Copy Data to be Calculated********************
	cudaMemcpy(darr_trit_msg   , arr_trit_msg   , sizeof(Message)*num_block, cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_irr_l     , poly_irr_l     , sizeof(Poly)*1           , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_key_pub   , poly_key_pub   , sizeof(Poly)*1           , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_rand_sel  , poly_rand_sel  , sizeof(Poly)*1           , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_irr_l_coef    , poly_irr_l->coef   , sizeof(int)*(poly_irr_l->degree)   , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_key_pub_coef  , poly_key_pub->coef , sizeof(int)*(poly_key_pub->degree) , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_rand_sel_coef , poly_rand_sel->coef, sizeof(int)*(poly_rand_sel->degree), cudaMemcpyHostToDevice);
	dpoly_irr_l   ->coef = dpoly_irr_l_coef;
	dpoly_key_pub ->coef = dpoly_key_pub_coef;
	dpoly_rand_sel->coef = dpoly_rand_sel_coef;
	

	// Copy Data (indsave array) to device
	//cudaMemcpy(dInd, indsave, sizeof(IndexSave)*SIZE, cudaMemcpyHostToDevice);
	
	// Start Timer
	cudaEventRecord(start, 0);

	// Lunch Kernel
	dim3 dimGrid (2);
	dim3 dimBlock(4);
	encrypt<<<dimGrid,dimBlock>>>(darr_trit_msg, num_block, dpoly_cipher, dpoly_irr_l, dpoly_key_pub, dpoly_rand_sel, NUM_TRITS, p, q);

	// Stop Timer
	cudaEventRecord(stop, 0);
  	cudaEventSynchronize(stop); 

	// Copy Output back******************
	cudaMemcpy(poly_cipher, dpoly_cipher, sizeof(Cipher)*num_block, cudaMemcpyDeviceToHost);
	
	// Release Memory Space on Device
	cudaFree(darr_trit_msg);
	cudaFree(dpoly_irr_l);
	cudaFree(dpoly_irr_l_coef);
	cudaFree(dpoly_key_pub);
	cudaFree(dpoly_key_pub_coef);
	cudaFree(dpoly_rand_sel);
	cudaFree(dpoly_rand_sel_coef);
	cudaFree(dpoly_cipher);

	// Calculate Elapsed Time
  	float elapsedTime; 
  	cudaEventElapsedTime(&elapsedTime, start, stop);  

	return elapsedTime;
}

int main(int argc , char** argv){

    char * infilepath  =  argv[1];
    char * outfilepath =  argv[2];

    Message * arr_trit_msg = NULL;
    int num_block=0;
    FILE * fptr_out = NULL;
    fptr_out = fopen(outfilepath,"w");
	
    if( (num_block = char2trit(infilepath, arr_trit_msg)) == -1 ){
        printf("Error\n");
        return 1;
    }

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
    // param eyncryption
    Poly * poly_key_pub; 
    //Poly * poly_message; 
    Poly * poly_rand_sel;

    Poly_init(& poly_key_pub );
    Poly_init(& poly_message );
    Poly_init(& poly_rand_sel);

    poly_key_pub    -> set (poly_key_pub  ,key_pub  ,sizeof(key_pub  )/sizeof(int));
//    poly_message    -> set (poly_message  ,message  ,sizeof(message  )/sizeof(int));
    poly_rand_sel   -> set (poly_rand_sel ,rand_sel ,sizeof(rand_sel )/sizeof(int));

	/* CPU side*/
	function_1(C,A);//to modified
	
	Cipher * arr_cipher_cpu;
	Malloc((void**)&arr_cipher_cpu,sizeof(Cipher)*num_block);
	
	/* GPU side*/
	float elapsedTime = GPU_kernel(arr_trit_msg, num_block, arr_cipher_cpu, poly_irr_l, poly_key_pub, poly_rand_sel, NUM_TRITS, p, q);
	
	printf("GPU time = %5.2f ms\n", elapsedTime);
	
	for( int blk_idx =0; blk_idx < num_block ; ++blk_idx  ){
	File_export(fptr_out,arr_cipher_cpu[blk_idx]);
	}
	
	free(arr_cipher_cpu);
//  Encryption intermediate ptr

    /*Poly* poly_scalmul ;
    Poly* poly_mult    ;
    Poly* poly_cipher  ;

    for( int blk_idx =0; blk_idx < num_block ; ++blk_idx  ){
        if(poly_message -> coef != NULL){// has previous message
             poly_message -> free(poly_message); 
             poly_scalmul -> free(poly_scalmul); 
             poly_mult    -> free(poly_mult   ); 
             poly_cipher  -> free(poly_cipher ); 
        }
        poly_message -> set (poly_message  , arr_trit_msg[blk_idx].trit_poly, NUM_TRITS);
        poly_scalmul = poly_rand_sel -> scalar_mult(poly_rand_sel, p) ;
        poly_mult    = poly_scalmul  -> mult(poly_scalmul, poly_key_pub, poly_irr_l, q);
        poly_cipher  = poly_mult -> add ( poly_mult, poly_message, q);
        File_export(fptr_out,poly_cipher);
    }*/
//    printf("message:  ");
//    poly_message -> print(poly_message);
//    Poly* poly_scalmul = poly_rand_sel -> scalar_mult(poly_rand_sel, p) ;
//    Poly* poly_mult    = poly_scalmul  -> mult(poly_scalmul, poly_key_pub, poly_irr_l, q);

//    printf("mult:  ");
//    poly_mult -> print(poly_mult);

//    Poly* poly_cipher = poly_mult -> add ( poly_mult, poly_message, q);
//    printf("Cipher:  ");
//    poly_cipher -> print(poly_cipher);

/*
    printf("Decryption:\n");
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
    while(poly_count){
        int idx = --poly_count;
	poly_table[idx] -> free(poly_table[idx]);
        poly_table[idx] = NULL;
    }
    fclose(fptr_out);

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

void Cipher_set(int * arr, Poly *self){
    for (int i = 0 ; i <= self->degree ; ++i){
        arr[i]=self->coef[i];
    }
} 

typedef struct Cipher {
    int Cipher_poly[251] = {0} ;
    int degree;
} Cipher;
