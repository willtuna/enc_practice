CC=gcc
CFLAGS=-Wall -g

all: 
	$(CC) -c ./bit2tritCon/char2trit_lib.c  -o ./char2trit_lib.o
	$(CC) -o encrypt.out    $(CFLAGS) ./ntru_encrypt.c char2trit_lib.o
	$(CC) -o decrypt.out    $(CFLAGS) ./ntru_decrypt.c char2trit_lib.o
	$(CC) -o text2trit.out $(CFLAGS) ./text2trit.c
clean:
	rm -rf encrypt.out decrypt.out ./bit2tritCon/char2trit_lib.o
