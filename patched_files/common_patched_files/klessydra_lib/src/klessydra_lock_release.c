#include"functions.h"

void klessydra_lock_release(int *lock)
{
	__asm__(
		"amoswap.w.rl x0, x0, (%0);"// Release lock by storing 0.
		://no output
		:"r" (lock)
		://no clobbered register
	);
}
