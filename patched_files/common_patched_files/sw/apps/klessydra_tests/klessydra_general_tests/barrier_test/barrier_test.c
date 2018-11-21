#include"functions.h"

int main()
{
	int x = 0;	
	
	sync_barrier_reset();
	
	if(Klessydra_get_coreID() == 1 || Klessydra_get_coreID() == 0) sync_barrier_thread_registration();
	
	if(Klessydra_get_coreID() == 1)
	{
		x = x+1;
	}
	
	sync_barrier();
	
	x = 0;

	return 0;
}
