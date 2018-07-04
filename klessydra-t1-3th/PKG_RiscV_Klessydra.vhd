library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.thread_parameters_klessydra.all;

package riscv_klessydra is

  
  file file_handler : text open write_mode is "execution_trace.txt";

  
  type regfile_behavioral_array is array (31 downto 0) of std_logic_vector(31 downto 0);

  
  type array_2d is array (integer range<>) of std_logic_vector;
  type array_3d is array(integer range<>) of array_2d;
  type sc_repl_128b_reg is array(2 downto 0) of std_logic_vector(127 downto 0);
  type sc_repl_10b_reg  is array(2 downto 0) of std_logic_vector(9 downto 0);
  type sc_repl_16b_reg  is array(2 downto 0) of std_logic_vector(15 downto 0);
  type sc_repl_bit      is array(2 downto 0) of std_logic;
						 
  constant Num_SCs    : integer := 4;
  constant Addr_Width : integer := 9;
  constant Data_Width : integer := 128;
						 
  
  type replicated_32b_reg is array (harc_range) of std_logic_vector(31 downto 0);
  type replicated_bit is array (harc_range) of std_logic;
  type replicated_positive_integer is array (harc_range) of natural;

  
  type regfile_replicated_array is array (harc_range) of regfile_behavioral_array;

  constant EXEC_UNIT_INSTR_SET_SIZE : natural := 44;  
  constant LS_UNIT_INSTR_SET_SIZE   : natural := 11;  
  constant DSP_UNIT_INSTR_SET_SIZE  : natural := 2;   

  
  constant ADDI_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000000000001";
  constant SLTI_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000000000010";
  constant SLTIU_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000000000100";
  constant ANDI_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000000001000";
  constant ORI_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000000010000";
  constant XORI_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000000100000";
  constant SLLI_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000001000000";
  constant SRLI7_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000010000000";
  constant SRAI7_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000000100000000";
  constant LUI_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000001000000000";
  constant AUIPC_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000010000000000";
  constant ADD7_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000000100000000000";
  constant SUB7_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000001000000000000";
  constant SLT_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000010000000000000";
  constant SLTU_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000000100000000000000";
  constant ANDD_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000001000000000000000";
  constant ORR_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000010000000000000000";
  constant XORR_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000000100000000000000000";
  constant SLLL_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000001000000000000000000";
  constant SRLL7_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000010000000000000000000";
  constant SRAA7_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000000100000000000000000000";
  constant JAL_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000001000000000000000000000";
  constant JALR_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000010000000000000000000000";
  constant BEQ_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000000100000000000000000000000";
  constant BNE_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000001000000000000000000000000";
  constant BLT_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000010000000000000000000000000";
  constant BLTU_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000000100000000000000000000000000";
  constant BGE_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000001000000000000000000000000000";
  constant BGEU_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000010000000000000000000000000000";
  constant FENCE_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000000100000000000000000000000000000";
  constant FENCEI_pattern  : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000001000000000000000000000000000000";
  constant ECALL_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000010000000000000000000000000000000";
  constant EBREAK_pattern  : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000000100000000000000000000000000000000";
  constant MRET_pattern    : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000001000000000000000000000000000000000";
  constant WFI_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000010000000000000000000000000000000000";
  constant CSRRW_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000100000000000000000000000000000000000";
  constant CSRRS_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000001000000000000000000000000000000000000";
  constant CSRRC_pattern   : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000010000000000000000000000000000000000000";
  constant CSRRWI_pattern  : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000100000000000000000000000000000000000000";
  constant CSRRSI_pattern  : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00001000000000000000000000000000000000000000";
  constant CSRRCI_pattern  : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00010000000000000000000000000000000000000000";
  constant SW_MIP_pattern  : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "00100000000000000000000000000000000000000000";
  constant ILL_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "01000000000000000000000000000000000000000000";
  constant NOP_pattern     : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0) := "10000000000000000000000000000000000000000000";
  

  
  constant LW_pattern      : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000001";
  constant LH_pattern      : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000010";
  constant LHU_pattern     : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000000100";
  constant LB_pattern      : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000001000";
  constant LBU_pattern     : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000010000";
  constant SW_pattern      : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00000100000";
  constant SH_pattern      : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00001000000";
  constant SB_pattern      : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00010000000";
  constant AMOSWAP_pattern : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "00100000000";
  constant KMEMLD_pattern  : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "01000000000";
  constant KMEMSTR_pattern : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0) := "10000000000";
  

  
  constant KADDV_pattern   : std_logic_vector(DSP_UNIT_INSTR_SET_SIZE-1 downto 0) := "01";
  constant KDOTP_pattern   : std_logic_vector(DSP_UNIT_INSTR_SET_SIZE-1 downto 0) := "10";
  

  constant ADDI_bit_position    : natural := 0;
  constant SLTI_bit_position    : natural := 1;
  constant SLTIU_bit_position   : natural := 2;
  constant ANDI_bit_position    : natural := 3;
  constant ORI_bit_position     : natural := 4;
  constant XORI_bit_position    : natural := 5;
  constant SLLI_bit_position    : natural := 6;
  constant SRLI7_bit_position   : natural := 7;
  constant SRAI7_bit_position   : natural := 8;
  constant LUI_bit_position     : natural := 9;
  constant AUIPC_bit_position   : natural := 10;
  constant ADD7_bit_position    : natural := 11;
  constant SUB7_bit_position    : natural := 12;
  constant SLT_bit_position     : natural := 13;
  constant SLTU_bit_position    : natural := 14;
  constant ANDD_bit_position    : natural := 15;
  constant ORR_bit_position     : natural := 16;
  constant XORR_bit_position    : natural := 17;
  constant SLLL_bit_position    : natural := 18;
  constant SRLL7_bit_position   : natural := 19;
  constant SRAA7_bit_position   : natural := 20;
  constant JAL_bit_position     : natural := 21;
  constant JALR_bit_position    : natural := 22;
  constant BEQ_bit_position     : natural := 23;
  constant BNE_bit_position     : natural := 24;
  constant BLT_bit_position     : natural := 25;
  constant BLTU_bit_position    : natural := 26;
  constant BGE_bit_position     : natural := 27;
  constant BGEU_bit_position    : natural := 28;
  constant FENCE_bit_position   : natural := 29;
  constant FENCEI_bit_position  : natural := 30;
  constant ECALL_bit_position   : natural := 31;
  constant EBREAK_bit_position  : natural := 32;
  constant MRET_bit_position    : natural := 33;
  constant WFI_bit_position     : natural := 34;
  constant CSRRW_bit_position   : natural := 35;
  constant CSRRS_bit_position   : natural := 36;
  constant CSRRC_bit_position   : natural := 37;
  constant CSRRWI_bit_position  : natural := 38;
  constant CSRRSI_bit_position  : natural := 39;
  constant CSRRCI_bit_position  : natural := 40;
  constant SW_MIP_bit_position  : natural := 41;
  constant ILL_bit_position     : natural := 42;
  constant NOP_bit_position     : natural := 43;

  constant LW_bit_position      : natural := 0;
  constant LH_bit_position      : natural := 1;
  constant LHU_bit_position     : natural := 2;
  constant LB_bit_position      : natural := 3;
  constant LBU_bit_position     : natural := 4;
  constant SW_bit_position      : natural := 5;
  constant SH_bit_position      : natural := 6;
  constant SB_bit_position      : natural := 7;
  constant AMOSWAP_bit_position : natural := 8;
  constant KMEMLD_bit_position  : natural := 9;
  constant KMEMSTR_bit_position : natural := 10;


  constant KADDV_bit_position   : natural := 0;
  constant KDOTP_bit_position   : natural := 1;

  
  
  constant MSTATUS_addr : std_logic_vector (11 downto 0) := "001100000000";
  constant MEPC_addr    : std_logic_vector (11 downto 0) := "001101000001";
  constant MCAUSE_addr  : std_logic_vector (11 downto 0) := "001101000010";
  constant PCCRs_addr   : std_logic_vector (11 downto 0) := "000000000000";  
  constant PCMR_addr    : std_logic_vector (11 downto 0) := "011110100001";  
  constant MTVEC_addr   : std_logic_vector (11 downto 0) := x"305";
  constant MIP_addr     : std_logic_vector (11 downto 0) := x"344";

  
  constant PCER_addr          : std_logic_vector (11 downto 0) := "011110100000";
  
  constant MESTATUS_addr      : std_logic_vector (11 downto 0) := "011110111000";
  constant MCPUID_addr        : std_logic_vector (11 downto 0) := "111100000000";
  constant MIMPID_addr        : std_logic_vector (11 downto 0) := "111100000001";
  constant MHARTID_addr       : std_logic_vector (11 downto 0) := "111100010000";
  constant BADADDR_addr       : std_logic_vector (11 downto 0) := "001101000011";
  constant MIRQ_addr          : std_logic_vector (11 downto 0) := "111111000000";
  
  constant MCYCLE_addr        : std_logic_vector (11 downto 0) := x"B00";
  constant MINSTRET_addr      : std_logic_vector (11 downto 0) := x"B02";
  constant MHPMCOUNTER3_addr  : std_logic_vector (11 downto 0) := x"B03";
  constant MHPMCOUNTER4_addr  : std_logic_vector (11 downto 0) := x"B04";
  constant MHPMCOUNTER5_addr  : std_logic_vector (11 downto 0) := x"B05";
  constant MHPMCOUNTER6_addr  : std_logic_vector (11 downto 0) := x"B06";
  constant MHPMCOUNTER7_addr  : std_logic_vector (11 downto 0) := x"B07";
  constant MHPMCOUNTER8_addr  : std_logic_vector (11 downto 0) := x"B08";
  constant MHPMCOUNTER9_addr  : std_logic_vector (11 downto 0) := x"B09";
  constant MHPMCOUNTER10_addr : std_logic_vector (11 downto 0) := x"B0A";
  constant MHPMCOUNTER11_addr : std_logic_vector (11 downto 0) := x"B0B";
  constant MHPMCOUNTER12_addr : std_logic_vector (11 downto 0) := x"B0C";
  constant MHPMCOUNTER13_addr : std_logic_vector (11 downto 0) := x"B0D";
  constant MHPMCOUNTER14_addr : std_logic_vector (11 downto 0) := x"B0E";
  constant MHPMCOUNTER15_addr : std_logic_vector (11 downto 0) := x"B0F";
  constant MHPMCOUNTER16_addr : std_logic_vector (11 downto 0) := x"B10";
  constant MHPMCOUNTER17_addr : std_logic_vector (11 downto 0) := x"B11";
  constant MHPMCOUNTER18_addr : std_logic_vector (11 downto 0) := x"B12";
  constant MHPMCOUNTER19_addr : std_logic_vector (11 downto 0) := x"B13";
  constant MHPMCOUNTER20_addr : std_logic_vector (11 downto 0) := x"B14";
  constant MHPMCOUNTER21_addr : std_logic_vector (11 downto 0) := x"B15";
  constant MHPMCOUNTER22_addr : std_logic_vector (11 downto 0) := x"B16";
  constant MHPMCOUNTER23_addr : std_logic_vector (11 downto 0) := x"B17";
  constant MHPMCOUNTER24_addr : std_logic_vector (11 downto 0) := x"B18";
  constant MHPMCOUNTER25_addr : std_logic_vector (11 downto 0) := x"B19";
  constant MHPMCOUNTER26_addr : std_logic_vector (11 downto 0) := x"B1A";
  constant MHPMCOUNTER27_addr : std_logic_vector (11 downto 0) := x"B1B";
  constant MHPMCOUNTER28_addr : std_logic_vector (11 downto 0) := x"B1C";
  constant MHPMCOUNTER29_addr : std_logic_vector (11 downto 0) := x"B1D";
  constant MHPMCOUNTER30_addr : std_logic_vector (11 downto 0) := x"B1E";
  constant MHPMCOUNTER31_addr : std_logic_vector (11 downto 0) := x"B1F";
  constant MCYCLEH_addr       : std_logic_vector (11 downto 0) := x"B80";
  constant MINSTRETH_addr     : std_logic_vector (11 downto 0) := x"B82";
  constant MHPMEVENT3_addr    : std_logic_vector (11 downto 0) := x"323";
  constant MHPMEVENT4_addr    : std_logic_vector (11 downto 0) := x"324";
  constant MHPMEVENT5_addr    : std_logic_vector (11 downto 0) := x"325";
  constant MHPMEVENT6_addr    : std_logic_vector (11 downto 0) := x"326";
  constant MHPMEVENT7_addr    : std_logic_vector (11 downto 0) := x"327";
  constant MHPMEVENT8_addr    : std_logic_vector (11 downto 0) := x"328";
  constant MHPMEVENT9_addr    : std_logic_vector (11 downto 0) := x"329";
  constant MHPMEVENT10_addr   : std_logic_vector (11 downto 0) := x"32A";
  constant MHPMEVENT11_addr   : std_logic_vector (11 downto 0) := x"32B";
  constant MHPMEVENT12_addr   : std_logic_vector (11 downto 0) := x"32C";
  constant MHPMEVENT13_addr   : std_logic_vector (11 downto 0) := x"32D";
  constant MHPMEVENT14_addr   : std_logic_vector (11 downto 0) := x"32E";
  constant MHPMEVENT15_addr   : std_logic_vector (11 downto 0) := x"32F";
  constant MHPMEVENT16_addr   : std_logic_vector (11 downto 0) := x"330";
  constant MHPMEVENT17_addr   : std_logic_vector (11 downto 0) := x"331";
  constant MHPMEVENT18_addr   : std_logic_vector (11 downto 0) := x"332";
  constant MHPMEVENT19_addr   : std_logic_vector (11 downto 0) := x"333";
  constant MHPMEVENT20_addr   : std_logic_vector (11 downto 0) := x"334";
  constant MHPMEVENT21_addr   : std_logic_vector (11 downto 0) := x"335";
  constant MHPMEVENT22_addr   : std_logic_vector (11 downto 0) := x"336";
  constant MHPMEVENT23_addr   : std_logic_vector (11 downto 0) := x"337";
  constant MHPMEVENT24_addr   : std_logic_vector (11 downto 0) := x"338";
  constant MHPMEVENT25_addr   : std_logic_vector (11 downto 0) := x"339";
  constant MHPMEVENT26_addr   : std_logic_vector (11 downto 0) := x"33A";
  constant MHPMEVENT27_addr   : std_logic_vector (11 downto 0) := x"33B";
  constant MHPMEVENT28_addr   : std_logic_vector (11 downto 0) := x"33C";
  constant MHPMEVENT29_addr   : std_logic_vector (11 downto 0) := x"33D";
  constant MHPMEVENT30_addr   : std_logic_vector (11 downto 0) := x"33E";
  constant MHPMEVENT31_addr   : std_logic_vector (11 downto 0) := x"33F";
  constant MVSIZE_addr        : std_logic_vector (11 downto 0) := x"FF0"; 

  
  constant OP_IMM   : std_logic_vector(6 downto 0) := "0010011";
  constant LUI      : std_logic_vector(6 downto 0) := "0110111";
  constant AUIPC    : std_logic_vector(6 downto 0) := "0010111";
  constant OP       : std_logic_vector(6 downto 0) := "0110011";
  constant JAL      : std_logic_vector(6 downto 0) := "1101111";
  constant JALR     : std_logic_vector(6 downto 0) := "1100111";
  constant BRANCH   : std_logic_vector(6 downto 0) := "1100011";
  constant LOAD     : std_logic_vector(6 downto 0) := "0000011";
  constant STORE    : std_logic_vector(6 downto 0) := "0100011";
  constant MISC_MEM : std_logic_vector(6 downto 0) := "0001111";
  constant SYSTEM   : std_logic_vector(6 downto 0) := "1110011";
  constant AMO      : std_logic_vector(6 downto 0) := "0101111";
  constant KMEM     : std_logic_vector(6 downto 0) := "0001011";
  constant KDSP     : std_logic_vector(6 downto 0) := "0101011";

  
  constant ADDI      : std_logic_vector(2 downto 0) := "000";
  constant SLTI      : std_logic_vector(2 downto 0) := "010";
  constant SLTIU     : std_logic_vector(2 downto 0) := "011";
  constant ANDI      : std_logic_vector(2 downto 0) := "111";
  constant ORI       : std_logic_vector(2 downto 0) := "110";
  constant XORI      : std_logic_vector(2 downto 0) := "100";
  constant SLLI      : std_logic_vector(2 downto 0) := "001";
  constant SRLI_SRAI : std_logic_vector(2 downto 0) := "101";

  
  constant ADD_SUB   : std_logic_vector(2 downto 0) := "000";
  constant SLT       : std_logic_vector(2 downto 0) := "010";
  constant SLTU      : std_logic_vector(2 downto 0) := "011";
  constant ANDD      : std_logic_vector(2 downto 0) := "111";
  constant ORR       : std_logic_vector(2 downto 0) := "110";
  constant XORR      : std_logic_vector(2 downto 0) := "100";
  constant SLLL      : std_logic_vector(2 downto 0) := "001";
  constant SRLL_SRAA : std_logic_vector(2 downto 0) := "101";

  
  constant BEQ  : std_logic_vector(2 downto 0) := "000";
  constant BNE  : std_logic_vector(2 downto 0) := "001";
  constant BLT  : std_logic_vector(2 downto 0) := "100";
  constant BGE  : std_logic_vector(2 downto 0) := "101";
  constant BLTU : std_logic_vector(2 downto 0) := "110";
  constant BGEU : std_logic_vector(2 downto 0) := "111";

  
  constant LW  : std_logic_vector(2 downto 0) := "010";
  constant LH  : std_logic_vector(2 downto 0) := "001";
  constant LHU : std_logic_vector(2 downto 0) := "101";
  constant LB  : std_logic_vector(2 downto 0) := "000";
  constant LBU : std_logic_vector(2 downto 0) := "100";

  
  constant SW : std_logic_vector(2 downto 0) := "010";
  constant SH : std_logic_vector(2 downto 0) := "001";
  constant SB : std_logic_vector(2 downto 0) := "000";

  
  constant FENCE  : std_logic_vector(2 downto 0) := "000";
  constant FENCEI : std_logic_vector(2 downto 0) := "001";

  
  constant SINGLE : std_logic_vector(2 downto 0) := "010";


  
  
  constant PRIV   : std_logic_vector(2 downto 0) := "000";
  constant CSRRW  : std_logic_vector(2 downto 0) := "001";
  constant CSRRS  : std_logic_vector(2 downto 0) := "010";
  constant CSRRC  : std_logic_vector(2 downto 0) := "011";
  constant CSRRWI : std_logic_vector(2 downto 0) := "101";
  constant CSRRSI : std_logic_vector(2 downto 0) := "110";
  constant CSRRCI : std_logic_vector(2 downto 0) := "111";

  
  constant LRW     : std_logic_vector(4 downto 0) := "00010";
  constant SCW     : std_logic_vector(4 downto 0) := "00011";
  constant AMOSWAP : std_logic_vector(4 downto 0) := "00001";
  constant AMOADD  : std_logic_vector(4 downto 0) := "00000";
  constant AMOXOR  : std_logic_vector(4 downto 0) := "00100";
  constant AMOAND  : std_logic_vector(4 downto 0) := "01100";
  constant AMOOR   : std_logic_vector(4 downto 0) := "01000";
  constant AMOMIN  : std_logic_vector(4 downto 0) := "10000";
  constant AMOMAX  : std_logic_vector(4 downto 0) := "10100";
  constant AMOMINU : std_logic_vector(4 downto 0) := "11000";
  constant AMOMAXU : std_logic_vector(4 downto 0) := "11100";

  
  constant SRLI7 : std_logic_vector(6 downto 0) := "0000000";
  constant SRAI7 : std_logic_vector(6 downto 0) := "0100000";
  constant ADD7  : std_logic_vector(6 downto 0) := "0000000";
  constant SUB7  : std_logic_vector(6 downto 0) := "0100000";
  constant SRLL7 : std_logic_vector(6 downto 0) := "0000000";
  constant SRAA7 : std_logic_vector(6 downto 0) := "0100000";

  
  constant KMEMLD  : std_logic_vector(6 downto 0) := "0000000";
  constant KMEMSTR : std_logic_vector(6 downto 0) := "0000001";

  
  constant KADDV : std_logic_vector(6 downto 0) := "0000001";
  constant KDOTP : std_logic_vector(6 downto 0) := "0000010";

  
  
  constant ECALL  : std_logic_vector(11 downto 0) := "000000000000";
  constant EBREAK : std_logic_vector(11 downto 0) := "000000000001";
  constant MRET   : std_logic_vector(11 downto 0) := "001100000010";
  constant WFI    : std_logic_vector(11 downto 0) := "000100000101";

  
  constant RDCYCLE    : std_logic_vector(11 downto 0) := "110000000000";
  constant RDCYCLEH   : std_logic_vector(11 downto 0) := "110010000000";
  constant RDTIME     : std_logic_vector(11 downto 0) := "110000000001";
  constant RDTIMEH    : std_logic_vector(11 downto 0) := "110010000001";
  constant RDINSTRET  : std_logic_vector(11 downto 0) := "110000000010";
  constant RDINSTRETH : std_logic_vector(11 downto 0) := "110010000010";

  
  constant ILLEGAL_INSN_EXCEPT_CODE          : std_logic_vector(31 downto 0) := x"00000002";
  constant LOAD_ERROR_EXCEPT_CODE            : std_logic_vector(31 downto 0) := x"00000005";
  constant STORE_ERROR_EXCEPT_CODE           : std_logic_vector(31 downto 0) := x"00000007";
  constant ECALL_EXCEPT_CODE                 : std_logic_vector(31 downto 0) := x"0000000B";
  constant LOAD_MISALIGNED_EXCEPT_CODE       : std_logic_vector(31 downto 0) := x"00000004";
  constant STORE_MISALIGNED_EXCEPT_CODE      : std_logic_vector(31 downto 0) := x"00000006";
  constant ILLEGAL_VECTOR_SIZE_EXCEPT_CODE   : std_logic_vector(31 downto 0) := x"00000100"; 
  constant ILLEGAL_ADDRESS_EXCEPT_CODE       : std_logic_vector(31 downto 0) := x"00000101"; 
  constant SCRATCHPAD_OVERFLOW_EXCEPT_CODE   : std_logic_vector(31 downto 0) := x"00000102"; 
  constant READ_SAME_SCARTCHPAD_EXCEPT_CODE  : std_logic_vector(31 downto 0) := x"00000103"; 
  constant WRITE_SAME_SCARTCHPAD_EXCEPT_CODE : std_logic_vector(31 downto 0) := x"00000104"; 

  
  constant MTVEC_RESET_VALUE    : replicated_32b_reg := (others => x"00000094");
  constant PCER_RESET_VALUE     : replicated_32b_reg := (others => x"00000000");
  constant MSTATUS_RESET_VALUE  : std_logic_vector(31 downto 0) := x"00001808";
  constant MESTATUS_RESET_VALUE : std_logic_vector(31 downto 0) := x"00001800";
  constant MEPC_RESET_VALUE     : std_logic_vector(31 downto 0) := x"00000000";  
  constant MCAUSE_RESET_VALUE   : std_logic_vector(31 downto 0) := x"00000000";
  constant MIP_RESET_VALUE      : std_logic_vector(31 downto 0) := x"00000000";
  constant MVSIZE_RESET_VALUE   : std_logic_vector(31 downto 0) := x"00000004";

  
  function aq(signal instr : in std_logic_vector(31 downto 0)) return std_logic;
  function rl(signal instr : in std_logic_vector(31 downto 0)) return std_logic;

  function rs1(signal instr : in std_logic_vector(31 downto 0)) return integer;
  function rs2(signal instr : in std_logic_vector(31 downto 0)) return integer;
  function rd(signal instr  : in std_logic_vector(31 downto 0)) return integer;

  function I_immediate(signal instr  : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function S_immediate(signal instr  : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function SB_immediate(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function U_immediate(signal instr  : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function UJ_immediate(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function shamt(signal instr        : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function OPCODE(signal instr       : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function FUNCT3(signal instr       : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function FUNCT7(signal instr       : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function FUNCT12(signal instr      : in std_logic_vector(31 downto 0)) return std_logic_vector;
  function CSR_ADDR(signal instr     : in std_logic_vector(31 downto 0)) return std_logic_vector;

end package;

package body riscv_klessydra is

  function aq (signal instr : in std_logic_vector(31 downto 0)) return std_logic is
  begin
    return instr(26);
  end;

  function rl (signal instr : in std_logic_vector(31 downto 0)) return std_logic is
  begin
    return instr(25);
  end;

  function rs1 (signal instr : in std_logic_vector(31 downto 0)) return integer is
  begin
    return to_integer(unsigned(instr(19 downto 15)));
  end;

  function rs2 (signal instr : in std_logic_vector(31 downto 0)) return integer is
  begin
    return to_integer(unsigned(instr(24 downto 20)));
  end;

  function rd (signal instr : in std_logic_vector(31 downto 0)) return integer is
  begin
    return to_integer(unsigned(instr(11 downto 7)));
  end;

  function I_immediate(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return std_logic_vector(resize(signed(instr(31) & instr(30 downto 20)), 32));
  end;

  function S_immediate(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return std_logic_vector(resize(signed(instr(31 downto 25) & instr(11 downto 8) & instr(7))
, 32));
  end;

  function SB_immediate(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return std_logic_vector(resize(signed(instr(31) & instr(7) & instr(30 downto 25)
                                          & instr(11 downto 8) & '0'), 32));
  end;

  function U_immediate(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return instr(31 downto 12) & std_logic_vector(to_unsigned(0, 12));
  end;

  function UJ_immediate(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return std_logic_vector(resize(signed(instr(31) & instr(19 downto 12) & instr(20)
                                          & instr(30 downto 21) & '0'), 32));
  end;

  function shamt(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return instr(24 downto 20);
  end;

  function OPCODE(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return instr(6 downto 0);
  end;

  function FUNCT3(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return instr(14 downto 12);
  end;

  function FUNCT7(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return instr(31 downto 25);
  end;

  function FUNCT12(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return instr(31 downto 20);
  end;

  function CSR_ADDR(signal instr : in std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return instr(31 downto 20);
  end;

end package body;
