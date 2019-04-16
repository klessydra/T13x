#include"dsp_functions.h"

int kbcast8(void* rd, void* rs1)
{
	__asm__(
		"kbcast8 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kbcast8_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kbcast8 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kbcast16(void* rd, void* rs1)
{
	__asm__(
		"kbcast16 %[rd], %[rs1];"
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
		"kbcast16 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kbcast32(void* rd, void* rs1)
{
	__asm__(
		"kbcast32 %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kbcast32_v2(void* rd, void* rs1, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kbcast32 %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1)
		:/*no clobbered registers*/
	);
	
	return 1;
}
