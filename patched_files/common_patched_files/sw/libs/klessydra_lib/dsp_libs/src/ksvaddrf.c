#include"dsp_functions.h"

int ksvaddrf8(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvaddrf8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksvaddrf8_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvaddrf8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int ksvaddrf16(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvaddrf16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksvaddrf16_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvaddrf16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}


int ksvaddrf32(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvaddrf32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksvaddrf32_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvaddrf32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
