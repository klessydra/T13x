#include <stdlib.h>
#include"dsp_functions.h"

void* kless_vector_right_shift_arith(void *result, void* src1, void* src2, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	asm volatile(
		"SCP_copyin_vect:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	ksrav %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END:"
		:
		:[SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [srcB] "r" (src2), [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}
