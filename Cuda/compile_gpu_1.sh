nvcc -c ntru_encrypt_v4.cu -arch=sm_20  2>&1 | tee log
g++ -g -o main_gpu_1 ntru_encrypt_v4.o   `OcelotConfig -l`
