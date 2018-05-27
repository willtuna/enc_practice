CC=gcc
CFLAGS=-WALL -g

all: 
	$(CC) -o ntru_c ntru_encrypt.c