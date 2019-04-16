#include <stdlib.h>
#include"dsp_functions.h"

int8_t* kless_vector_reduction_8(void *result, void* src, int size)
{
	int key = 1;
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	static int section1 = 0;
	char scalar_size = 4;
	int* psection1 = &section1;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], END8;"
		"SCP_copyin_vect8:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	kvred8 %[SPMADDRB], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRB], %[sc_sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [src] "r" (src), [sz] "r" (size),  [sc_sz] "r" (scalar_size),
		 [SPMADDRA] "r" (SPMADDRA), [SPMADDRB] "r" (SPMADDRB), [result] "r" (result)
		:
	);
	return result;
}

int16_t* kless_vector_reduction_16(void *result, void* src, int size)
{
	int key = 1;
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	static int section1 = 0;
	char scalar_size = 4;
	int* psection1 = &section1;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], END16;"
		"SCP_copyin_vect16:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	kvred16 %[SPMADDRB], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRB], %[sc_sz];"
		"END16:"
		:
		:[key] "r" (key), [psection1] "r" (psection1),
		 [src] "r" (src), [sz] "r" (size),  [sc_sz] "r" (scalar_size),
         [SPMADDRA] "r" (SPMADDRA), [SPMADDRB] "r" (SPMADDRB), [result] "r" (result)
		:
	);
	return result;
}

int32_t* kless_vector_reduction_32(void *result, void* src, int size)
{
	int key = 1;
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	static int section1 = 0;
	char scalar_size = 4;
	int* psection1 = &section1;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], END32;"
		"SCP_copyin_vect32:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	kvred32 %[SPMADDRB], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRB], %[sc_sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [src] "r" (src), [sz] "r" (size),  [sc_sz] "r" (scalar_size),
         [SPMADDRA] "r" (SPMADDRA), [SPMADDRB] "r" (SPMADDRB), [result] "r" (result)
		:
	);
	return result;
}
