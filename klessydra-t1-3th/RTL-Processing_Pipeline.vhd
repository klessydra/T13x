-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

-- local packages ------------
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

-- pipeline  pinout --------------------
entity Pipeline is
  port (
    pc_IF                      : in  std_logic_vector(31 downto 0);
    harc_IF                    : in  harc_range;
    irq_pending                : in  replicated_bit;
    csr_instr_done             : in  std_logic;
    csr_access_denied_o        : in  std_logic;
    csr_rdata_o                : in  std_logic_vector (31 downto 0);
    dbg_req_o                  : in  std_logic;
    dbg_halted_o               : in  std_logic;
    MVSIZE                     : in  replicated_32b_reg;
    MSTATUS                    : in  replicated_32b_reg;
    served_irq     	           : out replicated_bit;
    WFI_Instr		           : out std_logic;
    reset_state                : out std_logic;
    misaligned_err             : out std_logic;
    pc_IE                      : out std_logic_vector(31 downto 0);  -- pc_IE is pc entering stage IE
    taken_branch               : out std_logic;
    set_branch_condition       : out std_logic;
    ie_except_condition        : out std_logic;
    ls_except_condition        : out std_logic;
    dsp_except_condition       : out std_logic;
    set_except_condition       : out std_logic;
    set_mret_condition         : out std_logic;
    set_wfi_condition          : out std_logic;
    csr_instr_req              : out std_logic;
    instr_rvalid_IE            : out std_logic;  -- validity bit at IE input
    csr_addr_i                 : out std_logic_vector (11 downto 0);
    csr_wdata_i                : out std_logic_vector (31 downto 0);
    csr_op_i                   : out std_logic_vector (2 downto 0);
    jump_instr                 : out std_logic;
    jump_instr_lat             : out std_logic;
    branch_instr               : out std_logic;
    branch_instr_lat           : out std_logic;
    data_valid_waiting_counter : out std_logic;
    harc_ID                    : out harc_range;
    harc_LS                    : out harc_range;
    harc_DSP                   : out harc_range;
    harc_EXEC                  : out harc_range;
    harc_to_csr                : out harc_range;
    instr_word_IE              : out std_logic_vector(31 downto 0);
    PC_offset                  : out replicated_32b_reg;
    pc_except_value            : out replicated_32b_reg;
    dbg_ack_i                  : out std_logic;
    ebreak_instr               : out std_logic;
    data_addr_internal         : out std_logic_vector(31 downto 0);
    absolute_jump              : out std_logic;
    regfile                    : out regfile_replicated_array;
    -- clock, reset active low, test enable
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic;
    -- program memory interface
    instr_req_o                : out std_logic;
    instr_gnt_i                : in  std_logic;
    instr_rvalid_i             : in  std_logic;
    instr_addr_o               : out std_logic_vector(31 downto 0);
    instr_rdata_i              : in  std_logic_vector(31 downto 0);
    -- data memory interface
    data_req_o                 : out std_logic;
    data_gnt_i                 : in  std_logic;
    data_rvalid_i              : in  std_logic;
    data_we_o                  : out std_logic;
    data_be_o                  : out std_logic_vector(3 downto 0);
    data_addr_o                : out std_logic_vector(31 downto 0);
    data_wdata_o               : out std_logic_vector(31 downto 0);
    data_rdata_i               : in  std_logic_vector(31 downto 0);
    data_err_i                 : in  std_logic;
    -- interrupt request interface
	irq_i               	   : in  std_logic;
    -- debug interface
    debug_halted_o             : out std_logic;
    -- miscellanous control signals
    fetch_enable_i             : in  std_logic;
    core_busy_o                : out std_logic
    );
end entity;  ------------------------------------------


-- Klessydra T03x (4 stages) pipeline implementation -----------------------
architecture Pipe of Pipeline is

  signal instr_rvalid_state     : std_logic;
  signal busy_ID                : std_logic;
  signal core_busy_IE           : std_logic;
  
  signal dsp_parallel_read          : std_logic_vector(1 downto 0);
  signal dsp_parallel_write         : std_logic_vector(1 downto 0);
  signal ls_data_gnt_i              : std_logic_vector(Num_SCs-1 downto 0);
  signal dsp_data_gnt_i             : std_logic_vector(Num_SCs-1 downto 0);
  signal ls_instr_done              : std_logic;
  signal csr_wdata_en               : std_logic;
  signal ie_to_csr                  : std_logic_vector(31 downto 0);
  signal ie_csr_wdata_i             : std_logic_vector(31 downto 0);
  signal ie_except_data             : std_logic_vector(31 downto 0);
  signal ls_except_data             : std_logic_vector(31 downto 0);
  signal dsp_except_data            : std_logic_vector(31 downto 0);
  signal ie_taken_branch            : std_logic;
  signal ls_taken_branch            : std_logic;
  signal dsp_taken_branch           : std_logic;
  signal ie_instr_req               : std_logic;
  signal ls_instr_req               : std_logic;
  signal core_busy_LS               : std_logic;
  signal busy_LS                    : std_logic;
  signal busy_DSP                   : std_logic;
  signal LS_WB_EN                   : std_logic;
  signal LS_WB                      : std_logic_vector(31 downto 0);
  signal data_addr_internal_IE      : std_logic_vector(31 downto 0);
  signal data_be_ID                 : std_logic_vector(3 downto 0);
  signal IE_WB_EN                   : std_logic;
  signal IE_WB                      : std_logic_vector(31 downto 0);
  signal pc_LS_except_value         : replicated_32b_reg;
  signal pc_DSP_except_value        : replicated_32b_reg;
  signal pc_IE_except_value         : replicated_32b_reg;
  signal IE_except_condition_lat    : std_logic;
  signal LS_except_condition_lat    : std_logic;
  signal DSP_except_condition_lat   : std_logic;

  --ID_comnb stage signals
  signal pass_BEQ_ID   : std_logic;
  signal pass_BNE_ID   : std_logic;
  signal pass_BLT_ID   : std_logic;
  signal pass_BLTU_ID  : std_logic;
  signal pass_BGE_ID   : std_logic;
  signal pass_BGEU_ID  : std_logic;
  signal pass_SLTI_ID  : std_logic;
  signal pass_SLTIU_ID : std_logic;
  signal pass_SLT_ID   : std_logic;
  signal pass_SLTU_ID  : std_logic;

  -- program counters --
  signal pc_WB     : std_logic_vector(31 downto 0);  -- pc_WB is pc entering stage WB
  signal pc_ID     : std_logic_vector(31 downto 0);
  signal pc_ID_lat : std_logic_vector(31 downto 0);  -- pc_ID is PC entering ID stage

  -- instruction register and instr. propagation registers --
  signal instr_word_ID_lat       : std_logic_vector(31 downto 0);  -- latch needed for long-latency program memory
  signal instr_rvalid_ID         : std_logic;  -- validity bit at ID input
  signal instr_word_LS_WB        : std_logic_vector(31 downto 0);
  signal instr_word_IE_WB        : std_logic_vector(31 downto 0);
  signal instr_rvalid_WB         : std_logic;  -- idem
  signal decoded_instruction_DSP : std_logic_vector(DSP_UNIT_INSTR_SET_SIZE-1 downto 0);
  signal decoded_instruction_IE  : std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0);
  signal decoded_instruction_LS  : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0);

  --signal used by counters
  signal amo_load_skip : std_logic;
  signal amo_load      : std_logic;
  signal amo_store     : std_logic;
  signal sw_mip        : std_logic;

  -- hardware context id at fetch, and propagated hardware context ids
  signal harc_ID_lat      : harc_range;
  signal harc_LS_WB       : harc_range;
  signal harc_IE_WB       : harc_range;

  -- DSP Unit Signals
  signal ls_sc_data_write_wire  : std_logic_vector(Data_Width/4 -1 downto 0);
  signal ls_sc_data_read_wire   : std_logic_vector(Data_Width/4 -1 downto 0);
  signal dsp_sc_data_read_wire  :  array_2d(NUM_SCs -1 downto 0)(Data_Width -1 downto 0);
  signal dsp_sc_data_write_wire : std_logic_vector(Data_Width -1 downto 0);
  signal rs1_to_sc              : std_logic_vector(2 downto 0);
  signal rs2_to_sc              : std_logic_vector(2 downto 0);
  signal rd_to_sc               : std_logic_vector(2 downto 0);
  signal dsp_instr_req          : std_logic;
  signal dsp_instr_done         : std_logic;
  signal sci_err                : std_logic;
  signal ls_sc_read_addr        : std_logic_vector(Addr_Width -1 downto 0);
  signal ls_sc_write_addr       : std_logic_vector(Addr_Width -1 downto 0);
  signal dsp_sc_read_addr       : std_logic_vector(Addr_Width -1 downto 0);
  signal dsp_sc_write_addr      : std_logic_vector(Addr_Width -1 downto 0);
  signal ls_sci_req             : std_logic_vector(Num_SCs-1 downto 0);
  signal ls_sci_we              : std_logic_vector(Num_SCs-1 downto 0);
  signal dsp_sci_req            : std_logic_vector(Num_SCs-1 downto 0);
  signal dsp_sci_we             : std_logic_vector(Num_SCs-1 downto 0);

  -- instruction operands
  signal S_Imm_IE           : std_logic_vector(11 downto 0);  -- unused
  signal I_Imm_IE           : std_logic_vector(11 downto 0);  -- unused
  signal SB_Imm_IE          : std_logic_vector(11 downto 0);  -- unused
  signal CSR_ADDR_IE        : std_logic_vector(11 downto 0);  -- unused
  signal RS1_Addr_IE        : std_logic_vector(4 downto 0);   -- unused
  signal RS2_Addr_IE        : std_logic_vector(4 downto 0);   -- unused
  signal RD_Addr_IE         : std_logic_vector(4 downto 0);   -- unused
  signal RS1_Data_IE        : std_logic_vector(31 downto 0);
  signal RS2_Data_IE        : std_logic_vector(31 downto 0);
  signal RD_Data_IE         : std_logic_vector(31 downto 0);  -- unused


  component IF_STAGE is
  port (
    pc_IF                      : in  std_logic_vector(31 downto 0);
    harc_IF                    : in  harc_range;
    dbg_halted_o               : in  std_logic; 
	busy_ID                    : in  std_logic;  
	instr_rvalid_i             : in std_logic;
	harc_ID                    : out harc_range;
    pc_ID_lat                  : out std_logic_vector(31 downto 0);  -- pc_ID is PC entering ID stage
    instr_rvalid_ID            : out std_logic; 
	instr_word_ID_lat          : out std_logic_vector(31 downto 0);
	harc_ID_lat                : out harc_range;
    -- clock, reset active low
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic;
    -- program memory interface
    instr_req_o                : out std_logic;
    instr_gnt_i                : in  std_logic;
    instr_addr_o               : out std_logic_vector(31 downto 0);
    instr_rdata_i              : in  std_logic_vector(31 downto 0);
    -- debug interface
    debug_halted_o             : out std_logic
    );
  end component; --------------------------------------------------

  component ID_STAGE is
  port (
	-- Branch Control Signals
    pass_BEQ_ID                : out std_logic;
    pass_BNE_ID                : out std_logic;
    pass_BLT_ID                : out std_logic;
    pass_BLTU_ID               : out std_logic;
    pass_BGE_ID                : out std_logic;
    pass_BGEU_ID               : out std_logic;
    RS1_Data_IE                : out std_logic_vector(31 downto 0);
    RS2_Data_IE                : out std_logic_vector(31 downto 0);
    RD_Data_IE                 : out std_logic_vector(31 downto 0);
    ls_instr_req               : out std_logic;
    ie_instr_req               : out std_logic;
    dsp_instr_req              : out std_logic;
    decoded_instruction_IE     : out std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0);
    decoded_instruction_LS     : out std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0);
    decoded_instruction_DSP    : out std_logic_vector(DSP_UNIT_INSTR_SET_SIZE-1 downto 0);
    data_be_ID                 : out std_logic_vector(3 downto 0);
	amo_store                  : in  std_logic;
	amo_load                   : out std_logic;
	amo_load_skip              : out std_logic;
    instr_word_IE              : out std_logic_vector(31 downto 0);
	harc_ID_lat                : in harc_range;
    pc_ID_lat                  : in std_logic_vector(31 downto 0);  -- pc_ID is PC entering ID stage
	core_busy_IE               : in std_logic;
	core_busy_LS               : in std_logic;
	busy_LS                    : in std_logic;
	busy_DSP                   : in std_logic;
    busy_ID                    : out std_logic;
    pc_IE                      : out std_logic_vector(31 downto 0);  -- pc_IE is pc entering stage IE ***
    instr_rvalid_ID            : in  std_logic; 
    instr_rvalid_IE            : out std_logic;  -- validity bit at IE input
	instr_word_ID_lat          : in std_logic_vector(31 downto 0); 
    sw_mip                     : out std_logic;
    harc_EXEC                  : out harc_range;
    data_addr_internal_IE      : out std_logic_vector(31 downto 0);
    regfile                    : in regfile_replicated_array;
    -- clock, reset active low
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic
    );
  end component;

  component Load_Store_Unit is
  port (
    -- clock, and reset active low
    clk_i, rst_ni              : in std_logic;
    -- ID_Stage Signals
	RS1_Data_IE                : in std_logic_vector(31 downto 0);
	RS2_Data_IE                : in std_logic_vector(31 downto 0);
	RD_Data_IE                 : in std_logic_vector(31 downto 0);
    instr_word_IE              : in std_logic_vector(31 downto 0);
	pc_IE                      : in std_logic_vector(31 downto 0);
	decoded_instruction_LS     : in std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0);
	data_be_ID                 : in std_logic_vector(3 downto 0);  -- AAA Check if needed
	harc_EXEC                  : in harc_range;
	LS_instr_req               : in std_logic;
	core_busy_LS               : out std_logic;
	busy_LS                    : out std_logic;
    -- Processing Pipeline Signals
    rs1_to_sc                  : in std_logic_vector(2 downto 0);
    rs2_to_sc                  : in std_logic_vector(2 downto 0);
    rd_to_sc                   : in std_logic_vector(2 downto 0);
    data_addr_internal         : out std_logic_vector(31 downto 0);
	ls_except_data             : out std_logic_vector(31 downto 0);
	pc_LS_except_value         : out replicated_32b_reg;
	ls_except_condition        : out std_logic;
	ls_taken_branch            : out std_logic;
	amo_load                   : in std_logic;
	amo_load_skip              : in std_logic;
	amo_store                  : out std_logic;
    -- CSR Signals
	misaligned_err             : out std_logic;
	-- Scratchpad Interface Signals
	sci_err                    : in std_logic;
    ls_data_gnt_i              : in std_logic_vector(Num_SCs-1 downto 0);
    ls_sc_data_read_wire       : in std_logic_vector(31 downto 0);
    ls_sci_req                 : out std_logic_vector(Num_SCs-1 downto 0);
    ls_sci_we                  : out std_logic_vector(Num_SCs-1 downto 0);
    ls_sc_read_addr            : out std_logic_vector(Addr_Width -1 downto 0);
    ls_sc_write_addr           : out std_logic_vector(Addr_Width -1 downto 0);
    ls_sc_data_write_wire      : out std_logic_vector(31 downto 0);
	-- WB_Stage Signals
	LS_WB_EN                   : out std_logic;
	harc_LS_WB                 : out harc_range;
	instr_word_LS_WB           : out std_logic_vector(31 downto 0);
	LS_WB                      : out std_logic_vector(31 downto 0);
    -- Data memory interface
    data_req_o                 : out std_logic;
    data_gnt_i                 : in  std_logic;
    data_rvalid_i              : in  std_logic;
    data_we_o                  : out std_logic;
    data_be_o                  : out std_logic_vector(3 downto 0);
    data_addr_o                : out std_logic_vector(31 downto 0);
    data_wdata_o               : out std_logic_vector(31 downto 0);
    data_rdata_i               : in  std_logic_vector(31 downto 0);
    data_err_i                 : in  std_logic
	);
  end component;  ------------------------------------------  

  component IE_STAGE is
  port (
	   -- clock, and reset active low
    clk_i, rst_ni          : in std_logic;
    irq_i                  : in std_logic;
	pc_ID_lat              : in std_logic_vector(31 downto 0);
	RS1_Data_IE            : in std_logic_vector(31 downto 0);
	RS2_Data_IE            : in std_logic_vector(31 downto 0);
	irq_pending            : in replicated_bit;
	fetch_enable_i         : in std_logic;
	csr_instr_done         : in std_logic;
    csr_access_denied_o    : in std_logic;
    csr_rdata_o            : in std_logic_vector (31 downto 0);
    pc_IE                  : in std_logic_vector (31 downto 0);
    instr_word_IE          : in std_logic_vector (31 downto 0);
    data_addr_internal_IE  : in std_logic_vector (31 downto 0);
    pass_BEQ_ID            : in std_logic;
    pass_BNE_ID            : in std_logic;
    pass_BLT_ID            : in std_logic;
    pass_BLTU_ID           : in std_logic;
    pass_BGE_ID            : in std_logic;
    pass_BGEU_ID           : in std_logic;
    sw_mip                 : in std_logic;
    ie_instr_req           : in std_logic;
	dbg_req_o              : in std_logic;
    MSTATUS                : in replicated_32b_reg;
	dsp_taken_branch       : in std_logic;
	harc_DSP               : in harc_range;
	harc_EXEC              : in harc_range;
    instr_rvalid_IE        : in std_logic;  -- validity bit at IE input
	decoded_instruction_IE : in std_logic_vector(EXEC_UNIT_INSTR_SET_SIZE-1 downto 0);
    csr_addr_i             : out std_logic_vector (11 downto 0);
    ie_except_data         : out std_logic_vector (31 downto 0);
    ie_csr_wdata_i         : out std_logic_vector (31 downto 0);
    csr_op_i               : out std_logic_vector (2 downto 0);
    csr_wdata_en           : out std_logic;
    harc_to_csr            : out harc_range;
    csr_instr_req          : out std_logic;
    core_busy_IE           : out std_logic;
    jump_instr             : out std_logic;
    jump_instr_lat         : out std_logic;
	WFI_Instr		       : out std_logic;
    reset_state            : out std_logic;
	set_branch_condition   : out std_logic;
	IE_except_condition    : out std_logic;
    set_mret_condition     : out std_logic;
    set_wfi_condition      : out std_logic;
    ie_taken_branch        : out std_logic;
	branch_instr           : out std_logic;
	branch_instr_lat       : out std_logic;
	PC_offset              : out replicated_32b_reg;
    pc_IE_except_value     : out replicated_32b_reg;
	served_irq     	       : out replicated_bit;
    dbg_ack_i              : out std_logic;
    ebreak_instr           : out std_logic;
	absolute_jump          : out std_logic;
    instr_rvalid_WB        : out std_logic;
    instr_word_IE_WB       : out std_logic_vector (31 downto 0);
    IE_WB_EN               : out std_logic;
	IE_WB                  : out std_logic_vector(31 downto 0);
	harc_IE_WB             : out harc_range;
	pc_WB                  : out std_logic_vector(31 downto 0)
	   );
  end component;  ------------------------------------------

  component DSP_Unit is
  port (
	-- Core Signals
    clk_i, rst_ni              : in std_logic;
    -- Processing Pipeline Signals
    rs1_to_sc                  : in  std_logic_vector(2 downto 0);
    rs2_to_sc                  : in  std_logic_vector(2 downto 0);
    rd_to_sc                   : in  std_logic_vector(2 downto 0);
	-- CSR Signals
    MVSIZE                     : in  replicated_32b_reg;
    dsp_except_data            : out std_logic_vector(31 downto 0);
	-- Program Counter Signals
	pc_DSP_except_value        : out replicated_32b_reg;
	dsp_taken_branch           : out std_logic;
	dsp_except_condition       : out std_logic;
    harc_DSP                   : out harc_range;
    -- ID_Stage Signals
	decoded_instruction_DSP    : in  std_logic_vector(DSP_UNIT_INSTR_SET_SIZE-1 downto 0);
	harc_EXEC                  : in  harc_range;
	pc_IE                      : in  std_logic_vector(31 downto 0);
	RS1_Data_IE                : in  std_logic_vector(31 downto 0);
	RS2_Data_IE                : in  std_logic_vector(31 downto 0);
	RD_Data_IE                 : in  std_logic_vector(31 downto 0);
    dsp_instr_req              : in  std_logic;
    dsp_instr_done             : out std_logic;
    busy_dsp                   : out std_logic;
	-- Scratchpad Interface Signals
    dsp_data_gnt_i             : in  std_logic_vector(Num_SCs-1 downto 0);
	dsp_sc_data_read_wire      : in  array_2d(NUM_SCs -1 downto 0)(Data_Width -1 downto 0);
    dsp_sc_read_addr           : out std_logic_vector(Addr_Width -1 downto 0);
	dsp_sc_data_write_wire     : out std_logic_vector(Data_Width -1 downto 0);
    dsp_sc_write_addr          : out std_logic_vector(Addr_Width -1 downto 0);
	dsp_sci_we                 : out std_logic_vector(Num_SCs-1 downto 0);
	dsp_sci_req                : out std_logic_vector(Num_SCs-1 downto 0);
    dsp_parallel_read          : out std_logic_vector(1 downto 0);
    dsp_parallel_write         : out std_logic_vector(1 downto 0)
	);
  end component;  ------------------------------------------

  component Scratchpad_memory_interface is
  port (
    clk_i, rst_ni              : in std_logic;
	data_rvalid_i              : in std_logic;
    dsp_parallel_read          : in std_logic_vector(1 downto 0);
    dsp_parallel_write         : in std_logic_vector(1 downto 0);
    ls_sc_data_write_wire      : in std_logic_vector(31 downto 0);
    dsp_sc_data_write_wire     : in std_logic_vector(127 downto 0);
    ls_sc_read_addr            : in std_logic_vector(Addr_Width -1 downto 0);
    ls_sc_write_addr           : in std_logic_vector(Addr_Width -1 downto 0);
    dsp_sc_read_addr           : in std_logic_vector(Addr_Width -1 downto 0);
    dsp_sc_write_addr          : in std_logic_vector(Addr_Width -1 downto 0);
    ls_sci_req                 : in std_logic_vector(Num_SCs-1 downto 0);
    ls_sci_we                  : in std_logic_vector(Num_SCs-1 downto 0);
    dsp_sci_req                : in std_logic_vector(Num_SCs-1 downto 0);
    dsp_sci_we                 : in std_logic_vector(Num_SCs-1 downto 0);
    dsp_sc_data_read_wire      : out array_2d(NUM_SCs -1 downto 0)(Data_Width -1 downto 0);
    ls_sc_data_read_wire       : out std_logic_vector(Data_Width/4 -1 downto 0);
    dsp_data_gnt_i             : out std_logic_vector(Num_SCs-1 downto 0);
    ls_data_gnt_i              : out std_logic_vector(Num_SCs-1 downto 0);
    sci_err                    : out std_logic
	);
  end component;  ------------------------------------------
	  
  component WB_STAGE is
  port (
	   -- clock, and reset active low
   clk_i, rst_ni              : in std_logic;
   LS_WB_EN                   : in std_logic;
   IE_WB_EN                   : in std_logic;
   IE_WB                      : in std_logic_vector(31 downto 0);
   LS_WB                      : in std_logic_vector(31 downto 0);
   instr_word_LS_WB           : in std_logic_vector(31 downto 0);
   instr_word_IE_WB           : in std_logic_vector(31 downto 0);
   instr_rvalid_WB            : in std_logic;
   harc_LS_WB                 : in harc_range;
   harc_IE_WB                 : in harc_range;
   regfile                    : out regfile_replicated_array
       );
  end component; -------------------------------  
	  
--------------------------------------------------------------------------------------------------
----------------------- ARCHITECTURE BEGIN -------------------------------------------------------
begin

  -- check for microarchitecture configuration limit, up to 16 thread support.
  assert THREAD_POOL_SIZE < 2**THREAD_ID_SIZE
    report "threading configuration not supported"
  severity error;

	  
  taken_branch <= '1' when (ie_taken_branch = '1' or ls_taken_branch = '1' or dsp_taken_branch = '1') else '0';

  set_except_condition <= '1' when (IE_except_condition = '1' or LS_except_condition = '1' or DSP_except_condition = '1') else '0';

  pc_except_value <= pc_IE_except_value  when IE_except_condition  = '1' 
	            else pc_LS_except_value  when LS_except_condition  = '1' 
                else pc_DSP_except_value when DSP_except_condition = '1';

  ie_to_csr <= ie_except_data when csr_wdata_en = '1' and ie_except_condition_lat = '1' 
		  else ie_csr_wdata_i when csr_wdata_en = '1' and ie_except_condition_lat = '0';
					
  csr_wdata_i     <= ls_except_data  when LS_except_condition_lat  = '1' 
                else dsp_except_data when DSP_except_condition_lat = '1'
                else ie_to_csr when csr_wdata_en = '1';

  --Decode what scratchpads operands rs1, rs2 and, rd refer to
  rs1_to_sc <= "000" when RS1_DATA_IE(31 downto 9) >= x"00109" & "000" and RS1_DATA_IE(31 downto 9) < x"00109" & "001"
          else "001" when RS1_DATA_IE(31 downto 9) >= x"00109" & "001" and RS1_DATA_IE(31 downto 9) < x"00109" & "010"
          else "010" when RS1_DATA_IE(31 downto 9) >= x"00109" & "010" and RS1_DATA_IE(31 downto 9) < x"00109" & "011"
		  else "011" when RS1_DATA_IE(31 downto 9) >= x"00109" & "011" and RS1_DATA_IE(31 downto 9) < x"00109" & "100"
		  else "100";

  rs2_to_sc <= "000" when RS2_DATA_IE(31 downto 9) >= x"00109" & "000" and RS2_DATA_IE(31 downto 9) < x"00109" & "001"
          else "001" when RS2_DATA_IE(31 downto 9) >= x"00109" & "001" and RS2_DATA_IE(31 downto 9) < x"00109" & "010"
          else "010" when RS2_DATA_IE(31 downto 9) >= x"00109" & "010" and RS2_DATA_IE(31 downto 9) < x"00109" & "011"
		  else "011" when RS2_DATA_IE(31 downto 9) >= x"00109" & "011" and RS2_DATA_IE(31 downto 9) < x"00109" & "100"
		  else "100";

  rd_to_sc  <= "000" when RD_DATA_IE(31 downto 9)  >= x"00109" & "000" and RD_DATA_IE(31 downto 9)  < x"00109" & "001"
          else "001" when RD_DATA_IE(31 downto 9)  >= x"00109" & "001" and RD_DATA_IE(31 downto 9)  < x"00109" & "010"
          else "010" when RD_DATA_IE(31 downto 9)  >= x"00109" & "010" and RD_DATA_IE(31 downto 9)  < x"00109" & "011"
		  else "011" when RD_DATA_IE(31 downto 9)  >= x"00109" & "011" and RD_DATA_IE(31 downto 9)  < x"00109" & "100"
		  else "100";
			  
  fsm_IE_state : process(clk_i, rst_ni) -- also implements the delay slot counters and some aux signals
  begin
    
    if rst_ni = '0' then
      LS_except_condition_lat  <= '0'; 
      DSP_except_condition_lat <= '0';
      ie_except_condition_lat  <= '0';
    elsif rising_edge(clk_i) then
      LS_except_condition_lat  <= LS_except_condition; 
      DSP_except_condition_lat <= DSP_except_condition;
      ie_except_condition_lat  <= ie_except_condition;
    end if;
  end process;
	  
------------------------------------------------------------------------------------------------------------------------------------
-- Core_busy_o
------------------------------------------------------------------------------------------------------------------------------------

  core_busy_o <= '1' when (instr_rvalid_i or instr_rvalid_ID or instr_rvalid_IE or instr_rvalid_WB) = '1' and rst_ni = '1' else '0';
------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
-- Mapping of the pipeline stages
------------------------------------------------------------------------------------------------------------------------------------


  FETCH : IF_STAGE
  port map(
    pc_IF                      => pc_IF,         
    harc_IF                    => harc_IF,          
    dbg_halted_o               => dbg_halted_o,     
	busy_ID                    => busy_ID,          
	instr_rvalid_i             => instr_rvalid_i,  
	harc_ID                    => harc_ID,  
    pc_ID_lat                  => pc_ID_lat,        
    instr_rvalid_ID            => instr_rvalid_ID,  
	instr_word_ID_lat          => instr_word_ID_lat,
	harc_ID_lat                => harc_ID_lat,      
    clk_i                      => clk_i,            
    rst_ni                     => rst_ni,           
    instr_req_o                => instr_req_o,      
    instr_gnt_i                => instr_gnt_i,      
    instr_addr_o               => instr_addr_o,     
    instr_rdata_i              => instr_rdata_i,    
    debug_halted_o             => debug_halted_o  
  );

  DECODE : ID_STAGE
  port map(                    
    pass_BEQ_ID                => pass_BEQ_ID,            
    pass_BNE_ID                => pass_BNE_ID,            
    pass_BLT_ID                => pass_BLT_ID,            
    pass_BLTU_ID               => pass_BLTU_ID,
    pass_BGE_ID                => pass_BGE_ID,            
    pass_BGEU_ID               => pass_BGEU_ID,           
    RS1_Data_IE                => RS1_Data_IE,            
    RS2_Data_IE                => RS2_Data_IE,         
    RD_Data_IE                 => RD_Data_IE,         
    ie_instr_req               => ie_instr_req,        
    ls_instr_req               => ls_instr_req,        
    dsp_instr_req              => dsp_instr_req,        
    decoded_instruction_IE     => decoded_instruction_IE, 
    decoded_instruction_LS     => decoded_instruction_LS, 
    decoded_instruction_DSP    => decoded_instruction_DSP,
    data_be_ID                 => data_be_ID,             
	amo_store                  => amo_store,              
	amo_load                   => amo_load,               
	amo_load_skip              => amo_load_skip,          
    instr_word_IE              => instr_word_IE,          
	harc_ID_lat                => harc_ID_lat,            
    pc_ID_lat                  => pc_ID_lat,              
	core_busy_IE               => core_busy_IE,                
	core_busy_LS               => core_busy_LS,                
	busy_LS                    => busy_LS,                
	busy_DSP                   => busy_DSP,                
	busy_ID                    => busy_ID,                
    pc_IE                      => pc_IE,                  
    instr_rvalid_ID            => instr_rvalid_ID,        
    instr_rvalid_IE            => instr_rvalid_IE,        
	instr_word_ID_lat          => instr_word_ID_lat,      
    sw_mip                     => sw_mip,                 
    harc_EXEC                  => harc_EXEC,                
    data_addr_internal_IE      => data_addr_internal_IE,  
    regfile                    => regfile,                
    clk_i                      => clk_i,                 
    rst_ni                     => rst_ni                
  );

  LSU : Load_Store_Unit
  port map(
    clk_i                      => clk_i,
    rst_ni                     => rst_ni,        
    instr_word_IE              => instr_word_IE,                  
	pc_IE                      => pc_IE,   
	RS1_Data_IE                => RS1_Data_IE,           
	RS2_Data_IE                => RS2_Data_IE,           
	RD_Data_IE                 => RD_Data_IE, 
	decoded_instruction_LS     => decoded_instruction_LS,
	data_be_ID                 => data_be_ID, 
	harc_EXEC                  => harc_EXEC,
	LS_instr_req               => LS_instr_req,   
	core_busy_LS               => core_busy_LS,               
	busy_LS                    => busy_LS,    
    rs1_to_sc                  => rs1_to_sc,
    rs2_to_sc                  => rs2_to_sc,
    rd_to_sc                   => rd_to_sc,
    data_addr_internal         => data_addr_internal, 
	ls_except_data             => ls_except_data,    
	pc_LS_except_value         => pc_LS_except_value,  
	ls_except_condition        => ls_except_condition,        
	ls_taken_branch            => ls_taken_branch,
	amo_load                   => amo_load,              
	amo_load_skip              => amo_load_skip,         
	amo_store                  => amo_store,    
	misaligned_err             => misaligned_err,     
	sci_err                    => sci_err,
	ls_data_gnt_i              => ls_data_gnt_i,
    ls_sc_data_read_wire       => ls_sc_data_read_wire,
    ls_sci_req                 => ls_sci_req,
    ls_sci_we                  => ls_sci_we,
	ls_sc_read_addr            => ls_sc_read_addr,
	ls_sc_write_addr           => ls_sc_write_addr,
    ls_sc_data_write_wire      => ls_sc_data_write_wire,
	LS_WB_EN                   => LS_WB_EN,  
	harc_LS_WB                 => harc_LS_WB,
    instr_word_LS_WB           => instr_word_LS_WB,
	LS_WB                      => LS_WB,
    data_req_o                 => data_req_o,   
    data_gnt_i                 => data_gnt_i,            
    data_rvalid_i              => data_rvalid_i,         
    data_we_o                  => data_we_o,             
    data_be_o                  => data_be_o,             
    data_addr_o                => data_addr_o,           
    data_wdata_o               => data_wdata_o,          
    data_rdata_i               => data_rdata_i,          
    data_err_i                 => data_err_i    
  );

  EXECUTE : IE_STAGE
  port map(
    clk_i                      => clk_i,        
    rst_ni                     => rst_ni,          
    irq_i                      => irq_i,                 
	pc_ID_lat                  => pc_ID_lat,             
	RS1_Data_IE                => RS1_Data_IE,           
	RS2_Data_IE                => RS2_Data_IE,           
	irq_pending                => irq_pending,           
	fetch_enable_i             => fetch_enable_i,        
	csr_instr_done             => csr_instr_done,        
    csr_access_denied_o        => csr_access_denied_o,   
    csr_rdata_o                => csr_rdata_o,           
    pc_IE                      => pc_IE,                 
    instr_word_IE              => instr_word_IE,         
    data_addr_internal_IE      => data_addr_internal_IE, 
    pass_BEQ_ID                => pass_BEQ_ID,           
    pass_BNE_ID                => pass_BNE_ID,           
    pass_BLT_ID                => pass_BLT_ID,           
    pass_BLTU_ID               => pass_BLTU_ID,          
    pass_BGE_ID                => pass_BGE_ID,           
    pass_BGEU_ID               => pass_BGEU_ID,          
    sw_mip                     => sw_mip,                
    ie_instr_req               => ie_instr_req,        
	dbg_req_o                  => dbg_req_o,             
    MSTATUS                    => MSTATUS,
	dsp_taken_branch           => dsp_taken_branch,
	harc_DSP                   => harc_DSP,
	harc_EXEC                  => harc_EXEC,               
    instr_rvalid_IE            => instr_rvalid_IE, 
    decoded_instruction_IE     => decoded_instruction_IE,
    csr_addr_i                 => csr_addr_i,            
    ie_except_data             => ie_except_data,
    ie_csr_wdata_i             => ie_csr_wdata_i,
    csr_op_i                   => csr_op_i,       
    csr_wdata_en               => csr_wdata_en,       
    harc_to_csr                => harc_to_csr,           
    csr_instr_req              => csr_instr_req,         
    core_busy_IE               => core_busy_IE,               
    jump_instr                 => jump_instr,            
    jump_instr_lat             => jump_instr_lat,        
	WFI_Instr		           => WFI_Instr,	      
    reset_state                => reset_state,           
	set_branch_condition       => set_branch_condition,  
	IE_except_condition        => IE_except_condition,  
    set_mret_condition         => set_mret_condition,    
    set_wfi_condition          => set_wfi_condition,     
    ie_taken_branch            => ie_taken_branch,          
	branch_instr               => branch_instr,          
	branch_instr_lat           => branch_instr_lat,      
	PC_offset                  => PC_offset,             
    pc_IE_except_value         => pc_IE_except_value,    
	served_irq     	           => served_irq,     	      
    dbg_ack_i                  => dbg_ack_i,             
    ebreak_instr               => ebreak_instr,          
	absolute_jump              => absolute_jump,         
    instr_rvalid_WB            => instr_rvalid_WB,       
    instr_word_IE_WB           => instr_word_IE_WB,         
    IE_WB_EN                   => IE_WB_EN,              
	IE_WB                      => IE_WB,                 
	harc_IE_WB                 => harc_IE_WB,               
	pc_WB                      => pc_WB
  );
	  
  DSP : DSP_Unit
  port map(
    clk_i                      => clk_i,
    rst_ni                     => rst_ni,
    rs1_to_sc                  => rs1_to_sc,
    rs2_to_sc                  => rs2_to_sc,
    rd_to_sc                   => rd_to_sc,
    MVSIZE                     => MVSIZE,
    dsp_except_data            => dsp_except_data,
	pc_DSP_except_value        => pc_DSP_except_value,
	dsp_taken_branch           => dsp_taken_branch,
	dsp_except_condition       => dsp_except_condition,
	harc_DSP                   => harc_DSP,
	decoded_instruction_DSP    => decoded_instruction_DSP,
	harc_EXEC                  => harc_EXEC,
	pc_IE                      => pc_IE,
	RS1_Data_IE                => RS1_Data_IE,
	RS2_Data_IE                => RS2_Data_IE,
	RD_Data_IE                 => RD_Data_IE,
    dsp_instr_req              => dsp_instr_req,
    dsp_instr_done             => dsp_instr_done,
    busy_DSP                   => busy_DSP,
    dsp_data_gnt_i             => dsp_data_gnt_i,
	dsp_sc_data_read_wire      => dsp_sc_data_read_wire,
    dsp_sc_read_addr           => dsp_sc_read_addr,
	dsp_sc_data_write_wire     => dsp_sc_data_write_wire,
    dsp_sc_write_addr          => dsp_sc_write_addr,
	dsp_sci_we                 => dsp_sci_we,
	dsp_sci_req                => dsp_sci_req,
    dsp_parallel_read          => dsp_parallel_read,
    dsp_parallel_write         => dsp_parallel_write
	);
	
  SCI : Scratchpad_memory_interface
  port map(  
    clk_i                      => clk_i,
    rst_ni                     => rst_ni,
	data_rvalid_i              => data_rvalid_i,
	dsp_parallel_read          => dsp_parallel_read,
	dsp_parallel_write         => dsp_parallel_write,
    ls_sc_data_write_wire      => ls_sc_data_write_wire,
    dsp_sc_data_write_wire     => dsp_sc_data_write_wire,
    ls_sc_read_addr            => ls_sc_read_addr,
    ls_sc_write_addr           => ls_sc_write_addr,
    dsp_sc_read_addr           => dsp_sc_read_addr,
    dsp_sc_write_addr          => dsp_sc_write_addr,
    ls_sci_req                 => ls_sci_req,
    ls_sci_we                  => ls_sci_we,
    dsp_sci_req                => dsp_sci_req,
    dsp_sci_we                 => dsp_sci_we,
    ls_sc_data_read_wire       => ls_sc_data_read_wire,
    dsp_sc_data_read_wire      => dsp_sc_data_read_wire,
    dsp_data_gnt_i             => dsp_data_gnt_i,
    ls_data_gnt_i              => ls_data_gnt_i,
    sci_err                    => sci_err
	);
	  
  WRITEBACK : WB_STAGE
  port map(
    clk_i                      => clk_i,          
    rst_ni                     => rst_ni,      
	LS_WB_EN                   => LS_WB_EN,      
	IE_WB_EN                   => IE_WB_EN,      
	IE_WB                      => IE_WB,          
	LS_WB                      => LS_WB,         
	instr_word_LS_WB           => instr_word_LS_WB,  
	instr_word_IE_WB           => instr_word_IE_WB,  
	instr_rvalid_WB            => instr_rvalid_WB,
	harc_LS_WB                 => harc_LS_WB, 
	harc_IE_WB                 => harc_IE_WB, 
	regfile                    => regfile     
  );
  
end Pipe;
--------------------------------------------------------------------------------------------------
-- END of Processing-Pipeline architecture -------------------------------------------------------
--------------------------------------------------------------------------------------------------
