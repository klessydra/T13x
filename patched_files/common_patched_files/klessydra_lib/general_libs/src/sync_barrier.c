#include"functions.h"

void sync_barrier()
{	
    int my_hart, i;
    my_hart = Klessydra_get_coreID();
    
    if(sync_barrier_register[my_hart] == 1)
    {
	    barrier_completed[my_hart] = 1;
	    arrived_at_barrier[my_hart] = 1;
	    for (i=0;i<THREAD_POOL_SIZE; i++)
		{if (arrived_at_barrier[i] == 0 && sync_barrier_register[i] == 1) barrier_completed[my_hart] = 0;}
	    if (barrier_completed[my_hart] == 0)
	    {
		__asm__(
			"WFI;"
			://no output register
			://no input register
			://no clobbered register*/
		);
	    }
	    else 
	    {
		for (i=0;i<THREAD_POOL_SIZE; i++)
		    if (my_hart != i  &&  sync_barrier_register[i] == 1) send_sw_irq(i);
	    }
    }
}
