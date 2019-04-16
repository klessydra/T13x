// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

#include "klessydra.h"
#define EXCEPTION_STACK_SIZE 96
#define KLESSYDRA_EXC_STACK_SIZE 12



/* ========================================================= [ entry ] === */
  .section .text

reset_handler:

  /* set 0 in mtvec (base for IVT) */
  li a4, 0x94
  csrrw x0, mtvec, a4
  /* set all registers to zero */
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

reset:
	li ra,0x020000; 			#initialize return address
	csrr tp, k_mhartid;			#load mhartID value's in thread pointer tp 
	andi tp,tp,0x07;			#estraggo il valore del core nel cluster (contenuto nei 4 bit meno significativi)
	li s0,0;					#counter and coreID
	li a1,0x0F000000;			#load in t1 gp value
	li a2,16;					#max coreID number
	li a3,-thread_stack_size;	#stack size for each thread

init_sp_loop:
	bne tp,s0,not_assigned_sp;	#compare coreID with counter if they are not equal take the branch
	mv sp,a1;			#else initialize stack pointer
	
	not_assigned_sp:
		addi s0,s0,1;		#increment counter
		add a1,a1,a3;		#decrement stack pointer initializator of the value content in a3
		bne s0,a2,init_sp_loop;	#if s0 isn't equal to 16 loop again else call main

end_sp_loop:
	mv gp,a1;			#initialize global pointer

_start:
  .global _start

  /* clear BSS */
  la x14, _bss_start
  la x15, _bss_end

  bge x14, x15, zero_loop_end

zero_loop:
  sw x0, 0(x14)
  addi x14, x14, 4
  ble x14, x15, zero_loop
zero_loop_end:

  /* Run global initialization functions */
  call    __libc_init_array

main_entry:
  addi   x10, x0, 0
  addi   x11, x0, 0x1
  jal  uart_set_cfg;

  /* jump to main program entry point (argc = argv = 0) */
  addi x10, x0, 0
  addi x11, x0, 0
  jal x1, main
  mv s0, a0
  jal  uart_wait_tx_done;
  mv a0, s0
  /* if program exits call exit routine from library */
  jal  x1, exit

mtvec_routine:					
	addi	sp,sp,-KLESSYDRA_EXC_STACK_SIZE;
	sw	a4,0x00(sp);
	sw	a5,0x04(sp);
	sw	a2,0x08(sp);
	csrrs a5, k_mcause, x0;
	csrr a4, k_mirq;
	li a2, EXT_INTERRUPT_CODE;
	bne a5, a2, no_ext_interrupt;
	lw a5, 0x04(sp);
	lw a2, 0x08(sp);
	jr a4;

	no_ext_interrupt:
	li a2, SW_INTERRUPT_CODE_WFI;   //In klessydra, if we have a WFI, we write a "1" to the bit mcause(30), hence there are no sw_interrupt codes       		                      
	beq a5, a2, sofware_insn_handler;
	li a2, SW_INTERRUPT_CODE_NO_WFI;
	beq a5, a2, sofware_insn_handler;
	li a2, TIMER_INTERRUPT_CODE;          		                      
	bne a5, a2, exception_trap;
	lw a5, 0x04(sp);
	lw a2, 0x08(sp);
	jr a4;

	exception_trap:
	li a2, ECALL_EXCEPT_CODE;
	beq a5, a2, ecall_insn_handler;  	
	li a2, ILLEGAL_INSN_EXCEPT_CODE;                                  
	beq a5, a2, illegal_insn_handler;  	                                     
	li a2, LOAD_ERROR_EXCEPT_CODE;  		                                      
	beq a5, a2, invalid_addr_handler; 
	li a2, STORE_ERROR_EXCEPT_CODE;   		                                     
	beq a5, a2, invalid_addr_handler;
	li a2,LOAD_MISALIGNED_EXCEPT_CODE;		   
	beq a5, a2, invalid_addr_handler;
	li a2,STORE_MISALIGNED_EXCEPT_CODE;		   
	beq a5, a2, invalid_addr_handler;	
	    	
	lw a4,0x00(sp);
	lw a5, 0x04(sp);			
	lw a2, 0x08(sp);
	addi	sp,sp, KLESSYDRA_EXC_STACK_SIZE;
	mret;

/* ========================================== [ I2C handler ] === */
ISR_I2C_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_I2C

/* ========================================== [ UART handler ] === */
ISR_UART_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_UART

/* ========================================== [ GPIO handler ] === */
ISR_GPIO_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_GPIO

/* ========================================== [ SPI Master end of transmission handler ] === */
ISR_SPIM0_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_SPIM0

/* ========================================== [ SPI Master receive/transmit finish handler ] === */
ISR_SPIM1_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_SPIM1

/* ========================================== [ Timer A compare handler ] === */
ISR_TA_CMP_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TA_CMP

/* ========================================== [ Timer A overflow handler ] === */
ISR_TA_OVF_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TA_OVF

/* ========================================== [ Timer B Compare handler ] === */
ISR_TB_CMP_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TB_CMP

/* ========================================== [ Timer B overflow handler ] === */
ISR_TB_OVF_ASM:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ISR_TB_OVF

/* ================================= [ illegal instruction handler] === */
illegal_insn_handler:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, illegal_insn_handler_c

/* ================================= [ ecall instruction handler] === */
ecall_insn_handler:
  addi x2, x2, -EXCEPTION_STACK_SIZE
  sw x1, 0x5C(x2)
  jal x1, store_regs
  la x1, end_except
  jal x0, ecall_insn_handler_c

sofware_insn_handler:
invalid_addr_handler:
  lw	a4,0x00(sp);
  addi	sp,sp,KLESSYDRA_EXC_STACK_SIZE;
  mret;

// saves all caller-saved registers (except return address)
store_regs:
  sw  x3, 0x00(x2)  // gp
  sw  x4, 0x04(x2)  // tp
  sw  x5, 0x08(x2)  // t0
  sw  x6, 0x0c(x2)  // t1
  sw  x7, 0x10(x2)  // t2
  sw x10, 0x14(x2)  // a0
  sw x11, 0x18(x2)  // a1
  sw x12, 0x1c(x2)  // a2
  sw x13, 0x20(x2)  // a3
  sw x14, 0x24(x2)  // a4
  sw x15, 0x28(x2)  // a5
  jalr x0, x1

// load back registers from stack
end_except:
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
  lw  x1, 0x5C(x2)
  addi x2, x2, EXCEPTION_STACK_SIZE
  mret

  .global _init
  .global _fini
_init:
_fini:
  # These don't have to do anything since we use init_array/fini_array.
  ret

/* =================================================== [ exceptions ] === */
/* This section has to be down here, since we have to disable rvc for it  */

  .section .vectors, "ax"
  .option norvc;

  // external interrupts are handled by the same callback
  // until compiler supports IRQ routines
  .org 0x00
  .rept 23
  nop                       // unused
  .endr

  jal x0, ISR_I2C_ASM 	    // 23: i2c
  jal x0, ISR_UART_ASM 	    // 24: uart
  jal x0, ISR_GPIO_ASM 	    // 25: gpio
  jal x0, ISR_SPIM0_ASM     // 26: spim	end of transmission
  jal x0, ISR_SPIM1_ASM     // 27: spim R/T finished
  jal x0, ISR_TA_OVF_ASM    // 28: timer A overflow
  jal x0, ISR_TA_CMP_ASM    // 29: timer A compare
  jal x0, ISR_TB_OVF_ASM    // 30: timer B overflow
  jal x0, ISR_TB_CMP_ASM    // 31: timer B compare


  // reset vector
  .org 0x80
  jal x0, reset_handler

  // illegal instruction exception
  .org 0x84
  jal x0, illegal_insn_handler

  // ecall handler
  .org 0x88
  jal x0, ecall_insn_handler

  .org 0x94
  jal x0, mtvec_routine	
