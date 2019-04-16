#include"dsp_functions.h"

int kvmuladd8(void* rd, void* rs1, void* rs2, void* rs3)
{
	__asm__(
		"ksvmulsc8 %[rd], %[rs2], %[rs3];"
		"kaddv8 %[rd], %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvmuladd8_v2(void* rd, void* rs1, void* rs2, void* rs3, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
		"ksvmulsc8 %[rd], %[rs2], %[rs3];"
		"kaddv8 %[rd], %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvmuladd16(void* rd, void* rs1, void* rs2, void* rs3)
{
	__asm__(
		"ksvmulsc16 %[rd], %[rs2], %[rs3];"
		"kaddv16 %[rd], %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvmuladd16_v2(void* rd, void* rs1, void* rs2, void* rs3, int size)
{
	__asm__(
  		"csrw 0xBF0, %[size];"
		"ksvmulsc16 %[rd], %[rs2], %[rs3];"
		"kaddv16 %[rd], %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvmuladd32(void* rd, void* rs1, void* rs2, void* rs3)
{
	__asm__(
		"ksvmulsc32 %[rd], %[rs2], %[rs3];"
		"kaddv32 %[rd], %[rd], %[rs1];"
		://no output register
		:[rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kvmuladd32_v2(void* rd, void* rs1, void* rs2, void* rs3, int size)
{
	__asm__(
  		"csrw 0xBF0, %[size];"
		"ksvmulsc32 %[rd], %[rs2], %[rs3];"
		"kaddv32 %[rd], %[rd], %[rs1];"
		://no output register
		:[size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2), [rs3] "r" (rs3)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

