#include"functions.h"

int send_sw_irq(int targethart)
{	
	int mip_data_send = 8;
	int store_addr = 0xff00;
	
	if(targethart >= THREAD_POOL_SIZE) return 0; 		// the thread to which you sent the interrupt request doesn't exist
	else
	{
		store_addr = store_addr + (4*targethart); 	// MIP address generation
		load_mem(mip_data_send, store_addr);		// rise bit numb 3 in MIP reg to require sw interrupt
		return 1;
	}
}
