#ifndef _KLESSYDRA_H_
#define _KLESSYDRA_H_

#define ILLEGAL_INSN_EXCEPT_CODE	 0x00000002;
#define LOAD_ERROR_EXCEPT_CODE 		 0x00000005;
#define STORE_ERROR_EXCEPT_CODE 	 0x00000007;
#define ECALL_EXCEPT_CODE 		 0x0000000B;
#define EXT_INTERRUPT_CODE		 0x8000000B;
#define SW_INTERRUPT_CODE	         0x80000003;
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

 
#ifndef PULPINO_H
#define PULPINO_H

#define PULPINO_BASE_ADDR             0x10000000

#define SOC_PERIPHERALS_BASE_ADDR     ( PULPINO_BASE_ADDR + 0xA100000 )

#define UART_BASE_ADDR                ( SOC_PERIPHERALS_BASE_ADDR + 0x0000 )
#define GPIO_BASE_ADDR                ( SOC_PERIPHERALS_BASE_ADDR + 0x1000 )
#define SPI_BASE_ADDR                 ( SOC_PERIPHERALS_BASE_ADDR + 0x2000 )
#define TIMER_BASE_ADDR               ( SOC_PERIPHERALS_BASE_ADDR + 0x3000 )
#define EVENT_UNIT_BASE_ADDR          ( SOC_PERIPHERALS_BASE_ADDR + 0x4000 )
#define I2C_BASE_ADDR                 ( SOC_PERIPHERALS_BASE_ADDR + 0x5000 )
#define FLL_BASE_ADDR                 ( SOC_PERIPHERALS_BASE_ADDR + 0x6000 )
#define SOC_CTRL_BASE_ADDR            ( SOC_PERIPHERALS_BASE_ADDR + 0x7000 )

#define STDOUT_BASE_ADDR              ( SOC_PERIPHERALS_BASE_ADDR + 0x10000 )
#define FPUTCHAR_BASE_ADDR            ( STDOUT_BASE_ADDR + 0x1000 )
#define FILE_CMD_BASE_ADDR            ( STDOUT_BASE_ADDR + 0x2000 )
#define STREAM_BASE_ADDR              ( STDOUT_BASE_ADDR + 0x3000 )

#define INSTR_RAM_BASE_ADDR           ( 0x00       )
#define INSTR_RAM_START_ADDR          ( 0x80       )

#define ROM_BASE_ADDR                 ( 0x8000     )

#define DATA_RAM_BASE_ADDR            ( 0x00100000 )

#define REGP(x) ((volatile unsigned int*)(x))
#define REG(x) (*((volatile unsigned int*)(x)))
#define REGP_8(x) (((volatile uint8_t*)(x)))

#define __PSC__(a) *(unsigned volatile int*) (SOC_CTRL_BASE_ADDR + a)

#define CGREG __PSC__(0x04)

#define CGSPI     0x00
#define CGUART    0x01
#define CGGPIO    0x02
#define CGGSPIM   0x03
#define CGTIM     0x04
#define CGEVENT   0x05
#define CGGI2C    0x06
#define CGFLL     0x07

#define BOOTREG     __PSC__(0x08)

#define RES_STATUS  __PSC__(0x14)

#endif
