#include <stdint.h>
#include "klessydra_defs.h"

#define MHARTID_IDCORE_MASK 15
#define THREAD_POOL_SIZE 4

/*
If the user adds more scratchpad in the rtl, he must define more scratchpads belwo i.e. spmaddrE, spmaddrF etc..
If the user changes the starting address of the scratchpads in the rtl, he must also change the define values below
*/

#ifdef KLESS_SPM_A
#define spmaddrA KLESS_SPM_A
#endif 
#ifdef KLESS_SPM_B
#define spmaddrB KLESS_SPM_B
#endif
#ifdef KLESS_SPM_C
#define spmaddrC KLESS_SPM_C
#endif
#ifdef KLESS_SPM_D
#define spmaddrD KLESS_SPM_D
#endif

#ifndef KLESS_SPM_A
#define spmaddrA 0x10000000  // Default startung address of SPMA
#endif
#ifndef KLESS_SPM_B
#define spmaddrB 0x10001000  // Default startung address of SPMB
#endif
#ifndef KLESS_SPM_C
#define spmaddrC 0x10002000  // Default startung address of SPMC
#endif
#ifndef KLESS_SPM_D
#define spmaddrD 0x10003000  // Default startung address of SPMD
#endif

/*

*/

#ifndef __KLESSYDRACFUNCTIONS_H__
#define __KLESSYDRACFUNCTIONS_H__

int Klessydra_get_coreID();

__attribute__ ((always_inline)) inline void CSR_MVSIZE(int MYSIZE)
{
	__asm__(
		"csrw 0xBF0, %0;"
		://no output register
		:"r" (MYSIZE)
		:/*no clobbered register*/
	);	
}

__attribute__ ((always_inline)) inline void CSR_MVTYPE(int MVTYPE)
{
	__asm__(
		"csrw 0xBF8, %0;"
		://no output register
		:"r" (MVTYPE)
		:/*no clobbered register*/
	);	
}

__attribute__ ((always_inline)) inline int CSR_MPSCLFAC(int MPSCLFAC)
{
	__asm__(
        "csrw 0xBE0, %[p_scal];"
		://no output register
		:[p_scal] "r" (MPSCLFAC)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kmemld(void* rd, void* rs1, int rs2)
{
	__asm__(
		"kmemld %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return rs2;
}

__attribute__ ((always_inline)) inline int kbcastld(void* rd, void* rs1, int rs2)
{
	__asm__(
		"kbcastld %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return rs2;
}

__attribute__ ((always_inline)) inline int kmemstr(void* rd, void* rs1, int rs2)
{
	__asm__(
		"kmemstr %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return rs2;
}

__attribute__ ((always_inline)) inline int kaddv(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kaddv %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kaddv_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kaddv %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int ksvaddrf(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvaddrf %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksvaddrf_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvaddrf %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int ksvaddsc(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvaddsc %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksvaddsc_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvaddsc %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int ksubv(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksubv %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksubv_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksubv %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kvmul(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kvmul %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kvmul_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kvmul %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int ksvmulrf(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvmulrf %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksvmulrf_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvmulrf %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline  int ksvmulsc(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvmulsc %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksvmulsc_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvmulsc %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kvmuladd(void* rd, void* rs1, void* rs2, void* rs3)
{
	__asm__(
		"ksvmulsc %[rd], %[rs2], %[rs3];"
		"kaddv %[rd], %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kvmuladd_v2(void* rd, void* rs1, void* rs2, void* rs3, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvmulsc %[rd], %[rs2], %[rs3];"
		"kaddv %[rd], %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kdotp(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotp %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kdotp_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kdotp %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kdotpps(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotpps %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kdotpps_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kdotpps %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kdotpps_v3(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "csrw 0xBE0, %[p_scal];"
		"kdotpps %[rd], %[rs1], %[rs2];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kdotpps_v4(void* rd, void* rs1, void* rs2, void* p_scal,  int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "csrw 0xBE0, %[p_scal];"
		"kdotpps %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kdotpps_emul_v3(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "kvmul %[rd], %[rs1], %[rs2];"
        "ksrav %[rd], %[rd], %[p_scal];"
        "kvred %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kdotpps_emul_v4(void* rd, void* rs1, void* rs2, void* p_scal, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "kvmul %[rd], %[rs1], %[rs2];"
        "ksrav %[rd], %[rd], %[p_scal];"
        "kvred %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kvred(void* rd, void* rs1)
{
	__asm__(
		"kvred %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kvred_v2(void* rd, void* rs1, int size)
{
	__asm__(
		"csrw 0xBF0, %[size];"
		"kvred %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int ksrav(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrav %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksrav_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksrav %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int ksrlv(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrlv %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksrlv_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
		"csrw 0xBF0, %[size];"
		"ksrlv %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int krelu(void* rd, void* rs1)
{
	__asm__(
		"krelu %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int krelu_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"krelu %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kvslt(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kvslt %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kvslt_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kvslt %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int ksvslt(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvslt %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int ksvslt_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvslt %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kbcast(void* rd, void* rs1)
{
	__asm__(
		"kbcast %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kbcast_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kbcast %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

__attribute__ ((always_inline)) inline int kvcp(void* rd, void* rs1)
{
	__asm__(
		"kvcp %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kvcp_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kvcp %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

/*
The three functions below perfrom full dot product using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does dot product between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void* kless_dot_product(void* result, void* src1, void* src2, int size);
/*
The three functions below perfrom full vector addition using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does vector addition between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/

void* kless_vector_addition_sth(void* result, void* src1, void* src2, int size);

void* kless_vector_addition_mth(void* result, void* src1, void* src2, int size);

void* kless_vector_addition_sth_sw_loop(void* result, void* src1, void* src2, int size, int SIMD_BYTES);
/*
The three functions below perfrom multiply the corresponding vector elements in the sources by each other
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does vector addition between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void* kless_vector_multiplication(void *result, void* src1, void* src2, int size);

/*
The three functions below perfrom full dot product including post scaling between
the multiplication and the accumulation using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does post scaling dot product between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void* kless_post_scal_dot_product(void *result, void* src1, void* src2, void* p_scal, int size);

/*
The three functions below perfrom "through emulation" full dot product including
post scaling between the multiplication and the accumulation using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 emulates post scaling dot product between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void* kless_post_scal_dot_product_emul(void *result, void* src1, void* src2, void* p_scal, int size);

/*
The three functions below perfrom full vector addition using multi-threading
thread 1 loads the vector (of size int size) from main memory into spmA and exits
thread 2 does vector reduction by accumulatin the elements in vect1
thread 2 then stores the value back in the main memory at the address in "result"
*/
void* kless_vector_reduction(void *result, void* src, int size);

/*
The three functions below perfrom full vector subtraction using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does vector subtraction between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void*  kless_vector_subtraction(void* result, void* src1, void* src2, int size);


/*
The three functions below perfrom full right arithmetic shift using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does right arithmetic shift between vect1 and the shift amount in src2
thread 2 then stores the value back in the main memory at the address in "result"
*/
void*  kless_vector_right_shift_arith(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full right logic shift using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does right logic shift between vect1 and the shift amount in src2
thread 2 then stores the value back in the main memory at the address in "result"
*/
void*  kless_vector_right_shift_logic(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full scalar vector addition using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does scalar vector addition between vect1 and the scalar in src2 (src2 is not pointer)
thread 2 then stores the value back in the main memory at the address in "result"
*/
void*  kless_scalar_vect_add_rf(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full scalar vector addition using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads scalar 1 from main memory into spmB and exits
thread 3 does scalar vector addition between vect1 and the scalar in src2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void*  kless_scalar_vect_add_sc(void* result, void* src1, void* src2, int size);
/*
The three functions below perfrom full scalar vector multiplication using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does scalar vector multiplication between vect1 and the scalar in src2 (src2 is not a pointer)
thread 2 then stores the value back in the main memory at the address in "result"
*/
void*  kless_scalar_vect_mult_rf(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full scalar vector multiplication using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads scalar 1 from main memory into spmB and exits
thread 3 does scalar vector multiplication between vect1 and the scalar in src2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void*  kless_scalar_vect_mult_sc(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full vector rectification using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does vector rectification of vect1
thread 2 then stores the value back in the main memory at the address in "result"
*/
void*  kless_rectify_linear_unit(void* result, void* src1, int size);

void*  kless_vector_set_less_than(void* result, void* src1, void* src2, int size);

void*  kless_scalar_vect_set_less_than(void* result, void* src1, void* src2, int size);
/*
The three functions below perfrom vector broadcast
there are no vector loads in this function
thread 1 does vector broadcast of the "src" (src is a scalar and not a pointer) into "dest
thread 1 then stores the value of "dest" back in the main memory at the address in "result"
*/
void*  kless_scalar_broadcast(void *result, void *dest, void* src, int size);

/*
TThe function below is for debugging purposes and might not serve useful to the user, use
instead the function called "kvcp" or "kvcp_v2" to od vector copies
it laods a vector from main mem into spmA,
the vector spmA is copied into spmB. and the resut is stored back in the main memory
at the index in "result
*/
void* kless_vector_copy(void* result, void* src1, int size);

#endif
