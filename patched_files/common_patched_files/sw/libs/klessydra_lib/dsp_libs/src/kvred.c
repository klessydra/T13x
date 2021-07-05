#include"dsp_functions.h"

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

