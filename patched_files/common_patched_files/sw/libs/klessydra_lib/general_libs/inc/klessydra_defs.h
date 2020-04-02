#include "riscv_test.h"
#include "test_macros.h"
#include "encoding.h"
#undef  RVTEST_RV64U
#define RVTEST_RV64U RVTEST_RV32M

#define ILLEGAL_INSN_EXCEPT_CODE		  0x00000002;
#define LOAD_ERROR_EXCEPT_CODE 			  0x00000005;
#define STORE_ERROR_EXCEPT_CODE 		  0x00000007;
#define ECALL_EXCEPT_CODE 		  		  0x0000000B;
#define EXT_INTERRUPT_CODE		  		  0x8000000B;
#define SW_INTERRUPT_CODE				  0x80000003;
#define TIMER_INTERRUPT_CODE	          0x80000007;
#define LOAD_MISALIGNED_EXCEPT_CODE       0x00000004;
#define STORE_MISALIGNED_EXCEPT_CODE      0x00000006;
#define SW_INTERRUPT_CODE_NO_WFI          0x80000003;
#define SW_INTERRUPT_CODE_WFI	          0xC0000003;
#define ILLEGAL_OPERAND_EXCEPT_CODE       0x00000100;
#define ILLEGAL_BYTE_TRANSFER_EXCEPT_CODE 0x00000101;
#define ILLEGAL_ADDRESS_EXCEPT_CODE       0x00000102;
#define SCRATCHPAD_OVERFLOW_EXCEPT_CODE   0x00000103;
#define READ_SAME_SCARTCHPAD_EXCEPT_CODE  0x00000104;
#define WRITE_ACCESS_EXCEPT_CODE          0x00000105;

#define k_mstatus 	0x300
#define k_mepc 		0x341
#define k_mcause  	0x342
#define k_pcer    	0x7A0
#define k_mestatus	0x7B8
#define k_mcpuid  	0xF00
#define k_mimpid  	0xF01
#define k_mhartid 	0xF10
#define k_mirq		0xFC0
#define k_mip		0x304
#define k_mtvec		0x305

// #define thread_stack_size 4096
// #define thread_stack_size 16384
#define thread_stack_size 65536
