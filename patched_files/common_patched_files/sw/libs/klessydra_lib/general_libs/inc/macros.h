#include "klessydra_defs.h"

#define MHARTID_IDCORE_MASK 15
#define THREAD_POOL_SIZE 4

int barrier_completed[THREAD_POOL_SIZE];
int arrived_at_barrier[THREAD_POOL_SIZE];
int sync_barrier_register[THREAD_POOL_SIZE]; 

int vSCP_copyin_src1 = 0;
int* pSCP_copyin_src1 = &vSCP_copyin_src1;

int vSCP_copyin_src2 = 0;
int* pSCP_copyin_src2 = &vSCP_copyin_src2;


#ifndef __KLESSYDRACFUNCTIONS_H__
#define __KLESSYDRACFUNCTIONS_H__

#define klessydra_lock_acquire(lock) \
	int temp0 = 1;	\
	__asm__( \
		"loop: " \
		"amoswap.w.aq %1, %1, (%0);" \
		"bnez %1,loop;" \
		: \
		:"r" (lock), "r" (temp0) \
		: \
	);

#define klessydra_lock_release(lock) \
	__asm__( \
		"amoswap.w.rl x0, x0, (%0);" \
		: \
		:"r" (lock) \
		: \
	);

#define MKlessydra_WFI() __asm__(\
		"csrw 0x300, 0x8;"\
		"WFI;"\
	);

#define MKlessydra_get_coreID() \
        unsigned int hartID = 0; \
	unsigned int mhartid_value; \
        __asm__(\
		"CSRR %[mhartid_value], 0xf10;" \
		:[mhartid_value] "=r" (mhartid_value), [hartID] "=r" (hartID) \
                : \
                : \
	); \
        hartID = mhartid_value & MHARTID_IDCORE_MASK;


#define MKlessydra_get_mhartid() \
	int mhartid_value; \
	__asm__( \
		"CSRR %0, 0xF10;" \
		:"=r"(mhartid_value) \
	); \
	return mhartid_value; \


#define Mload_mem(data_send, store_addr) \
	__asm__( \
		"sw %0, (%1);" \
		: \
		:"r"(data_send), "r"(store_addr) \
		: \
	); \

#define Msend_sw_irq(targethart) \
	int mip_data_send = 8; \
	int store_addr = 0xff00; \
	if(targethart >= THREAD_POOL_SIZE) return 0; \
	else \
	{ \
		store_addr = store_addr + (4*targethart); \
		load_mem(mip_data_send, store_addr); \
		return 1; \
	}

#define Msync_barrier_reset() \
    int i; \
    for (i=0;i<THREAD_POOL_SIZE; i++) {sync_barrier_register[i] = 0;}

#define Msync_barrier_thread_registration() \
   int my_hart; \
   my_hart = Klessydra_get_coreID(); \
   arrived_at_barrier[my_hart] =  0; \
   sync_barrier_register[my_hart] = 1;

#define Msync_barrier() \
    int my_hart, i; \
    my_hart = Klessydra_get_coreID(); \
    if(sync_barrier_register[my_hart] == 1) \
    { \
	    barrier_completed[my_hart] = 1; \
	    arrived_at_barrier[my_hart] = 1; \
	    for (i=0;i<THREAD_POOL_SIZE; i++) \
		{if (arrived_at_barrier[i] == 0 && sync_barrier_register[i] == 1) barrier_completed[my_hart] = 0;} \
	    if (barrier_completed[my_hart] == 0) \
	    { \
		__asm__( \
			"WFI;" \
		); \
	    } \
	    else \
	    { \
		for (i=0;i<THREAD_POOL_SIZE; i++) \
		    if (my_hart != i  &&  sync_barrier_register[i] == 1) send_sw_irq(i); \
	    } \
    }

#define MKlessydra_En_Int(); \
{ \
	__asm__("csrs 0x300, 0x8;"); \
}

#endif
