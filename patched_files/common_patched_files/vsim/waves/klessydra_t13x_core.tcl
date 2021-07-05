add wave -group "Core" -radix hexadecimal sim:/tb/top_i/core_region_i/CORE/RISCV_CORE/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/FETCH/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/DECODE/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/LSU/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/EXECUTE/*
add wave -group "Core" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/*
add wave -group "Core" -radix hexadecimal sim:/tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/ACCL_generate/DSP/*
add wave -group "DSP" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/ACCL_generate/DSP/*
add wave -group "LSU" -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/LSU/*
add wave -group "SC"  -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/ACCL_generate/SCI/*
#add wave -group "SC"  -radix hexadecimal sim:tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/SCI/SC/*

add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/clk_i
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/LSU/nextstate_LS
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/LSU/state_LS
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_req_o
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_gnt_i
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_rvalid_i
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_we_o
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_be_o
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_addr_o
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_wdata_o
add wave -group MEM -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/data_rdata_i

add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MCYCLE
add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MINSTRET
add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MHPMCOUNTER3
add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MHPMCOUNTER6
add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MHPMCOUNTER7
add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MHPMCOUNTER8
add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MHPMCOUNTER9
add wave -group Perf_Cnt -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MHPMCOUNTER10

add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MTVEC
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/PCER
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MSTATUS
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MESTATUS
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MCAUSE
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MEPC
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MIP
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MIRQ
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MHARTID
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MVTYPE
add wave -group CSR -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/MVSIZE

add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/decoded_instruction_LS
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/decoded_instruction_DSP
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/decoded_instruction_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/irq_pending
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/set_branch_condition
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/set_except_condition
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/set_mret_condition
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/set_wfi_condition
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/clk_i
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/rst_ni
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/pc
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/instr_addr_o
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/instr_gnt_i
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/instr_rvalid_i
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/CSR/harc_to_csr
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/regfile
#add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/regfile_bram
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/harc_IF
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/harc_ID
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/harc_EXEC
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/harc_WB
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/WB_EN
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/pc_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/RS1_Addr_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/RS2_Addr_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/RD_Addr_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/DECODE/instr_word_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/RS1_Data_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/RS2_Data_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/RD_Data_IE
add wave -group Debug -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RF/WB_RD

#add wave -group Imm -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/S_Imm_IE
#add wave -group Imm -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/I_Imm_IE
#add wave -group Imm -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/SB_Imm_IE
#add wave -group Imm -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/CSR_ADDR_IE

add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/clk_i
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/taken_branch_pc_lat
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/PC_offset
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/relative_to_PC
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/incremented_pc
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/mepc_incremented_pc
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/mepc_interrupt_pc
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/pc
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/served_except_condition
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/served_mret_condition
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/served_irq
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/pc_IF
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/FETCH/pc_ID
add wave -group PC -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/pc_IE

add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Prg_Ctr/clk_i
add wave -group RAW_Check -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RAW
add wave -group RAW_Check -radix decimal     tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/RAW_wire
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/EXEC_instr_lat
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/harc_EXEC_lat
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/buf_wr_ptr_lat
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/buf_wr_ptr
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rs1_chk_en
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rs2_chk_en
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rd_read_only_chk_en
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/IE_instr
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/LSU_instr
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/DSP_instr
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/EXEC_instr
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rs1_valid
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rs2_valid
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rd_read_only_valid
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rd_valid
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rs1_valid_buf
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rs2_valid_buf
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rd_read_only_valid_buf
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/rd_valid_buf
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/Instr_word_buf
add wave -group RAW_Check -radix hexadecimal tb/top_i/core_region_i/CORE/RISCV_CORE/Pipe/pc_buf



WaveRestoreCursors {0 ns}
WaveRestoreZoom    {0 ns} {200 ns}
configure wave -namecolwidth  200
configure wave -valuecolwidth 200
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -gridperiod {10 ns}
configure wave -timelineunits ns
