#include"dsp_functions.h"

__attribute__ ((always_inline)) inline void CSR_MVSIZE(int rs1)
{
	__asm__(
		"csrw 0xBF0, %0;"
		://no output register
		:"r" (rs1)
		:/*no clobbered register*/
	);	
}
