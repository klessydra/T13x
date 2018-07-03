#include"functions.h"

void sync_barrier_thread_registration()
{
   int my_hart;
   my_hart = Klessydra_get_coreID();
   arrived_at_barrier[my_hart] =  0;	
   sync_barrier_register[my_hart] = 1;
}
