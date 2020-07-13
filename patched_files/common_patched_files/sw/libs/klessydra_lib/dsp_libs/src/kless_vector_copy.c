#include <stdlib.h>
#include"dsp_functions.h"

void* kless_vector_copy(void *result, void* src, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	asm volatile(
		"SCP_copyin_vect:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	kvcp %[SPMADDRC], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END:"
		:
		:[SPMADDRA] "r" (SPMADDRA), [src] "r" (src), [sz] "r" (size),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}
