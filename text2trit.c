#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NUM_TRITS 41
// !important out trit value is in (mod3) from 0 to 2

#typedef struct trits {
    char trit_poly [NUM_TRITS];
} Message, *Message_ptr;

long int filesize = 0;
int main(int argc , char* argv[]){
    if(argc != 2)
        printf("Only accept one argument(file position)!!");
    
    FILE *infile_p;
    infile_p = fopen(argv[1],"r");
    if(infile_p == NULL){
        printf("Error Opeing Files %s\n", argv[1]);
        return 1;
    }
    else{
        long int start_pos,end_pos;
        printf("Opeing Files :%s   Success !\n", argv[1]);
        fseek(infile_p,0L,SEEK_END);
        end_pos   = ftell(infile_p);
        fseek(infile_p,0L,SEEK_SET);
        start_pos = ftell(infile_p);
        printf("File End Pos  : %ld\n
                File Start Pos: %ld\n",end_pos,start_pos);
        filesize = end_pos -start_pos;
        printf("File Size     : %ld\n",filesize);
    }
    char char_read;
    unsigned long long int tmp_8byte;
    unsigned long long int * block_array8b_ptr;

    // filesize is number of byte
    // Our array element needs chunk it into 8-byte block
    // Number of block = filesize/8+1
    int num_block = filesize/8+1;
    // calloc to clean the malloc
    block_array8b_ptr = calloc(sizeof(unsigned long long int)*num_block);

    int chr_count = 0;
    int blk_idx = 0;
    while( (char_read == fgetc(infile_p))  != EOF){

       tmp_8byte = (chr_count == 0) ? 0 :tmp_8byte << 8;
       tmp_8byte = tmp_8byte | char_read; // shift one char size(8 bit) then bit wise or

       chr_count = (chr_count+1) % 8 ;

       if (chr_count == 0){
           block_array_ptr[blk_idx] = tmp_8byte;// store tmp code into array
           blk_idx ++;
       }
        
       if (blk_idx == num_block)
           break;
    }
    // Opeing Memory for trits
    Message * block_array_41t_ptr;

    block_array_41t_ptr = calloc(sizeof(message)*num_block);

    // Turn into trits
    for (int b_idx = 0 ; b_idx < num_block ; ++ b_idx){ // read out block
        tmp_8byte = block_array8b_ptr[b_idx];
        for(int t_idx =0 ; t_idx < NUM_TRITS ; ++t_idx ){ // encode to trits and write into trits
            block_array_41t_ptr[b_idx].trit_poly[t_idx] = tmp_8byte % 3;
            tmp_8byte /= 3;
        } 
    }
    // Finish Encoding to Trits
    
    unsigned long long int tmp_8byte_decode;
    // Decoding From Trits to Digit
    printf("Decoding ..........\n");
    for (int b_idx = 0 ; b_idx < num_block ; ++ b_idx){ // read out block
            tmp_8byte_decode = 0;
        for(int t_idx = NUM_TRITS-1 ; t_idx >= 0  ; --t_idx ){ // encode to trits and write into trits
            tmp_8byte_decode *= 3;
            tmp_8byte_decode += block_array_41t_ptr[b_idx].trit_poly[t_idx]; 
        } 

        printf("b_idx: %d: ", b_idx);
        char chr_tmp;
        for(int shf_idx =7; shf_idx >= 0 ; --shf_idx){// take out 8 bit by 8 bit
            chr_tmp =  tmp_8byte_decode >> (shf_idx*8) & 0xff; // after shifting , taking 8 bit out
            printf("%c",chr_tmp);
        }
        printf("\n");
    }

    free(block_array8b_ptr);
    free(block_array_41t_ptr);

    return 0;
}
