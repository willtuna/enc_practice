# NTRU Crypto System

# Reference Parameter


| Security Level | N | q | p |
| -------- | -------- | -------- | -------- |
| Moderate Security    | 167 |  128  | 3   |
| Standard Security    | 251 |  128  | 3   |
| High     Security    | 347 |  128  | 3   |
| Highest  Security    | 503 |  256  | 3   |

I would like to develop the standard security verseion.

## Message Format:
Use trit is because of p is chosen 3

* str2char()
* char2byte()
* byte2trit() 
    - byte equivalent to (mod 256)
    - trit equivalent to (mod 3)
        - 3 bit to 2 trit has bad efficiency
        - 8 bit (byte) to 4 trit has bad efficiency but easy for design
        For efficiency consideration 21 byte to 106 trits has 99.9961% 
        - I would choose (8 byte) to (41 trits)

41 trits means $N \geq 41$ , after converting to trits , it must be center lift from -1 to 1
> [name=willtuna]
> 這個不是主要的原因，但是這是一個必須滿足的condition
> 原則上 N 主要還是決定 keysize ，理想上 trit 個數越接近N 越好,可以讓加密的效率提昇（增加每次加密的資料密度）
> 如同上面所述，理想上可以透過將 21 byte 轉換程 106 trits 來實做 最有加密解密的效率，但是軟體實做上面需要去實現大數法則（支援 21 byte 寬度的整數）
    
    

# Example: 
string = "Hello Oasis?" 
string is 13 characters 
1. Chop string into 8-byte block padding 0 for the rest.
   - from "Hello Oasis?" to [Hello Oa],[sis?\n000]
2. Convert each block into unsinged long long number. Convert into 41 char array each element is a <B>trit $\in{\{-1,0,1\}}$</B>
   
3. message = 41 elements trit array

message:
$$m[x]\ = a_0 + a_1x + a_2x^2 + ...a_{40}x^{40} , where\ a_i \in \{-1,0,1\}$$
# Parameters:
* $f_q[x] = f^{-1}[x] (mod\ q)$
* $f_p[x] = f^{-1}[x] (mod\ p)$

# Key Generation:
$$ H = p\times f_q[x]*g[x]\ (mod q) $$

# Encryption
Choose random polynomial:
$$ r[x] \in R[x]/X^N-1 $$
Cipher  : $$ e[x] = r[x]*h[x]+m[x]$$

# Decryption:
Partial Decryption:
$$a[x] = f[x]*e[x] (mod q)$$
Change to mod p
$$b[x] = a[x] (mod p)$$
Message:$$m[x] = f_p[x]*b[x]$$