#include"functions.h"

void klessydra_lock_acquire(int *lock)
{
	int temp0 = 1;	
		
	__asm__(
		"loop: "
		"amoswap.w.aq %1, %1, (%0);"
		"bnez %1,loop;"
		://no output register
		:"r" (lock), "r" (temp0)
		:/*no clobbered registers*/
	);
}
