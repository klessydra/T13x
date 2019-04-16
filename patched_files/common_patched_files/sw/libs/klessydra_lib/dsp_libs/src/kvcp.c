#include"dsp_functions.h"

int kvcp(void* rd, void* rs1)
{
	__asm__(
		"kvcp %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvcp_v2(void* rd, void* rs1, int size)
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
