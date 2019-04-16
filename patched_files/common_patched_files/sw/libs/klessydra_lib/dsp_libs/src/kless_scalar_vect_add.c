#include <stdlib.h>
#include"dsp_functions.h"

int8_t* kless_scalar_vect_add_rf_8(void* result, void* src1, void* src2, int size)
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
		"	ksvaddrf8 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}

int16_t* kless_scalar_vect_add_rf_16(void* result, void* src1, void* src2, int size)
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
		"	ksvaddrf16 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END16:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}

int32_t* kless_scalar_vect_add_rf_32(void* result, void* src1, void* src2, int size)
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
		"	ksvaddrf32 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return result;
}

int8_t* kless_scalar_vect_add_sc_8(void *result, void* src1, void* src2, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	char scalar_size = 1;
	int key = 1;
	static int section1 = 0;
	static int section2 = 0;
	int* psection1 = &section1;
	int* psection2 = &section2;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect8_2;"
		"SCP_copyin_vect8_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END_8;"
		"SCP_copyin_vect8_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END_8;"
		"	kmemld %[SPMADDRB], %[srcB], %[sc_sz];"
		"	csrw 0xBF0, %[sz]; "
		"	ksvaddsc8 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END_8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),
         [sz] "r" (size), [sc_sz] "r" (scalar_size),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}

int16_t* kless_scalar_vect_add_sc_16(void *result, void* src1, void* src2, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	char scalar_size = 2;
	int key = 1;
	static int section1 = 0;
	static int section2 = 0;
	int* psection1 = &section1;
	int* psection2 = &section2;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect16_2;"
		"SCP_copyin_vect16_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END_16;"
		"SCP_copyin_vect16_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END_16;"
		"	kmemld %[SPMADDRB], %[srcB], %[sc_sz];"
		"	csrw 0xBF0, %[sz]; "
		"	ksvaddsc16 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END_16:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),
         [sz] "r" (size), [sc_sz] "r" (scalar_size),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}

int32_t* kless_scalar_vect_add_sc_32(void *result, void* src1, void* src2, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	char scalar_size = 4;
	int key = 1;
	static int section1 = 0;
	static int section2 = 0;
	int* psection1 = &section1;
	int* psection2 = &section2;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect32_2;"
		"SCP_copyin_vect32_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END_32;"
		"SCP_copyin_vect32_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END_32;"
		"	kmemld %[SPMADDRB], %[srcB], %[sc_sz];"
		"	csrw 0xBF0, %[sz]; "
		"	ksvaddsc32 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END_32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),  
         [sz] "r" (size), [sc_sz] "r" (scalar_size),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}
