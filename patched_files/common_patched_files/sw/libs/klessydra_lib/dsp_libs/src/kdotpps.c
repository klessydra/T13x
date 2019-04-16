#include"dsp_functions.h"

int kdotpps8(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotpps8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotpps8_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kdotpps8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps8_v3(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "csrw 0xBF4, %[p_scal];"
		"kdotpps8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps8_v4(void* rd, void* rs1, void* rs2, void* p_scal,  int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "csrw 0xBF4, %[p_scal];"
		"kdotpps8 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps16(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotpps16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotpps16_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kdotpps16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps16_v3(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "csrw 0xBF4, %[p_scal];"
		"kdotpps16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps16_v4(void* rd, void* rs1, void* rs2, void* p_scal, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "csrw 0xBF4, %[p_scal];"
		"kdotpps16 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps32(void* rd, void* rs1, void* rs2)
{
	__asm__(
		"kdotpps32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotpps32_v2(void* rd, void* rs1, void* rs2, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"kdotpps32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps32_v3(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "csrw 0xBF4, %[p_scal];"
		"kdotpps32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

int kdotpps32_v4(void* rd, void* rs1, void* rs2, void* p_scal, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "csrw 0xBF4, %[p_scal];"
		"kdotpps32 %[rd], %[rs1], %[rs2];"
		://no output register
		:[size] "r" (size), [p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}
