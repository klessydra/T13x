#include"dsp_functions.h"

int kdotp2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xFF0, %[size];"
		"kdotp %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
