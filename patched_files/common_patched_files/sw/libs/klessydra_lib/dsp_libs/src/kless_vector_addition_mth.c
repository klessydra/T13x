#include <stdlib.h>
#include"dsp_functions.h"

void* kless_vector_addition_mth(void *result, void* src1, void* src2, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	int key = 1;
	static int section1 = 0;
	static int section2 = 0;
	int* psection1 = &section1;
	int* psection2 = &section2;
	asm volatile(
		"	amoswap.w.aq %[key], %[key], (%[psection1]);"
		"	bnez %[key], SCP_copyin_vect_2;"
		"SCP_copyin_vect_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END;"
		"SCP_copyin_vect_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], RESET;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xBF0, %[sz]; "
		"	kaddv %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"	j END;"
		"RESET:"
		"	sw x0, 0(%[psection1]);"
		"	sw x0, 0(%[psection2]);"
		"END:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),  [sz] "r" (size),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}
