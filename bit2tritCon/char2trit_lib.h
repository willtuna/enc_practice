#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef BIT2TRIT_H
#define BIT2TRIT_H

#define NUM_TRITS 41

typedef struct trits {
    int trit_poly [NUM_TRITS] ;
} Message;

int char2trit(char * infile_path, Message *msg_arr);
int trit2char(Message *const decrypted_msg_arr, int num_block);
void read_tritfile(FILE *ptr);

#endif

