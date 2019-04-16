#include <stdlib.h>
#include"dsp_functions.h"

int8_t* kless_rectify_linear_unit_8(void *result, void* src, int size)
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
		"SCP_copyin_vect8:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	krelu8 %[SPMADDRC], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [src] "r" (src), [sz] "r" (size),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}

int16_t* kless_rectify_linear_unit_16(void *result, void* src, int size)
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
		"SCP_copyin_vect16:"
		"	kmemld %[SPMADDRA], %[src], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	krelu16 %[SPMADDRC], %[SPMADDRA];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END16:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [src] "r" (src), [sz] "r" (size),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}

int32_t* kless_rectify_linear_unit_32(void *result, void* src, int size)
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
		"	krelu32 %[SPMADDRC], %[SPMADDRA];"
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
