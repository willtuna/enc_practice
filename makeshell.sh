#! /bin/bash
make 

./encrypt.out test_text.log cipher

./decrypt.out cipher plaintxt
