#include "klessydra_defs.h"
#define EXCEPTION_STACK_SIZE 96
#define KLESSYDRA_EXC_STACK_SIZE 12

  .section .text

reset_handler:

  li t4, 0x94
  csrrw x0, mtvec, t4
  mv  x1, x0
  mv  x2, x1
  mv  x3, x1
  mv  x4, x1
  mv  x5, x1
  mv  x6, x1
  mv  x7, x1
  mv  x8, x1
  mv  x9, x1
  mv x10, x1
  mv x11, x1
  mv x12, x1
  mv x13, x1
  mv x14, x1
  mv x15, x1
  mv x16, x1
  mv x17, x1
  mv x18, x1
  mv x19, x1
  mv x20, x1
  mv x21, x1
  mv x22, x1
  mv x23, x1
  mv x24, x1
  mv x25, x1
  mv x26, x1
  mv x27, x1
  mv x28, x1
  mv x29, x1
  mv x30, x1
  mv x31, x1

reset:
	li ra,0x020000; 			#initialize return address
	csrr tp, k_mhartid;			#load mhartID value's in thread pointer tp 
	andi tp,tp,0x07;			#estraggo il valore del core nel cluster (contenuto nei 4 bit meno significativi)
	li t3,0;					#counter and coreID
	li t4,0x0F000000;			#load in t4 gp value
	li t5,16;					#max coreID number
	li t6,-thread_stack_size;	#stack size for each thread

init_sp_loop:
	bne tp,t3,not_assigned_sp;	#compare coreID with counter if they are not equal take the branch
	mv sp,t4;			#else initialize stack pointer
	
	not_assigned_sp:
		addi t3,t3,1;		#increment counter
		add t4,t4,t6;		#decrement stack pointer initializator of the value content in t6 
		bne t3,t5,init_sp_loop;	#if t3 isn't equal to 16 loop again else call main

end_sp_loop:
	mv gp,t4;			#initialize global pointer
	
_start:
  .global _start

  la x26, _bss_start
  la x27, _bss_end

  bge x26, x27, zero_loop_end

zero_loop:
  sw x0, 0(x26)
  addi x26, x26, 4
  ble x26, x27, zero_loop
zero_loop_end:
				
  call    __libc_init_array			

main_entry:
  addi   x10, x0, 0
  addi   x11, x0, 0x1
  jal  uart_set_cfg; 				

  addi x10, x0, 0
  addi x11, x0, 0
  jal x1, main
  mv s0, a0
  jal  uart_wait_tx_done;
  mv a0, s0
  jal  x1, exit


mtvec_routine:					
	addi	sp,sp,-KLESSYDRA_EXC_STACK_SIZE;
	sw	t4,0x00(sp);
	sw	t5,0x04(sp);
	sw	t6,0x08(sp);
	csrrs t5, k_mcause, x0;
	csrr t4, k_mirq;
	li t6, EXT_INTERRUPT_CODE;
	bne t5, t6, no_ext_interrupt;
	lw t5, 0x04(sp);
	lw t6, 0x08(sp);
	jr t4;

	no_ext_interrupt:
	li t6, SW_INTERRUPT_CODE_WFI;   //In klessydra, if we have a WFI, we write a "1" to the bit mcause(30), hence there are no sw_interrupt codes       		                      
	beq t5, t6, sofware_insn_handler;
	li t6, SW_INTERRUPT_CODE_NO_WFI;
	beq t5, t6, sofware_insn_handler;
	li t6, TIMER_INTERRUPT_CODE;          		                      
	bne t5, t6, exception_trap;
	lw t5, 0x04(sp);
	lw t6, 0x08(sp);
	jr t4;

	exception_trap:
	li t6, ECALL_EXCEPT_CODE;
	beq t5, t6, ecall_insn_handler;  	
	li t6, ILLEGAL_INSN_EXCEPT_CODE;                                  
	beq t5, t6, illegal_insn_handler;  	                                     
	li t6, LOAD_ERROR_EXCEPT_CODE;  		                                      
	beq t5, t6, invalid_addr_handler; 
	li t6, STORE_ERROR_EXCEPT_CODE;   		                                     
	beq t5, t6, invalid_addr_handler;
	li t6,LOAD_MISALIGNED_EXCEPT_CODE;		   
	beq t5, t6, invalid_addr_handler;
	li t6,STORE_MISALIGNED_EXCEPT_CODE;		   
	beq t5, t6, invalid_addr_handler;	
	    	
	lw t4,0x00(sp);
	lw t5, 0x04(sp);			
	lw t6, 0x08(sp);
	addi	sp,sp, KLESSYDRA_EXC_STACK_SIZE;
	mret;

ISR_I2C_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;	
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_I2C

ISR_UART_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_UART

ISR_GPIO_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_GPIO

ISR_SPIM0_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_SPIM0

ISR_SPIM1_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_SPIM1

ISR_TA_CMP_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TA_CMP

ISR_TA_OVF_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TA_OVF

ISR_TB_CMP_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TB_CMP

ISR_TB_OVF_ASM:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TB_OVF

illegal_insn_handler:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, illegal_insn_handler_c

ecall_insn_handler:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ecall_insn_handler_c

sofware_insn_handler:
invalid_addr_handler:
  lw	t4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  mret;

store_regs:
  sw  x3, 0x00(x2)
  sw  x4, 0x04(x2)
  sw  x5, 0x08(x2)
  sw  x6, 0x0c(x2)
  sw  x7, 0x10(x2)
  sw x10, 0x14(x2)
  sw x11, 0x18(x2)
  sw x12, 0x1c(x2)
  sw x13, 0x20(x2)
  sw x14, 0x24(x2)
  sw x15, 0x28(x2)
  sw x16, 0x2c(x2)
  sw x17, 0x30(x2)
  sw x28, 0x34(x2)
  sw x29, 0x38(x2)
  sw x30, 0x3c(x2)
  sw x31, 0x40(x2)
  csrr x28, 0x7B0
  csrr x29, 0x7B1
  csrr x30, 0x7B2
  sw x28, 0x44(x2)
  sw x29, 0x48(x2)
  sw x30, 0x4C(x2)
  csrr x28, 0x7B4
  csrr x29, 0x7B5
  csrr x30, 0x7B6
  sw x28, 0x50(x2)
  sw x29, 0x54(x2)
  sw x30, 0x58(x2)
  jalr x0, x1

end_except:
  lw x28, 0x50(x2)
  lw x29, 0x54(x2)
  lw x30, 0x58(x2)
  csrrw x0, 0x7B4, x28
  csrrw x0, 0x7B5, x29
  csrrw x0, 0x7B6, x30
  lw x28, 0x44(x2)
  lw x29, 0x48(x2)
  lw x30, 0x4C(x2)
  csrrw x0, 0x7B0, x28
  csrrw x0, 0x7B1, x29
  csrrw x0, 0x7B2, x30
  lw  x3, 0x00(x2)
  lw  x4, 0x04(x2)
  lw  x5, 0x08(x2)
  lw  x6, 0x0c(x2)
  lw  x7, 0x10(x2)
  lw x10, 0x14(x2)
  lw x11, 0x18(x2)
  lw x12, 0x1c(x2)
  lw x13, 0x20(x2)
  lw x14, 0x24(x2)
  lw x15, 0x28(x2)
  lw x16, 0x2c(x2)
  lw x17, 0x30(x2)
  lw x28, 0x34(x2)
  lw x29, 0x38(x2)
  lw x30, 0x3c(x2)
  lw x31, 0x40(x2)
  lw  x1, 0x5C(x2)
  addi x2, x2, EXCEPTION_STACK_SIZE
  mret

  .global _init
  .global _fini
_init:
_fini:
  ret


  .section .vectors, "ax"
  .option norvc;

  
  .org 0x00
  .rept 23
  nop
  .endr

  jal x0, ISR_I2C_ASM
  jal x0, ISR_UART_ASM			
  jal x0, ISR_GPIO_ASM
  jal x0, ISR_SPIM0_ASM
  jal x0, ISR_SPIM1_ASM
  jal x0, ISR_TA_OVF_ASM
  jal x0, ISR_TA_CMP_ASM
  jal x0, ISR_TB_OVF_ASM
  jal x0, ISR_TB_CMP_ASM

	
  .org 0x80
  jal x0, reset_handler

  .org 0x84
  jal x0, illegal_insn_handler

  .org 0x88
  jal x0, ecall_insn_handler
  
  .org 0x94
  jal x0, mtvec_routine	

