#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NUM_TRITS 41
// !important out trit value is in (mod3) from 0 to 2

typedef struct trits {
    char trit_poly [NUM_TRITS] ;
} Message, *Message_ptr;
void read_tritfile(FILE *ptr);

long int filesize = 0;
int main(int argc , char* argv[]){
    if(argc != 2)
        printf("Only accept one argument(file position)!!");
    
    FILE *infile_p, *outfile_p, *recover_p;
    infile_p = fopen(argv[1],"r");

    char * outfileName = strcat(argv[1],".trit");
    outfile_p = fopen(outfileName,"w");

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
    int num_block = filesize/8+1;
    printf("Number of Block: %d \n",num_block);
    // calloc to clean the malloc
    block_array8b_ptr = calloc(num_block,sizeof(unsigned long long int));

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
    if (blk_idx != num_block)
        printf("Block Segmentation Fault !!! Debug\n");

    // Opeing Memory for trits
    Message * block_array_41t_ptr;

    block_array_41t_ptr = calloc(num_block,sizeof(Message));

    // Turn into trits
    for (int b_idx = 0 ; b_idx < num_block ; ++ b_idx){ // read out block
        tmp_8byte = block_array8b_ptr[b_idx];
        printf("\nblk_idx %d : %llu\n",b_idx,tmp_8byte);

        for(int t_idx =0 ; t_idx < NUM_TRITS ; ++t_idx ){ // encode to trits and write into trits
            block_array_41t_ptr[b_idx].trit_poly[t_idx] = tmp_8byte % 3;
            //printf("%d",block_array_41t_ptr[b_idx].trit_poly[t_idx]);
            fprintf(outfile_p,"%d",block_array_41t_ptr[b_idx].trit_poly[t_idx]);
            tmp_8byte /= 3;
        } 
        fprintf(outfile_p,"\n");
    }
    // Finish Encoding to Trits
    fclose(outfile_p);
    
    












    //-------------------------------------
    unsigned long long int tmp_8byte_decode = 0;

    outfile_p = fopen(outfileName,"r");
    fseek(outfile_p,0L,SEEK_SET);
    if(outfile_p == NULL){
        printf("Error Opeing Files %s\n", argv[1]);
        return 1;
    }
    //read_tritfile(outfile_p);
    
    //--------------------------



    // Decoding From Trits to Digit
    printf("Decoding ..........\n");
    for (int b_idx = 0 ; b_idx < num_block ; ++ b_idx){ // read out block
            tmp_8byte_decode = 0;
        for(int t_idx = NUM_TRITS-1 ; t_idx >= 0  ; --t_idx ){ // encode to trits and write into trits
            tmp_8byte_decode *= 3;
            tmp_8byte_decode += block_array_41t_ptr[b_idx].trit_poly[t_idx]; 
        } 

        printf("b_idx: %d: ", b_idx);
        printf("tmp_8byte : %llu  :",tmp_8byte_decode);
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



void read_tritfile(FILE *ptr){
    printf("File Decoding ..........\n");
    unsigned long long int tmp_8byte_decode = 0;
    size_t bufsize = NUM_TRITS+1;// Null Character
    char * buffer;
    buffer = malloc(bufsize*sizeof(char));
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
