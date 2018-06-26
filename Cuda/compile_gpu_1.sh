nvcc -c ntru_encrypt_v3_1.cu ../bit2tritCon/char2trit_lib.o -arch=sm_20
g++ -o main_gpu_1 ntru_encrypt_v3_1.o `OcelotConfig -l`
./main_gpu_1
