#include"dsp_functions.h"

int kaddv8(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kaddv8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kaddv8_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kaddv8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kaddv16(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kaddv16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kaddv16_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"kaddv16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kaddv32(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kaddv32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kaddv32_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"kaddv32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
