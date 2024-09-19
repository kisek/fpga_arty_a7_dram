#include <stdio.h>

#define N  (1 << 25)

int dram[N];

int main() {
    for (int addr = 0; addr < N; addr++){ /// WRITE
        dram[addr] = 1;
    }

    int sum = 0;
    for (int addr = 0; addr < N; addr++){ /// READ
        sum += dram[addr];
    }

    printf("%x %d\n", sum, sum);
    return 0;
}
