#include"dsp_functions.h"

__attribute__ ((always_inline)) inline int kdotpps_emul(void* rd, void* rs1, void* rs2, void* p_scal)
{
	__asm__(
        "kvmul %[rd], %[rs1], %[rs2];"
        "ksrav %[rd], %[rd], %[p_scal];"
        "kvred %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return sizeof(rd);
}

__attribute__ ((always_inline)) inline int kdotpps_emul_v2(void* rd, void* rs1, void* rs2, void* p_scal, int size)
{
	__asm__(
        "csrw 0xBF0, %[size];"
        "kvmul %[rd], %[rs1], %[rs2];"
        "ksrav %[rd], %[rd], %[p_scal];"
        "kvred %[rd], %[rd];"
		://no output register
		:[p_scal] "r" (p_scal), [size] "r" (size), [rd] "r" (rd), [rs1] "r" (rs1), [rs2] "r" (rs2)
		:/*no clobbered registers*/
	);
	
	return 1;
}

