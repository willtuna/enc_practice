CC=gcc
CFLAGS=-WALL -g

all: 
	$(CC) -o ntru_c.out    ./ntru_encrypt_v2.c
	$(CC) -o text2trit.out ./text2trit.c
