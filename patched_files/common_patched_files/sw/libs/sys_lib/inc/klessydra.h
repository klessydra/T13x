#ifndef _KLESSYDRA_H_
#define _KLESSYDRA_H_

#define ILLEGAL_INSN_EXCEPT_CODE	 0x00000002;
#define LOAD_ERROR_EXCEPT_CODE 		 0x00000005;
#define STORE_ERROR_EXCEPT_CODE 	 0x00000007;
#define ECALL_EXCEPT_CODE 		 0x0000000B;
#define EXT_INTERRUPT_CODE		 0x8000000B;
#define SW_INTERRUPT_CODE_NO_WFI         0x80000003;
#define SW_INTERRUPT_CODE_WFI	         0xC0000003;
#define TIMER_INTERRUPT_CODE	         0x80000007;
#define LOAD_MISALIGNED_EXCEPT_CODE  	 0x00000004;
#define STORE_MISALIGNED_EXCEPT_CODE 	 0x00000006;

#define k_mstatus 	0b001100000000
#define k_mepc 		0b001101000001 
#define k_mcause  	0b001101000010
#define k_pcer    	0b011110100000
#define k_mestatus	0b011110111000
#define k_mcpuid  	0b111100000000
#define k_mimpid  	0b111100000001
#define k_mhartid 	0xF10
#define k_mirq		0xFC0
#define k_mip		0x344 
#define k_mtvec		0x305 


#define thread_stack_size 4096

#endif
