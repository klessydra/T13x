#include <stdlib.h>
#include"dsp_functions.h"

int8_t* kless_scalar_broadcast_8(void *result, void* dest, void* src, int size)
{
	int key = 1;
	static int section1 = 0;
	int* psection1 = &section1;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], END8;"
		"SCP_copyin_vect8:"
		"	csrw 0xBF0, %[sz];"
		"	kbcast8 %[dest], %[src];"
		"	kmemstr %[result], %[dest], %[sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [src] "r" (src), [sz] "r" (size),
		 [dest] "r" (dest), [result] "r" (result)
		:
	);
	return result;
}

int16_t* kless_scalar_broadcast_16(void *result, void* dest, void* src, int size)
{
	int key = 1;
	static int section1 = 0;
	int* psection1 = &section1;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], END16;"
		"SCP_copyin_vect16:"
		"	csrw 0xBF0, %[sz];"
		"	kbcast16 %[dest], %[src];"
		"	kmemstr %[result], %[dest], %[sz];"
		"END16:"
		:
		:[key] "r" (key), [psection1] "r" (psection1),
		 [src] "r" (src), [sz] "r" (size),
         [dest] "r" (dest), [result] "r" (result)
		:
	);
	return result;
}

int32_t* kless_scalar_broadcast_32(void *result, void* dest, void* src, int size)
{
	int key = 1;
	static int section1 = 0;
	int* psection1 = &section1;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], END32;"
		"SCP_copyin_vect32:"
		"	csrw 0xBF0, %[sz];"
		"	kbcast32 %[dest], %[src];"
		"	kmemstr %[result], %[dest], %[sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [src] "r" (src), [sz] "r" (size),
         [dest] "r" (dest), [result] "r" (result)
		:
	);
	return result;
}
