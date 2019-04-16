#include"dsp_functions.h"

int kvred8(void* rd, void* rs1)
{
	__asm__(
		"kvred8 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvredt8_v2(void* rd, void* rs1, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"kvred8 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kvred16(void* rd, void* rs1)
{
	__asm__(
		"kvred16 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kbacst16_v2(void* rd, void* rs1, int size)
{
	__asm__(
		"csrw 0xBF0, %[size];"
		"kvred16 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kvred32(void* rd, void* rs1)
{
	__asm__(
		"kvred32 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvred32_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kvred32 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}
