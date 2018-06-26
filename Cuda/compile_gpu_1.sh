nvcc -c ntru_encrypt_v3_1.cu -arch=sm_20  2>&1 | tee log
g++ -o main_gpu_1 ntru_encrypt_v3_1.o   `OcelotConfig -l`
