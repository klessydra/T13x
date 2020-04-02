#include"functions.h"

void sync_barrier_reset()
{
    int i;
	int key = 1;
	static int section = 0;
	int* ptr_section = &section;
	asm volatile
	(
		"csrrw zero, mstatus, 8;" 
		"amoswap.w.aq %[key], %[key], (%[ptr_section]);"
		:
		:[key] "r" (key), [ptr_section] "r" (ptr_section)
		:
	);
	if (section == 0)
	{
	    for (i=0;i<THREAD_POOL_SIZE; i++) 
    	{
    		sync_barrier_register[i] = 0;
    	}
	}
}
