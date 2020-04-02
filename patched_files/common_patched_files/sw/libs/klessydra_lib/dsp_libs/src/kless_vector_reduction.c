#include <stdlib.h>
#include"dsp_functions.h"

void* kless_vector_reduction(void *result, void* src, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	char scalar_size = 4;
	asm volatile(
		"SCP_copyin_vect:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	kvred %[SPMADDRB], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRB], %[sc_sz];"
		"END:"
		:
		:[src] "r" (src), [sz] "r" (size),  [sc_sz] "r" (scalar_size),
		 [SPMADDRA] "r" (SPMADDRA), [SPMADDRB] "r" (SPMADDRB), [result] "r" (result)
		:
	);
	return result;
}

