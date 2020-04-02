#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

#include "dsp_functions.h"
#include "functions.h"
#include "klessydra_defs.h"

int barrier_completed[THREAD_POOL_SIZE]; 
int arrived_at_barrier[THREAD_POOL_SIZE];
int sync_barrier_register[THREAD_POOL_SIZE];
int key;  // key to be used for atomic operations
int *ptr_key;
int barrier_thread_registration_count;
int arrived_at_barrier_count;  // Counter for the threads that arrived at the barrier

int th_id;
int cnt;

int main(){
	
	__asm__("csrw 0x300, 0x8;" );// each thread enables it's own interrupt
	th_id =	0; 
	cnt = 30;
	// sync_barrier_reset(); sync_barrier_thread_registration();	
	// sync_barrier

	
	for (int i = 0 ; i < 2 ; i++ ) {
		sync_barrier_reset();
		sync_barrier_thread_registration();
		sync_barrier();
	}
	return 0;

}
