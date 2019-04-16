#include <stdlib.h>
#include"dsp_functions.h"

int8_t* kless_post_scal_dot_product_emul_8(void *result, void* src1, void* src2, void* p_scal, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	int key = 1;
	char scalar_size = 4;
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
		"	csrw 0xBF0, %[sz]; "
        "	kvmul8 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
        "	ksrav8 %[SPMADDRC], %[SPMADDRC], %[p_scal];"
        "	kvred8 %[SPMADDRC], %[SPMADDRC];"
		"	kmemstr %[result], %[SPMADDRC], %[sc_sz];"
		"END8:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [sz] "r" (size), [p_scal] "r" (p_scal), [sc_sz] "r" (scalar_size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}

int16_t* kless_post_scal_dot_product_emul_16(void *result, void* src1, void* src2, void* p_scal, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	int key = 2;
	char scalar_size = 4;
	static int section1 = 0;
	static int section2 = 0;
	int* psection1 = &section1;
	int* psection2 = &section2;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect16_2;"
		"SCP_copyin_vect16_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END16;"
		"SCP_copyin_vect16_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END16;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xBF0, %[sz]; "
        "	kvmul16 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
        "	ksrav16 %[SPMADDRC], %[SPMADDRC], %[p_scal];"
        "	kvred16 %[SPMADDRC], %[SPMADDRC];"
		"	kmemstr %[result], %[SPMADDRC], %[sc_sz];"
		"END16:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [sz] "r" (size),  [p_scal] "r" (p_scal), [sc_sz] "r" (scalar_size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}

int32_t* kless_post_scal_dot_product_emul_32(void *result, void* src1, void* src2, void* p_scal, int size)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int SPMADDRD = spmaddrD;
	int key = 3;
	char scalar_size = 4;
	static int section1 = 0;
	static int section2 = 0;
	int* psection1 = &section1;
	int* psection2 = &section2;
	asm volatile(
		"amoswap.w.aq %[key], %[key], (%[psection1]);"
		"bnez %[key], SCP_copyin_vect32_2;"
		"SCP_copyin_vect32_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"	j END32;"
		"SCP_copyin_vect32_2:"
		"	amoswap.w.aq %[key], %[key], (%[psection2]);"
		"	bnez %[key], END32;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
		"	csrw 0xBF0, %[sz]; "
        "	kvmul32 %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
        "	ksrav32 %[SPMADDRC], %[SPMADDRC], %[p_scal];"
        "	kvred32 %[SPMADDRC], %[SPMADDRC];"
		"	kmemstr %[result], %[SPMADDRC], %[sc_sz];"
		"END32:"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
         [psection2] "r" (psection2),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [sz] "r" (size),  [p_scal] "r" (p_scal), [sc_sz] "r" (scalar_size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}
