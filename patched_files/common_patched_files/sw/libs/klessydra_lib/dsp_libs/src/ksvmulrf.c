#include"dsp_functions.h"

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

