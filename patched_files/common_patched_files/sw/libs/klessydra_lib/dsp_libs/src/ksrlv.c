#include"dsp_functions.h"

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
