#include"dsp_functions.h"

__attribute__ ((always_inline)) inline int kvmuladd8(void* rd, void* rs1, void* rs2, void* rs3)
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

__attribute__ ((always_inline)) inline int kvmuladd8_v2(void* rd, void* rs1, void* rs2, void* rs3, int size)
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
