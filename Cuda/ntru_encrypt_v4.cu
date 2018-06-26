#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>//**************************************************
#include <cuda_runtime.h>//**************************************************

#define NUM_TRITS 41

typedef struct trits {
    int trit_poly [NUM_TRITS] ;
} Message;

int char2trit(char * infile_path, Message **msg_arr);
int trit2char(Message *const decrypted_msg_arr, int num_block);
void read_tritfile(FILE *ptr);




//#define DBG 0
#define N  251
int p = 3;
int q =128;
int d = 2;

int f        []=  {-1,0,0,-1,1,0,1,0,0,1,-1,0,0,1,0,-1,1,1,0,1,0,-1,0,0,0,0,-1};
int g        []=  {0,1,0,-1,0,0,1,0,0,-1,1,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,-1,-1,-1,-1};

int f_inv_q  []= { 43,118,82,111,124,16,107,97,61,34,60,48,52,18,25,92,83,32,34,36,9,81,3,111,41,45,80,70,30,65,124,51,67,35,103,44,101,102,3,19,98,97,120,85,59,94,67,104,92,18,34,76,72,70,119,100,112,0,93,91,18,31,74,72,65,69,122,88,40,66,72,48,68,55,39,58,67,89,68,110,98,107,110,62,92,56,58,34,83,31,39,35,93,125,40,127,105,53,118,12,50,119,114,127,55,19,25,67,61,80,85,70,114,121,109,14,77,36,91,81,48,50,54,61,14,12,86,91,22,54,70,104,95,26,42,75,93,21,80,47,34,89,52,71,81,66,20,17,63,7,61,100,125,25,51,78,97,27,109,50,7,26,21,11,77,100,113,83,27,78,35,34,27,123,25,54,95,77,83,108,38,68,6,26,0,38,50,55,87,33,75,31,24,29,65,75,39,81,50,21,85,88,2,63,126,82,23,110,90,47,12,78,1,93,9,122,19,35,126,1,22,71,86,28,6,13,113,5,125,40,83,53,111,44,76,108,51,55,101,40,1,93,16,87,43,103,18,97,72,65,2 };

int f_inv_p  []= { 2,2,1,2,0,1,2,0,1,1,0,1,2,1,0,2,2,1,1,0,2,0,1,0,0,0,0,2,1,1,2,1,0,0,1,0,2,1,2,0,0,2,1,0,1,0,2,1,2,0,0,0,0,2,2,2,0,2,0,1,0,0,1,0,1,1,0,0,0,1,1,0,2,1,0,1,0,1,0,0,1,2,1,1,0,0,1,1,0,2,0,1,0,2,2,0,0,2,0,0,2,2,0,0,0,2,1,0,0,2,0,2,0,1,2,0,0,1,0,0,1,1,1,0,0,0,0,1,1,0,0,0,0,2,2,2,0,2,0,2,0,2,1,2,0,2,0,1,2,1,2,1,0,1,0,1,1,1,1,0,1,0,2,0,0,0,2,0,1,2,2,1,0,1,2,1,1,2,0,1,0,1,1,1,0,1,1,1,2,1,1,0,1,2,2,2,0,2,1,0,1,0,0,2,1,1,2,2,2,1,0,2,0,1,1,1,1,2,1,1,1,2,0,0,0,1,2,1,0,2,2,1,1,0,1,0,0,0,0,1,0,0,2,2,2,1,2,2,1,2,2 };


int rand_sel []=  {0,0,-1,-1,0,1,0,0,-1,1,1,1,0,1,0,-1,-1,1,1,0,-1,0,1,0,0,0,1,0,1,-1,-1,0,0,-1,0,0,0,0,-1};

int irr_l    []=  { -1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
};
int key_pub [] = { 0,129,354,117,-21,126,-156,303,489,66,-42,153,276,228,546,102,678,759,429,-123,444,609,1152,759,750,1098,429,294,36,-48,-879,30,-774,-375,-576,-327,33,516,156,-567,300,153,339,-81,141,-243,444,612,714,-87,-198,312,183,207,78,246,15,123,3,-129,3,3,174,-324,426,195,390,27,153,-123,-327,-744,12,18,-462,-231,462,564,150,-120,159,-288,-705,-129,-249,-84,210,321,243,270,33,-132,-90,-180,333,-417,18,36,195,300,87,69,747,591,-96,-510,-390,-360,-75,-24,-459,-447,-222,204,555,441,90,645,396,84,93,-987,-384,126,360,-174,-15,-201,147,-714,-666,-174,447,786,171,-78,-6,240,-639,-762,-366,-300,9,-165,-12,-144,-102,-531,66,306,18,315,525,342,-159,-351,147,267,6,-435,-255,-567,369,-204,-54,294,768,-477,-213,-360,-219,-186,333,300,252,174,-6,345,-279,237,84,-369,-696,45,-696,-300,237,768,345,696,39,207,-363,-522,-264,-69,-66,-78,246,-69,243,267,-9,-546,-561,-375,-546,-492,27,435,357,627,105,-93,171,213,-462,177,120,867,-438,354,156,180,-594,300,-111,123,447,309,-393,-669,318,-618,-240,-576,639,-450,195,123,450,-741,438,150,-126,90,-123,-84,255,633,-168,465,-123,618,-264,240,-390,-90,-393,93,-369,-603,-339,-348,-630,-351,-153,-342,-105,-84,-306,-546,-747,-783,-870,-756,-708,-417,-201,-6 };


typedef struct Poly Poly;// forward declaration

typedef void  (*func_p)(Poly *);
typedef void  (*func_p_arr_i)(Poly *,int [], int);
typedef Poly* (*func_p_i)(Poly*, int);
typedef Poly* (*func_p_p_i)(Poly *, Poly *, int);
typedef Poly* (*func_p_p_p_i)(Poly *, Poly *, Poly *,int);

typedef struct Cipher {
    int Cipher_poly[251] ;//should be initialized
    int degree;
} Cipher;

struct Poly {
    int * coef;
    int degree;
    func_p free,print;
    func_p_i scalar_mult,center_lift;
    func_p_p_i add;
    func_p_p_p_i mult;
    func_p_arr_i set;
};


int table_size = 1000;
int  poly_count = 0;
__host__ __device__ int Poly_init(Poly** self);

__host__ __device__ void Poly_free(Poly* ptr);
__host__ __device__ void Poly_print(Poly* self);
__host__ __device__ Poly * Poly_CenterLift(Poly *ptr_a, int q);
__host__ __device__ Poly * Poly_scalar_mult(Poly * self, int multiplier);
__host__ __device__ Poly * Poly_add(Poly * self, Poly *ptr_b, int field_N);
__host__ __device__ Poly * Poly_mult(Poly *self, Poly *ptr_b, Poly* ptr_irr,int q);
__host__ __device__ void Poly_set(Poly *self, int [], int size); 
__host__ void File_export(FILE * fptr_out, Cipher* self);

__host__ __device__ void Cipher_set(int * arr, Poly *self);

/* ref 
print("encryption ...")
r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
cipher  = poly_ring_mult_over_q_with_irr(poly1_l=r_ccov_h.coef,poly2_l=[1],irr_l=irr_l,q=q)
print('cipher:',cipher)
*/

__global__ void encrypt(Message * arr_trit_msg, int num_block, Cipher * poly_cipher_arr, Poly * poly_irr_l, Poly * poly_key_pub, Poly * poly_rand_sel, int p, int q){
	//int blk_idx = blockIdx.x*blockDim.x+threadIdx.x;
	int blk_idx=0;
	int TotalThread = blockDim.x*gridDim.x;
	int stripe = num_block / TotalThread;
	int head   = (blockIdx.x*blockDim.x + threadIdx.x)*stripe;
	int LoopLim = head+stripe;

	Poly* poly_message; 
	Poly_init(& poly_message);
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
                int i=0;
		for(i = 0; i <= NUM_TRITS; i++){
			if(poly_message -> coef[i] < 0){
				poly_message -> coef[i] += 3;
			}
		}
		poly_scalmul = poly_rand_sel -> scalar_mult(poly_rand_sel, p) ;
		poly_mult    = poly_scalmul  -> mult(poly_scalmul, poly_key_pub, poly_irr_l, q);
		poly_cipher  = poly_mult -> add ( poly_mult, poly_message, q);


		Cipher_set(poly_cipher_arr[blk_idx].Cipher_poly, poly_cipher);
		poly_cipher_arr[blk_idx].degree = poly_cipher -> degree;
		//弄成array type => poly_cipher_arr[blk_idx]
		//File_export(fptr_out,poly_cipher)移到main;
	}
}

float GPU_kernel(Message * arr_trit_msg, int num_block, Cipher * poly_cipher, Poly * poly_irr_l, Poly * poly_key_pub, Poly * poly_rand_sel, int p, int q){
	
	Message * darr_trit_msg;
	Poly * dpoly_irr_l, * dpoly_key_pub, * dpoly_rand_sel;
        int * dpoly_irr_l_coef   ,* dpoly_key_pub_coef ,* dpoly_rand_sel_coef;


	Cipher * dpoly_cipher;

	//int * poly_irr_l_coef, 
	// Creat Timing Event
  	cudaEvent_t start, stop;
	cudaEventCreate (&start);
	cudaEventCreate (&stop); 	

	// Allocate Memory Space on Device******************
	cudaMalloc((void**)&darr_trit_msg      ,sizeof(Message)*num_block);
	cudaMalloc((void**)&dpoly_irr_l        ,sizeof(Poly)*1);
	cudaMalloc((void**)&dpoly_irr_l_coef   ,sizeof(int)*(poly_irr_l->degree+1));
	cudaMalloc((void**)&dpoly_key_pub      ,sizeof(Poly)*1);
	cudaMalloc((void**)&dpoly_key_pub_coef ,sizeof(int)*(poly_key_pub->degree+1));
	cudaMalloc((void**)&dpoly_rand_sel     ,sizeof(Poly)*1);
	cudaMalloc((void**)&dpoly_rand_sel_coef,sizeof(int)*(poly_rand_sel->degree+1));
	cudaMalloc((void**)&dpoly_cipher       ,sizeof(Cipher)*num_block);//initialize
	// Allocate Memory Space on Device (for observation)
	//cudaMalloc((void**)&dInd,sizeof(IndexSave)*SIZE);

	// Copy Data to be Calculated********************
	cudaMemcpy(darr_trit_msg   , arr_trit_msg   , sizeof(Message)*num_block, cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_irr_l     , poly_irr_l     , sizeof(Poly)*1           , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_key_pub   , poly_key_pub   , sizeof(Poly)*1           , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_rand_sel  , poly_rand_sel  , sizeof(Poly)*1           , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_irr_l_coef    , poly_irr_l->coef   , sizeof(int)*(poly_irr_l->degree+1)   , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_key_pub_coef  , poly_key_pub->coef , sizeof(int)*(poly_key_pub->degree+1) , cudaMemcpyHostToDevice);
	cudaMemcpy(dpoly_rand_sel_coef , poly_rand_sel->coef, sizeof(int)*(poly_rand_sel->degree+1), cudaMemcpyHostToDevice);
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
	encrypt<<<dimGrid,dimBlock>>>(darr_trit_msg, num_block, dpoly_cipher, dpoly_irr_l, dpoly_key_pub, dpoly_rand_sel,p,q);

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
	
    if( (num_block = char2trit(infilepath, &arr_trit_msg)) == -1 ){
        printf("Error\n");
        return 1;
    }
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

    Poly_init(& poly_rand_sel);

    poly_key_pub    -> set (poly_key_pub  ,key_pub  ,sizeof(key_pub  )/sizeof(int));
//    poly_message    -> set (poly_message  ,message  ,sizeof(message  )/sizeof(int));
    poly_rand_sel   -> set (poly_rand_sel ,rand_sel ,sizeof(rand_sel )/sizeof(int));

	/* CPU side*/
	
	Cipher * arr_cipher_cpu = (Cipher *)malloc(sizeof(Cipher)*num_block);
	
	/* GPU side*/
	float elapsedTime = GPU_kernel(arr_trit_msg, num_block, arr_cipher_cpu, poly_irr_l, poly_key_pub, poly_rand_sel, p , q);
	
	printf("GPU time = %5.2f ms\n", elapsedTime);
	
	for( int blk_idx =0; blk_idx < num_block ; ++blk_idx  ){
	File_export(fptr_out,&arr_cipher_cpu[blk_idx]);
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
    poly_irr_l    -> free(poly_irr_l    ); 
    poly_g        -> free(poly_g        );
    poly_f        -> free(poly_f        ); 
    poly_f_inv_q  -> free(poly_f_inv_q  ); 
    poly_f_inv_p  -> free(poly_f_inv_p  ); 
    poly_key_pub  -> free(poly_key_pub  ); 
    poly_rand_sel -> free(poly_rand_sel );

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


__host__ __device__ int Poly_init(Poly** self){
    if(NULL == (*self= (Poly*)malloc(sizeof(Poly))) ) return EXIT_FAILURE;

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




 __device__ __host__ void Poly_free(Poly* ptr){
    if(ptr->coef != NULL ){
        free(ptr->coef);
        ptr->coef = NULL;
        ptr->degree = 0;
    }
}
 __device__ __host__ void Poly_print(Poly* self){
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

__host__ void File_export(FILE * fptr_out, Cipher* self){
    for(int idx=0; idx <= self->degree ; ++idx){
        if(idx != self->degree ){
            fprintf(fptr_out,"%d ",self ->Cipher_poly[idx]);
        }
        else{
            fprintf(fptr_out,"%d\n",self->Cipher_poly[idx]);
        }
    }
}

 __device__ __host__ Poly * Poly_scalar_mult(Poly * self, int multiplier){
    Poly * rtn;
    Poly_init(&rtn);   
    rtn -> coef = (int*)malloc( sizeof(int)*(self->degree+1) );
    rtn -> degree = self->degree;
    for(int idx=0;idx <= self->degree ; ++idx){
        rtn->coef[idx]= (multiplier * self->coef[idx])%N;
    }
    return rtn;
}

 __device__ __host__ Poly * Poly_add(Poly * ptr_a, Poly *ptr_b, int field_N){
    Poly * large_ptr = (ptr_a -> degree > ptr_b -> degree ) ? ptr_a  : ptr_b ;
    Poly * small_ptr = (ptr_a -> degree > ptr_b -> degree ) ? ptr_b : ptr_a;

    Poly * rtn;
    Poly_init(&rtn);   
    rtn -> coef = (int*)malloc( sizeof(int)*(large_ptr->degree+1) );
    rtn -> degree = large_ptr->degree;

    for(int idx =0 ; idx <= large_ptr -> degree ; ++idx){
        if ( idx > small_ptr-> degree)
            rtn -> coef[idx] = large_ptr -> coef[idx];
        else
            rtn -> coef[idx] = (large_ptr->coef[idx]+ small_ptr->coef[idx]) % field_N;
    }
    return rtn;
}

__device__ __host__ Poly * Poly_CenterLift(Poly *ptr_a, int q){

    Poly * rtn;
    Poly_init(&rtn);   
    rtn -> coef = (int*)malloc( sizeof(int)*(ptr_a->degree + 1) );
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

__device__ __host__ Poly * Poly_mult(Poly *ptr_a, Poly *ptr_b, Poly* ptr_irr,int q){

    int rtn_idx = 0;
    int size = ptr_irr -> degree;
    int tmp;


    Poly * poly_rtn;
    Poly_init(& poly_rtn);
    poly_rtn -> coef = (int*)malloc(sizeof(int)*size);
    poly_rtn -> degree = size-1;

#ifdef DBG
    printf("poly rnt:"); Poly_print(poly_rtn);
    printf("ptr_a");     Poly_print(ptr_a);
    printf("ptr_b");     Poly_print(ptr_b);
    printf("ptr_irr");   Poly_print(ptr_irr);
#endif

    for (int idx = 0 ; idx <= ptr_a -> degree ; ++idx){
        for(int idy = 0 ; idy <= ptr_b -> degree ; ++ idy){
            rtn_idx = (idx + idy)%size;
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
    for (int idx = size-1 ; idx >= 0 ; idx--){
	if(poly_rtn->coef[idx] != 0 ){
	    poly_rtn->degree = idx;
	    break;
        }
    }
    return poly_rtn;
}
__device__ __host__ void Poly_set(Poly *self, int arr[], int size){
    for (int idx=size-1 ; idx >=0 ; -- idx){
        if(arr[idx] != 0){
            self -> degree = idx;
            break;
        }
    }
    self->coef = (int*)malloc(sizeof(int)*size );
    for (int i = 0 ; i <= self->degree ; ++i){
        self->coef[i]=arr[i];
    }
} 

__device__ void Cipher_set(int * arr, Poly *self){
    for (int i = 0 ; i < 251 ; ++i){
		if(i <= self->degree){
			arr[i]=self->coef[i];
		}else {
			arr[i]=0;
		}
    }
	
} 




//              char2trit 
int char2trit(char * infile_path, Message ** msg_arr){
    FILE *infile_p;
    long int filesize = 0;

    infile_p = fopen(infile_path ,"r");
    if(infile_p == NULL){
        printf("Error Opeing Files %s\n", infile_path);
        return -1;
    }
    else{
        long int start_pos,end_pos;
        printf("Opeing Files :%s   Success !\n", infile_path);
        fseek(infile_p,0L,SEEK_END);
        end_pos   = ftell(infile_p);
        fseek(infile_p,0L,SEEK_SET);
        start_pos = ftell(infile_p);
        printf("File End Pos  : %ld\nFile Start Pos: %ld\n",end_pos,start_pos);
        filesize = end_pos -start_pos;
        printf("File Size     : %ld\n",filesize);
    }
    char char_read;
    unsigned long long int tmp_8byte;
    unsigned long long int * block_array8b_ptr;

    // filesize is number of byte
    // Our array element needs chunk it into 8-byte block
    // Number of block = filesize/8+1
    int num_block = (filesize%8 == 0 )? filesize/8 : filesize/8+1;
    printf("Number of Block: %d \n",num_block);
    // calloc to clean the malloc
    block_array8b_ptr = (unsigned long long *)calloc(num_block,sizeof(unsigned long long int));

    int chr_count = 0;
    int blk_idx = 0;
    while( (char_read = fgetc(infile_p))  != EOF){
       printf("%c",char_read);
       tmp_8byte = (chr_count == 0) ? 0 :tmp_8byte << 8;
       tmp_8byte = tmp_8byte | char_read; // shift one char size(8 bit) then bit wise or

       chr_count = (chr_count+1) % 8 ;

       if (chr_count == 0){
           block_array8b_ptr[blk_idx] = tmp_8byte;// store tmp code into array
           blk_idx ++;
       }
    }
    // Padding Last Word with 0
    if (blk_idx == num_block-1){
           while(chr_count != 0){ 
               tmp_8byte = tmp_8byte << 8;
               chr_count = (chr_count+1) % 8 ;
           }
           block_array8b_ptr[blk_idx] = tmp_8byte;// store last word into block array 
        blk_idx++;
    }
    if (blk_idx != num_block){
        printf("Block Segmentation Fault !!! Debug\n");
        return -1;
    }

    // Opeing Memory for trits
    *msg_arr = (Message *)calloc(num_block,sizeof(Message));

    // Turn into trits
    for (int b_idx = 0 ; b_idx < num_block ; ++ b_idx){ // read out block
        tmp_8byte = block_array8b_ptr[b_idx];
        printf("\nblk_idx %d : %llu\n",b_idx,tmp_8byte);

        for(int t_idx =0 ; t_idx < NUM_TRITS ; ++t_idx ){ // encode to trits and write into trits
    // Convert trit {0 1 2} to  0 1 -1
            int trit = (tmp_8byte % 3);
            trit = (trit == 2)? -1 : trit;
            (*msg_arr)[b_idx].trit_poly[t_idx] = trit;
            tmp_8byte /= 3;
        } 
    }

    fclose(infile_p);
    // Finish Encoding to Trits
    return num_block;
}
    


__host__ __device__  int trit2char(Message *const decrypted_msg_arr, int num_block){
    unsigned long long int tmp_8byte_decode;
    printf("Decoding From Trits to char\n");
    for (int b_idx = 0 ; b_idx < num_block ; ++ b_idx){ // read out block
            tmp_8byte_decode = 0;
        for(int t_idx = NUM_TRITS-1 ; t_idx >= 0  ; --t_idx ){ // encode to trits and write into trits
            tmp_8byte_decode *= 3;
            tmp_8byte_decode += decrypted_msg_arr[b_idx].trit_poly[t_idx]; 
        } 

//        printf("b_idx: %d: ", b_idx);
//        printf("tmp_8byte : %llu  :",tmp_8byte_decode);
        char chr_tmp;
        for(int shf_idx =7; shf_idx >= 0 ; --shf_idx){// take out 8 bit by 8 bit
            chr_tmp =  tmp_8byte_decode >> (shf_idx*8) & 0xff; // after shifting , taking 8 bit out
            printf("%c",chr_tmp);
        }
        printf("\n");
    }
    return 0;
}



void read_tritfile(FILE *ptr){
    printf("File Decoding ..........\n");
    unsigned long long int tmp_8byte_decode = 0;
    size_t bufsize = NUM_TRITS+1;// Null Character
    char * buffer;
    buffer = (char*)malloc(bufsize*sizeof(char));
    if (buffer == NULL){
        printf("Error Unable to allocate buffer");
        exit(1);
    }
    int line_num = 0;
    char garbage;
    while ( fgets( buffer,bufsize, ptr) != NULL){
        garbage = fgetc(ptr);
        tmp_8byte_decode = 0;
        for(int t_idx = NUM_TRITS-1 ; t_idx >= 0  ; --t_idx ){ // encode to trits and write into trits
            tmp_8byte_decode *= 3;
            tmp_8byte_decode += buffer[t_idx]-'0';
        } 
        char chr_tmp;
        for(int shf_idx =7; shf_idx >= 0 ; --shf_idx){// take out 8 bit by 8 bit
            chr_tmp =  tmp_8byte_decode >> (shf_idx*8) & 0xff; // after shifting , taking 8 bit out
            printf("%c",chr_tmp);
        }
    }
    free(buffer);
}
