#include"dsp_functions.h"

int ksvmul8(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvmul8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksvmul8_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xFF0, %[size];"
		"ksvmul8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int ksvmul16(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvmul16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksvmul16_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xFF0, %[size];"
		"ksvmul16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}


int ksvmul32(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksvmul32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksvmul32_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xFF0, %[size];"
		"ksvmul32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
