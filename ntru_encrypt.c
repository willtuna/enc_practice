#include <stdio.h>
#include <stdlib.h>

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
    free(ptr->coef);
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

print("encryption ...")
r_ccov_h = p*P(rand_sel)*P(key_pub)+P(message)
cipher  = poly_ring_mult_over_q_with_irr(poly1_l=r_ccov_h.coef,poly2_l=[1],irr_l=irr_l,q=q)
print('cipher:',cipher)



int main(int argc , char** argv){
    Poly poly_g;
    Poly poly_rand_sel;
    Poly poly_key_pub;
    Poly poly_message;

    int n = sizeof(g)/sizeof(g[0]);
    Poly_init(&poly_g, g, n);

    Poly_print(&poly_g);

    Poly_free(&poly_g);
    return 0;
}