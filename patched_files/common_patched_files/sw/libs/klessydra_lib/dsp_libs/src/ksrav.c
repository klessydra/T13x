#include"dsp_functions.h"

int ksrav8(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrav8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksrav8_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"ksrav8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int ksrav16(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrav16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksrav32(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrav32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksrav32_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"ksrav32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
