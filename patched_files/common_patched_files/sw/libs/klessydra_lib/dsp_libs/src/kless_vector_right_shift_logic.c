#include <stdlib.h>
#include"dsp_functions.h"

uint8_t* kless_vector_right_shift_logic_8(void *result, void* src1, void* src2, int size)
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
		"bnez %[key], END8;"
		"SCP_copyin_vect8:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	ksrlv8 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}

uint16_t* kless_vector_right_shift_logic_16(void *result, void* src1, void* src2, int size)
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
		"bnez %[key], END16;"
		"SCP_copyin_vect16:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	ksrlv16 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END16:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}

uint32_t* kless_vector_right_shift_logic_32(void *result, void* src1, void* src2, int size)
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
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	csrw 0xBF0, %[sz];"
		"	ksrlv32 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}
