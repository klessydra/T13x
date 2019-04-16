#include"dsp_functions.h"

int kdotp8(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotp8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotp8_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kdotp8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotp16(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotp16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotp32(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotp32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotp32_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
                "csrw 0xBF0, %[size];"
		"kdotp32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
