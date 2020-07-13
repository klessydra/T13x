#include <stdlib.h>
#include"dsp_functions.h"

void* kless_scalar_broadcast(void *result, void* dest, void* src, int size)
{
	asm volatile(
		"SCP_copyin_vect:"
		"	csrw 0xBF0, %[sz];"
		"	kbcast %[dest], %[src];"
		"	kmemstr %[result], %[dest], %[sz];"
		"END:"
		:
		:[src] "r" (src), [sz] "r" (size),
		 [dest] "r" (dest), [result] "r" (result)
		:
	);
	return result;
}
