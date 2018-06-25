CC=gcc
CFLAGS=-Wall -g

all: 
	$(CC) -o ntru_c.out    $(CFLAGS) ./ntru_encrypt_v3.c ./bit2tritCon/char2trit_lib.o
	$(CC) -o text2trit.out $(CFLAGS) ./text2trit.c
