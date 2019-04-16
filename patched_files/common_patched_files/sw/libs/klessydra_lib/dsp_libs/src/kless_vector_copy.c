#include <stdlib.h>
#include"dsp_functions.h"

uint32_t* kless_vector_copy(void *result, void* src, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	int key = 1;
	static int section1 = 0;
	int* psection1 = &section1;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], END32;"
		"SCP_copyin_vect32:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	kvcp %[SPMADDRC], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [src] "r" (src), [sz] "r" (size),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}
