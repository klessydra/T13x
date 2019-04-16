#include"dsp_functions.h"

int krelu8(void* rd, void* rs1)
{
	__asm__(
		"krelu8 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int krelu8_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"krelu8 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int krelu16(void* rd, void* rs1)
{
	__asm__(
		"krelu16 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int krelu16_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"krelu16 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int krelu32(void* rd, void* rs1)
{
	__asm__(
		"krelu32 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int krelu32_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"krelu32 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}
