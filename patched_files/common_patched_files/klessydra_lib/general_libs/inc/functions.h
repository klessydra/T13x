#include "klessydra_defs.h"

#define MHARTID_IDCORE_MASK 15
#define THREAD_POOL_SIZE 4

int barrier_completed[THREAD_POOL_SIZE]; 
int arrived_at_barrier[THREAD_POOL_SIZE];
int sync_barrier_register[THREAD_POOL_SIZE]; 

#ifndef __KLESSYDRACFUNCTIONS_H__
#define __KLESSYDRACFUNCTIONS_H__

int Klessydra_get_mhartid();

int Klessydra_get_coreID();

void klessydra_lock_acquire(int *lock);

void klessydra_lock_release(int *lock);

void load_mem(int data_send, int store_addr);

int send_sw_irq(int targethart);

void sync_barrier_reset();

void sync_barrier_thread_registration();

void sync_barrier();

void Klessydra_WFI();	// Wait-for-interrupt function

void Klessydra_En_Int();

#endif
