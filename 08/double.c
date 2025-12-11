// This is some sort of library for B to work with doubles
// So solutions are written in B

#include <stdint.h>
#include <math.h>
#include <stdio.h>

#define SQR(n) (n*n)

void dprint(uint64_t a)
{
    printf("%f", *((double*)&a));
}

uint64_t dgreater(uint64_t a, uint64_t b) {
    return *((double*)&a) > *((double*)&b);
}

uint64_t dless(uint64_t a, uint64_t b) {
    return *((double*)&a) < *((double*)&b);
}

uint64_t dconst(uint64_t n) {
    double result = (double) n;
    return *(uint64_t*)&result;
}

uint64_t ddist3d(uint64_t x1, uint64_t y1, uint64_t z1, uint64_t x2, uint64_t y2, uint64_t z2)
{
    double x1_ = (double) x1;
    double y1_ = (double) y1;
    double z1_ = (double) z1;
    double x2_ = (double) x2;
    double y2_ = (double) y2;
    double z2_ = (double) z2;

    double result = sqrt(SQR((x1_ - x2_)) + SQR((y1_ - y2_)) + SQR((z1_ - z2_)));
    return *(uint64_t*)&result;
}
