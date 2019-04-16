#include"dsp_functions.h"

int ksrlv8(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrlv8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksrlv8_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"ksrlv8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int ksrlv16(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrlv16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksrlv32(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"ksrlv32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int ksrlv32_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"ksrlv32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
