#include <stdlib.h>
#include"dsp_functions.h"

void* kless_post_scal_dot_product_mth(void *result, void* src1, void* src2, void* p_scal, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	int key = 1;
	char scalar_size = 4;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect_2;"
		"SCP_copyin_vect_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END;"
		"SCP_copyin_vect_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xBF0, %[sz]; "
		"	csrw 0xBE0, %[p_scal]; "
		"	kdotpps %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sc_sz];"
		"END:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [sz] "r" (size), [p_scal] "r" (p_scal), [sc_sz] "r" (scalar_size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}
