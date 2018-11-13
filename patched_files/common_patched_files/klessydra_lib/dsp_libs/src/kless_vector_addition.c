#include"dsp_functions.h"

int* kless_vector_addition_8(void *result, void* src1, void* src2, int size)
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
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect8_2;"
		"SCP_copyin_vect8_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END8;"
		"SCP_copyin_vect8_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END8;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xFF0, %[sz]; "
		"	kaddv8 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),  [sz] "r" (size),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return (int*)result;
}

int* kless_vector_addition_16(void *result, void* src1, void* src2, int size)
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
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect16_2;"
		"SCP_copyin_vect16_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END8;"
		"SCP_copyin_vect16_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END8;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xFF0, %[sz]; "
		"	kaddv16 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END16:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),  [sz] "r" (size),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return (int*)result;
}

int* kless_vector_addition_32(void *result, void* src1, void* src2, int size)
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
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect32_2;"
		"SCP_copyin_vect32_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END8;"
		"SCP_copyin_vect32_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END8;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xFF0, %[sz]; "
		"	kaddv32 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),  [sz] "r" (size),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return (int*)result;
}
