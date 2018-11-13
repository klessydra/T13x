#include"functions.h"

void sync_barrier_reset()
{
    int i;
    for (i=0;i<THREAD_POOL_SIZE; i++) {sync_barrier_register[i] = 0;} 
}
