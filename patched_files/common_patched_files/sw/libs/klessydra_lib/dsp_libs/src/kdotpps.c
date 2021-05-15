#include"dsp_functions.h"

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

