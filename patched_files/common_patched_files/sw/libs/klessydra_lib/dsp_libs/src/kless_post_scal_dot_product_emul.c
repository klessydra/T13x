#include <stdlib.h>
#include"dsp_functions.h"

void* kless_post_scal_dot_product_emul(void *result, void* src1, void* src2, void* p_scal, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	char scalar_size = 4;
	asm volatile(
		"SCP_copyin_vect_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"SCP_copyin_vect_2:"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xBF0, %[sz]; "
        "	kvmul %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
        "	ksrav %[SPMADDRC], %[SPMADDRC], %[p_scal];"
        "	kvred %[SPMADDRC], %[SPMADDRC];"
		"	kmemstr %[result], %[SPMADDRC], %[sc_sz];"
		"END:"
		:
		:[SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [sz] "r" (size), [p_scal] "r" (p_scal), [sc_sz] "r" (scalar_size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}
