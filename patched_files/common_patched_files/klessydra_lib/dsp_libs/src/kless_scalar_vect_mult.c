#include"dsp_functions.h"

int* kless_scalar_vect_mult_8(void* result, void* src1, void* src2, int size)
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
		"	csrw 0xFF0, %[sz];"
		"	ksvmul8 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"   add %[sz], %[sz], %[sz];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return (int*)result;
}

int* kless_scalar_vect_mult_16(void* result, void* src1, void* src2, int size)
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
		"	csrw 0xFF0, %[sz];"
		"	ksvmul16 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"   add %[sz], %[sz], %[sz];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END16:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return (int*)result;
}

int* kless_scalar_vect_mult_32(void* result, void* src1, void* src2, int size)
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
		"	csrw 0xFF0, %[sz];"
		"	ksvmul32 %[SPMADDRC], %[SPMADDRA], %[srcB];"
		"   add %[sz], %[sz], %[sz];"
		"	kmemstr %[result], %[SPMADDRC], %[sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
		:
	);
	return (int*)result;
}
