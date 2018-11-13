#include "klessydra_defs.h"

#define MHARTID_IDCORE_MASK 15
#define THREAD_POOL_SIZE 4

#define SPMADDR1 0x00109000
#define SPMADDR2 0x00109200
#define SPMADDR3 0x00109400
#define SPMADDR4 0x00109600

int barrier_completed[THREAD_POOL_SIZE];
int arrived_at_barrier[THREAD_POOL_SIZE];
int sync_barrier_register[THREAD_POOL_SIZE]; 

int vSCP_copyin_src1 = 0;
int* pSCP_copyin_src1 = &vSCP_copyin_src1;

int vSCP_copyin_src2 = 0;
int* pSCP_copyin_src2 = &vSCP_copyin_src2;

const int spmaddrA = SPMADDR1;
const int spmaddrB = SPMADDR2;
const int spmaddrC = SPMADDR3;

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
// ################################## DSP #######################################

#define Klessydra_spmcpy_in(spm_vect_addr, ram_vect_addr, size) __asm__( \
		"kmemld %0, %1, %2;" \
		: \
		:"r" (spm_vect_addr), "r" (ram_vect_addr), "r" (size) \
		: \
	);

#define Klessydra_spmcpy_out(ram_vect_addr, spm_vect_addr, size) __asm__( \
		"kmemstr %0, %1, %2;" \
		: \
		:"r" (ram_vect_addr), "r" (spm_vect_addr), "r" (size) \
		: \
	);

#define Klessydra_setvsize(rs1); __asm__( \
		"csrw 0xFF0, %0;" \
		: \
		:"r" (rs1) \
		: \
	);

#define Klessydra_vadd(spm_vect1_addr, spm_vect2_addr, spm_res_addr) \
	__asm__( \
		"kaddv %0, %1, %2;" \
		: \
		:"r" (spm_res_addr), "r" (spm_vect1_addr), "r" (spm_vect2_addr) \
		: \
	);

#define Klessydra_Single_Function_KADDV(dest, src1, src2, size) \
	int key = 1;\
        static int section1 = 0; \
        int* psection1 = &section1; \
	asm volatile( \
		"amoswap.w.aq %[key], %[key], (%[psection1]);" \
		"bnez %0, SCP_copyin_vect2;" \
		"SCP_copyin_vect1:" \
		"	kmemld %[spmaddrA], %[srcA], %[sz];" \
		"       csrs 0x300, 0x8;" \
		"	wfi;"\
		"SCP_copyin_vect2:" \
                "       sw zero, 0(%[psection1]);" \
		"	amoswap.w.aq %[key], %[key], (%[psection1]);" \
		"	bnez %[key], Halt_Thread2;" \
		"	kmemld %[spmaddrB], %[srcB], %[sz];" \
                "       j SCP_vadd;" \
		"Halt_Thread2:" \
		"       csrs 0x300, 0x8;" \
		"	wfi;" \
                "SCP_vadd:" \
		"	csrw 0xFF0, %[sz]; " \
		"	kaddv %[spmaddrC], %[spmaddrA], %[spmaddrB];" \
		"	kmemstr %[dst], %[spmaddrC], %[sz];" \
		: \
		:[key] "r" (key),[psection1] "r" (psection1), \
		 [spmaddrA] "r" (spmaddrA), [srcA] "r" (src1), [sz] "r" (size), \
		 [spmaddrB] "r" (spmaddrB), [srcB] "r" (src2), \
                 [spmaddrC] "r" (spmaddrC), [dst] "r" (dest) \
		: \
	);

#define Klessydra_Single_Function_KDOTP(dest, src1, src2, size) \
	int key = 1; \
	asm volatile( \
		"amoswap.w.aq %[key], %[key], (%[pSCP_copyin_src1]);" \
		"bnez %[key], SCP_copyin_src2;" \
		"SCP_copyin_src1:" \
		"	kmemld %[spmaddrA], %[srcA], %[sz];" \
                "       csrs 0x300, 0x8;" \
                "       wfi;" \
		"	amoswap.w.rl x0, x0, (%[pSCP_copyin_src1]);" \
		"SCP_copyin_src2:" \
		"	amoswap.w.aq %[key], %[key], (%[pSCP_copyin_src2]);" \
		"	bnez %[key], End_Of_Function;" \
		"	kmemld %[spmaddrB], %[srcB], %[sz];" \
		"	csrw 0xFF0, %[sz]; " \
		"SCP_vadd:" \
                "	kdotp %[spmaddrC], %[spmaddrA], %[spmaddrB];" \
		"	kmemstr %[dst], %[spmaddrC], %[sz];" \
		"	amoswap.w.rl x0, x0, (%[pSCP_copyin_src1]);" \
                "Halt_Thread_2:" \
                "       csrs 0x300, 0x8;" \
                "       wfi;" \
                "End_Of_Function:" \
                "       nop;" \
		: \
		:[key] "r" (key), [pSCP_copyin_src1] "r" (pSCP_copyin_src1), \
		 [spmaddrA] "r" (spmaddrA), [srcA] "r" (src1), \
		 [pSCP_copyin_src2] "r" (pSCP_copyin_src2), \
		 [spmaddrB] "r" (spmaddrB), [srcB] "r" (src2), \
		 [spmaddrC] "r" (spmaddrC), [dst] "r" (dest), \
		 [sz] "r" (size) \
		: \
	);

// ###############################################################################

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
