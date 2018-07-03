#include "klessydra_defs.h"

#define MHARTID_IDCORE_MASK 15
#define THREAD_POOL_SIZE 4

#define spmaddrA 0x00109000
#define spmaddrB 0x00109200
#define spmaddrC 0x00109400
#define spmaddrD 0x00109600

#ifndef __KLESSYDRACFUNCTIONS_H__
#define __KLESSYDRACFUNCTIONS_H__

void CSR_MVSIZE(int rs1);

int kaddv(void* rd, void* rs1, void* rs2);

int kaddv2(void* rd, void* rs1, void* rs2, int size);

int kdotp(void* rd, void* rs1, void* rs2);

int kdotp2(void* rd, void* rs1, void* rs2, int size);

int kless_dot_product(void *dest, void* src1, void* src2, int size);

int kless_vector_addition(void *dest, void* src1, void* src2, int size);

int kmemld(void* rd, void* rs1, int rs2);

int kmemstr(void* rd, void* rs1, int rs2);

#endif
