#include <stdlib.h>
#include"dsp_functions.h"

void* kless_vector_addition_sth_sw_loop(void *result, void* src1, void* src2, int size, int SIMD_BYTES)
{
	int SPMADDRA = spmaddrA;
	int SPMADDRB = spmaddrB;
	int SPMADDRC = spmaddrC;
	int size_temp = size;
	asm volatile(
		"SCP_copyin_vect_1:"
		"	kmemld %[SPMADDRA], %[srcA], %[size_temp];"
		"SCP_copyin_vect_2:"
		"	kmemld %[SPMADDRB], %[srcB], %[size_temp];"
		"	csrw 0xBF0, %[SIMD_BYTES];"
		:
		:[size_temp] "r" (size_temp), [SIMD_BYTES] "r" (SIMD_BYTES),
		 [SPMADDRA] "r" (SPMADDRA), [srcA] "r" (src1),
		 [SPMADDRB] "r" (SPMADDRB), [srcB] "r" (src2)
	);
	for (int i=0; i<size; i=i+SIMD_BYTES)
	{
		if (size-i >= SIMD_BYTES)
		{
			size = size-i;
			asm volatile(
				"	kaddv %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
				:
				:
				 [SPMADDRA] "r" (SPMADDRA),
				 [SPMADDRB] "r" (SPMADDRB),
   		    	 [SPMADDRC] "r" (SPMADDRC)
			);
			SPMADDRA+=SIMD_BYTES;
			SPMADDRB+=SIMD_BYTES;
			SPMADDRC+=SIMD_BYTES;
		}
		else
		{
			size = i;
			asm volatile(
				"	csrw 0xBF0, %[size];"
				"	kaddv %[SPMADDRC], %[SPMADDRA], %[SPMADDRB];"
				:
				:
				 [SPMADDRA] "r" (SPMADDRA) ,
				 [SPMADDRB] "r" (SPMADDRB) ,
   		    	 [SPMADDRC] "r" (SPMADDRC) ,
   		    	 [size] "r" (size)
			);
		}
	}
	SPMADDRC=spmaddrC;
	asm volatile(
		"	kmemstr %[result], %[SPMADDRC], %[size_temp];"
		:
		:[size_temp] "r" (size_temp), [SIMD_BYTES] "r" (SIMD_BYTES),
         [SPMADDRC] "r" (SPMADDRC), [result] "r" (result)
	);
	return result;
}
