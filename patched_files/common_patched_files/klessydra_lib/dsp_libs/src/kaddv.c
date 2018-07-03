#include"dsp_functions.h"

int kaddv(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kaddv %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}
