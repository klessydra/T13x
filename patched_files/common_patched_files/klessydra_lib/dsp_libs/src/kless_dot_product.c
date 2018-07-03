#include"dsp_functions.h"

int kless_dot_product(void *dest, void* src1, void* src2, int size)
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
		"bnez %0, SCP_copyin_vect2;"
		"SCP_copyin_vect1:"
		"	kmemld %[SPMADDRA], %[srcA], %[sz];"
		"       csrs 0x300, 0x8;"
		"	wfi;"
		"SCP_copyin_vect2:"
                "       sw zero, 0(%[psection1]);"
		"	amoswap.w.aq %[key], %[key], (%[psection1]);"
		"	bnez %[key], Halt_Thread2;"
		"	kmemld %[SPMADDRB], %[srcB], %[sz];"
                "       j SCP_vadd;"
		"Halt_Thread2:"
		"       csrs 0x300, 0x8;"
		"	wfi;"
                "SCP_vadd:"
		"	csrw 0xFF0, %[sz]; "
		"	kdotp %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
		"	kmemstr %[dst], %[SPMADDRC], %[sz];"
		:
		:[key] "r" (key),[psection1] "r" (psection1),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1), [sz] "r" (size),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2),
                 [SPMADDRC] "r" (SPMADDRC), [dst] "r" (dest)
		:
	);
	return dest;
}
