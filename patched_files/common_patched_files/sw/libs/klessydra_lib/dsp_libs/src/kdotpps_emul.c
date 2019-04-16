#include"dsp_functions.h"

int kdotpps8_emul(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "kvmul8 %[rd], %[rs1], %[rs2];"
        "ksrav8 %[rd], %[rd], %[p_scal];"
        "kvred8 %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotpps8_emul_v2(void* rd, void* rs1, void* rs2, void* p_scal, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "kvmul8 %[rd], %[rs1], %[rs2];"
        "ksrav8 %[rd], %[rd], %[p_scal];"
        "kvred8 %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}


int kdotpps16_emul(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "kvmul16 %[rd], %[rs1], %[rs2];"
        "ksrav16 %[rd], %[rd], %[p_scal];"
        "kvred16 %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotpps16_emul_v2(void* rd, void* rs1, void* rs2, void* p_scal, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "kvmul16 %[rd], %[rs1], %[rs2];"
        "ksrav16 %[rd], %[rd], %[p_scal];"
        "kvred16 %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}


int kdotpps32_emul(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "kvmul32 %[rd], %[rs1], %[rs2];"
        "ksrav32 %[rd], %[rd], %[p_scal];"
        "kvred32 %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

int kdotpps32_emul_v2(void* rd, void* rs1, void* rs2, void* p_scal, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "kvmul32 %[rd], %[rs1], %[rs2];"
        "ksrav32 %[rd], %[rd], %[p_scal];"
        "kvred32 %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

