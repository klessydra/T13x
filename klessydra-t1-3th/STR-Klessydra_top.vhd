

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

entity klessydra_t1_3th_core is
  generic (
    N_EXT_PERF_COUNTERS : integer := 0;   
    INSTR_RDATA_WIDTH   : integer := 32;  
    N_HWLP              : integer := 2;   
    N_HWLP_BITS         : integer := 4    
    );
  port (
    
    clk_i               : in  std_logic;
    clock_en_i          : in  std_logic;
    rst_ni              : in  std_logic;
    test_en_i           : in  std_logic;
    
    boot_addr_i         : in  std_logic_vector(31 downto 0);
    core_id_i           : in  std_logic_vector(3 downto 0);
    cluster_id_i        : in  std_logic_vector(5 downto 0);
    
    instr_req_o         : out std_logic;
    instr_gnt_i         : in  std_logic;
    instr_rvalid_i      : in  std_logic;
    instr_addr_o        : out std_logic_vector(31 downto 0);
    instr_rdata_i       : in  std_logic_vector(31 downto 0);
    
    data_req_o          : out std_logic;
    data_gnt_i          : in  std_logic;
    data_rvalid_i       : in  std_logic;
    data_we_o           : out std_logic;
    data_be_o           : out std_logic_vector(3 downto 0);
    data_addr_o         : out std_logic_vector(31 downto 0);
    data_wdata_o        : out std_logic_vector(31 downto 0);
    data_rdata_i        : in  std_logic_vector(31 downto 0);
    data_err_i          : in  std_logic;
    
    irq_i               : in  std_logic;
    irq_id_i            : in  std_logic_vector(4 downto 0);
    irq_ack_o           : out std_logic;
    irq_id_o            : out std_logic_vector(4 downto 0);
    irq_sec_i           : in  std_logic;  
    sec_lvl_o           : out std_logic;  
    
    debug_req_i         : in  std_logic;
    debug_gnt_o         : out std_logic;
    debug_rvalid_o      : out std_logic;
    debug_addr_i        : in  std_logic_vector(14 downto 0);
    debug_we_i          : in  std_logic;
    debug_wdata_i       : in  std_logic_vector(31 downto 0);
    debug_rdata_o       : out std_logic_vector(31 downto 0);
    debug_halted_o      : out std_logic;
    debug_halt_i        : in  std_logic;
    debug_resume_i      : in  std_logic;
    
    fetch_enable_i      : in  std_logic;
    core_busy_o         : out std_logic;
    ext_perf_counters_i : in  std_logic_vector(N_EXT_PERF_COUNTERS to 1)
    );

end entity klessydra_t1_3th_core;

architecture Klessydra_T1 of klessydra_t1_3th_core is

  signal reset_state            : std_logic;

  
  signal MVSIZE      : replicated_32b_reg;
  signal MSTATUS     : replicated_32b_reg;
  signal MEPC        : replicated_32b_reg;
  signal MCAUSE      : replicated_32b_reg;
  signal MIP         : replicated_32b_reg;
  signal MTVEC       : replicated_32b_reg;

  signal irq_pending     : replicated_bit;
  signal WFI_Instr		 : std_logic;
  signal except_pc_vec_o : std_logic_vector(31 downto 0);

  
  signal load_err, store_err : std_logic;

  
  signal csr_instr_req       : std_logic;
  signal csr_instr_done      : std_logic;
  signal csr_access_denied_o : std_logic;
  signal csr_wdata_i         : std_logic_vector (31 downto 0);
  signal csr_op_i            : std_logic_vector (2 downto 0);
  signal csr_rdata_o         : std_logic_vector (31 downto 0);
  signal csr_addr_i          : std_logic_vector (11 downto 0);

  
  signal csr_instr_req_replicated       : replicated_bit;
  signal csr_instr_done_replicated      : replicated_bit;
  signal csr_access_denied_o_replicated : replicated_bit;
  signal csr_rdata_o_replicated         : replicated_32b_reg;

  
  signal pc        : replicated_32b_reg;
  signal pc_IE     : std_logic_vector(31 downto 0);  
  signal pc_ID     : std_logic_vector(31 downto 0);
  signal pc_IF     : std_logic_vector(31 downto 0);  

  
  signal instr_word_ID_lat      : std_logic_vector(31 downto 0);  
  signal instr_rvalid_ID        : std_logic;  
  signal instr_word_IE          : std_logic_vector(31 downto 0);
  signal instr_rvalid_IE        : std_logic;  
  signal instr_word_WB          : std_logic_vector(31 downto 0);
  signal instr_rvalid_WB        : std_logic;  

  
  signal pc_update_enable                : replicated_bit;
  signal branch_condition_pending        : replicated_bit;
  signal except_condition_pending        : replicated_bit;
  signal mret_condition_pending          : replicated_bit;
  signal wfi_condition_pending           : replicated_bit;
  signal served_ie_except_condition      : replicated_bit;
  signal served_ls_except_condition      : replicated_bit;
  signal served_dsp_except_condition     : replicated_bit;
  signal served_except_condition         : replicated_bit;
  signal served_mret_condition           : replicated_bit;
  signal served_irq                      : replicated_bit;
  signal taken_branch_pending            : replicated_bit;
  signal ie_except_data                  : std_logic_vector(31 downto 0);
  signal ls_except_data                  : std_logic_vector(31 downto 0);
  signal dsp_except_data                 : std_logic_vector(31 downto 0);
  signal taken_branch                    : std_logic;
  signal ie_taken_branch                 : std_logic;
  signal ls_taken_branch                 : std_logic;
  signal dsp_taken_branch                : std_logic;
  signal set_branch_condition            : std_logic;
  signal ie_except_condition             : std_logic;
  signal ls_except_condition             : std_logic;
  signal dsp_except_condition            : std_logic;
  signal set_except_condition            : std_logic;
  signal set_mret_condition              : std_logic;
  signal set_branch_condition_replicated : replicated_bit;
  signal set_wfi_condition_replicated    : replicated_bit;
  signal set_except_condition_replicated : replicated_bit;
  signal set_mret_condition_replicated   : replicated_bit;
  signal PC_offset                       : replicated_32b_reg;
  signal pc_except_value                 : replicated_32b_reg;
  signal taken_branch_pc_lat             : replicated_32b_reg;
  signal incremented_pc                  : replicated_32b_reg;
  signal mepc_incremented_pc             : replicated_32b_reg := (others => (others => '0'));
  signal mepc_interrupt_pc               : replicated_32b_reg := (others => (others => '0'));
  signal relative_to_PC                  : replicated_32b_reg;
  signal absolute_jump                   : std_logic;
  signal data_we_o_lat                   : std_logic;
  signal misaligned_err                  : std_logic;

  
  
  signal boot_pc : std_logic_vector(31 downto 0);

  
  
  
  
  

  
  signal regfile   : regfile_replicated_array;

  
  signal set_wfi_condition          : std_logic;
  signal harc_to_csr                : harc_range;
  signal jump_instr                 : std_logic;
  signal jump_instr_lat             : std_logic;
  signal branch_instr               : std_logic;
  signal branch_instr_lat           : std_logic;
  signal data_valid_waiting_counter : std_logic;

  
  signal data_addr_internal     : std_logic_vector(31 downto 0);
  signal data_be_internal       : std_logic_vector(3 downto 0);

  
  signal dbg_req_o       : std_logic;
  signal dbg_halted_o    : std_logic;
  signal dbg_ack_i       : std_logic;
  signal ebreak_instr    : std_logic;

  
  
  signal harc_IF         : harc_range;
  signal harc_ID         : harc_range;
  signal harc_LS         : harc_range;
  signal harc_DSP        : harc_range;
  signal harc_EXEC       : harc_range;

  component Program_Counter
  port (
    absolute_jump                     : in  std_logic;
    data_we_o_lat                     : in  std_logic;
    PC_offset                         : in  replicated_32b_reg;
    taken_branch                      : in  std_logic;
    ie_taken_branch                   : in  std_logic;
    ls_taken_branch                   : in  std_logic;
    dsp_taken_branch                  : in  std_logic;
    set_branch_condition              : in  std_logic;
    ie_except_condition               : in  std_logic;
    ls_except_condition               : in  std_logic;
    dsp_except_condition              : in  std_logic;
    set_except_condition              : in  std_logic;
    set_mret_condition                : in  std_logic;
    set_wfi_condition                 : in  std_logic;
    harc_ID                           : in  harc_range;
    harc_LS                           : in harc_range;
    harc_DSP                          : in harc_range;
    harc_EXEC                         : in  harc_range;
    instr_rvalid_IE                   : in  std_logic;
    pc_IE                             : in  std_logic_vector(31 downto 0);
    MIP, MEPC, MSTATUS, MCAUSE, MTVEC : in  replicated_32b_reg;
    instr_word_IE                     : in  std_logic_vector(31 downto 0);
    reset_state                       : in  std_logic;
    pc_IF                             : out std_logic_vector(31 downto 0);
    harc_IF                           : out harc_range;
    served_ie_except_condition        : out replicated_bit;
    served_ls_except_condition        : out replicated_bit;
    served_dsp_except_condition       : out replicated_bit;
    served_except_condition           : out replicated_bit;
    served_mret_condition             : out replicated_bit;
    served_irq                        : in  replicated_bit;
    taken_branch_pending              : out replicated_bit;
    taken_branch_pc_lat               : out replicated_32b_reg;
    incremented_pc                    : out replicated_32b_reg;
    mepc_incremented_pc               : out replicated_32b_reg;
    mepc_interrupt_pc                 : out replicated_32b_reg;
    irq_pending                       : out replicated_bit;
    branch_condition_pending          : out replicated_bit;
    except_condition_pending          : out replicated_bit;
    mret_condition_pending            : out replicated_bit;
    clk_i                             : in  std_logic;
    rst_ni                            : in  std_logic;
    irq_i                             : in  std_logic;
    fetch_enable_i                    : in  std_logic;
    boot_addr_i                       : in  std_logic_vector(31 downto 0);
    instr_gnt_i                       : in  std_logic
    );
  end component;

  component CSR_Unit
  port (
    pc_IE                       : in  std_logic_vector(31 downto 0);
    ie_except_data              : in  std_logic_vector(31 downto 0);
    ls_except_data              : in  std_logic_vector(31 downto 0);
    dsp_except_data             : in  std_logic_vector(31 downto 0);
    served_ie_except_condition  : in  replicated_bit;
    served_ls_except_condition  : in  replicated_bit;
    served_dsp_except_condition : in  replicated_bit;
    harc_EXEC                   : in  harc_range;
    harc_to_csr                 : in  harc_range;
    instr_word_IE               : in  std_logic_vector(31 downto 0);
    served_except_condition     : in  replicated_bit;
    served_mret_condition       : in  replicated_bit;
    served_irq                  : in  replicated_bit;
    pc_except_value             : in  replicated_32b_reg;
    dbg_req_o                   : in  std_logic;
    data_addr_internal          : in  std_logic_vector(31 downto 0);
    jump_instr                  : in  std_logic;
    branch_instr                : in  std_logic;
    data_valid_waiting_counter  : in  std_logic;
    set_branch_condition        : in  std_logic;
    csr_instr_req               : in  std_logic;
    misaligned_err              : in  std_logic;
    WFI_Instr  		            : in  std_logic;
    csr_wdata_i                 : in  std_logic_vector(31 downto 0);
    csr_op_i                    : in  std_logic_vector(2 downto 0);
    csr_addr_i                  : in  std_logic_vector(11 downto 0);
    csr_instr_done              : out std_logic;
    csr_access_denied_o         : out std_logic;
    csr_rdata_o                 : out std_logic_vector (31 downto 0);
    MVSIZE                      : out replicated_32b_reg;
    MSTATUS                     : out replicated_32b_reg;
    MEPC                        : out replicated_32b_reg;
    MCAUSE                      : out replicated_32b_reg;
    MIP                         : out replicated_32b_reg;
    MTVEC                       : out replicated_32b_reg;
    fetch_enable_i              : in  std_logic;
    clk_i                       : in  std_logic;
    rst_ni                      : in  std_logic;
    cluster_id_i                : in  std_logic_vector(5 downto 0);
    instr_rvalid_i              : in  std_logic;
    data_we_o                   : in  std_logic;
    data_req_o                  : in  std_logic;
    data_gnt_i                  : in  std_logic;
    irq_i                       : in  std_logic;
    irq_id_i                    : in  std_logic_vector(4 downto 0);
    irq_id_o                    : out std_logic_vector(4 downto 0);
    irq_ack_o                   : out std_logic
    );
  end component;

  component Debug_Unit
  port(
      set_branch_condition     : in  std_logic;
      set_except_condition     : in  std_logic;
      set_mret_condition       : in  std_logic;
      branch_condition_pending : in  replicated_bit;
      except_condition_pending : in  replicated_bit;
      mret_condition_pending   : in  replicated_bit;
      served_irq               : in  replicated_bit;
      irq_pending              : in  replicated_bit;
      taken_branch_pc_lat      : in  replicated_32b_reg;
      incremented_pc           : in  replicated_32b_reg;
      MTVEC                    : in  replicated_32b_reg;
      MIP                      : in  replicated_32b_reg;
      MSTATUS                  : in  replicated_32b_reg;
      MCAUSE                   : in  replicated_32b_reg;
      mepc_incremented_pc      : in  replicated_32b_reg := (others => (others => '0'));
      mepc_interrupt_pc        : in  replicated_32b_reg := (others => (others => '0'));
      regfile                  : in  regfile_replicated_array;
      pc_IE                    : in  std_logic_vector (31 downto 0);
      harc_EXEC                : in  harc_range;
      ebreak_instr             : in  std_logic;
      dbg_ack_i                : in  std_logic;
      taken_branch             : in  std_logic;
      taken_branch_pending     : in  replicated_bit;
      dbg_req_o                : out std_logic;
      dbg_halted_o             : out std_logic;
      clk_i                    : in  std_logic;
      rst_ni                   : in  std_logic;
      debug_req_i              : in  std_logic;
      debug_gnt_o              : out std_logic;
      debug_rvalid_o           : out std_logic;
      debug_addr_i             : in  std_logic_vector(14 downto 0);
      debug_we_i               : in  std_logic;
      debug_wdata_i            : in  std_logic_vector(31 downto 0);
      debug_rdata_o            : out std_logic_vector(31 downto 0);
      debug_halted_o           : out std_logic;
      debug_halt_i             : in  std_logic;
      debug_resume_i           : in  std_logic
      );
  end component;

  component Pipeline
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
    WFI_Instr                  : out std_logic;
    reset_state                : out std_logic;
    misaligned_err             : out std_logic;
    pc_IE                      : out std_logic_vector(31 downto 0);  
    ie_except_data             : out std_logic_vector(31 downto 0);
    ls_except_data             : out std_logic_vector(31 downto 0);
    dsp_except_data            : out std_logic_vector(31 downto 0);
    taken_branch               : out std_logic;
    ie_taken_branch            : out std_logic;
    ls_taken_branch            : out std_logic;
    dsp_taken_branch           : out std_logic;
    set_branch_condition       : out std_logic;
    ie_except_condition        : out std_logic;
    ls_except_condition        : out std_logic;
    dsp_except_condition       : out std_logic;
    set_except_condition       : out std_logic;
    set_mret_condition         : out std_logic;
    set_wfi_condition          : out std_logic;
    csr_instr_req              : out std_logic;
    instr_rvalid_IE            : out std_logic;  
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
    
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic;
    
    instr_req_o                : out std_logic;
    instr_gnt_i                : in  std_logic;
    instr_rvalid_i             : in  std_logic;
    instr_addr_o               : out std_logic_vector(31 downto 0);
    instr_rdata_i              : in  std_logic_vector(31 downto 0);
    
    data_req_o                 : out std_logic;
    data_gnt_i                 : in  std_logic;
    data_rvalid_i              : in  std_logic;
    data_we_o                  : out std_logic;
    data_be_o                  : out std_logic_vector(3 downto 0);
    data_addr_o                : out std_logic_vector(31 downto 0);
    data_wdata_o               : out std_logic_vector(31 downto 0);
    data_rdata_i               : in  std_logic_vector(31 downto 0);
    data_err_i                 : in  std_logic;
    
	irq_i               	   : in  std_logic;
    
    debug_halted_o             : out std_logic;
    
    fetch_enable_i             : in  std_logic;
    core_busy_o                : out std_logic
    );
  end component;

begin

  
  

  Prg_Ctr : Program_Counter
    port map(
      absolute_jump                => absolute_jump,
      data_we_o_lat                => data_we_o_lat,
      PC_offset                    => PC_offset,
      taken_branch                 => taken_branch,
      ie_taken_branch              => ie_taken_branch,
      ls_taken_branch              => ls_taken_branch,
      dsp_taken_branch             => dsp_taken_branch,
      set_branch_condition         => set_branch_condition,
      ie_except_condition          => ie_except_condition,
      ls_except_condition          => ls_except_condition,
      dsp_except_condition         => dsp_except_condition, 
      set_except_condition         => set_except_condition,
      set_mret_condition           => set_mret_condition,
      set_wfi_condition            => set_wfi_condition,
      harc_ID                      => harc_ID,
      harc_LS                      => harc_LS,
      harc_DSP                     => harc_DSP,
      harc_EXEC                    => harc_EXEC,
      instr_rvalid_IE              => instr_rvalid_IE,
      pc_IE                        => pc_IE,
      MIP                          => MIP,
      MEPC                         => MEPC,
      MSTATUS                      => MSTATUS,
      MCAUSE                       => MCAUSE,
      MTVEC                        => MTVEC,
      instr_word_IE                => instr_word_IE,
      reset_state                  => reset_state,
      pc_IF                        => pc_IF,
      harc_IF                      => harc_IF,
      served_ie_except_condition   => served_ie_except_condition,
      served_ls_except_condition   => served_ls_except_condition,
      served_dsp_except_condition  => served_dsp_except_condition,
      served_except_condition      => served_except_condition,
      served_mret_condition        => served_mret_condition,
      served_irq                   => served_irq,
      taken_branch_pending         => taken_branch_pending,
      taken_branch_pc_lat          => taken_branch_pc_lat,
      incremented_pc               => incremented_pc,
      mepc_incremented_pc          => mepc_incremented_pc,
      mepc_interrupt_pc            => mepc_interrupt_pc,
      irq_pending                  => irq_pending,
      branch_condition_pending     => branch_condition_pending,
      except_condition_pending     => except_condition_pending,
      mret_condition_pending       => mret_condition_pending,
      clk_i                        => clk_i,
      rst_ni                       => rst_ni,
      irq_i                        => irq_i,
      fetch_enable_i               => fetch_enable_i,
      boot_addr_i                  => boot_addr_i,
      instr_gnt_i                  => instr_gnt_i
      );

  CSR : CSR_Unit
    port map(
      pc_IE                      => pc_IE,
      ie_except_data             => ie_except_data,
      ls_except_data             => ls_except_data,
      dsp_except_data            => dsp_except_data,
      served_ie_except_condition   => served_ie_except_condition,
      served_ls_except_condition   => served_ls_except_condition,
      served_dsp_except_condition  => served_dsp_except_condition,
      harc_EXEC                  => harc_EXEC,
      harc_to_csr                => harc_to_csr,
      instr_word_IE              => instr_word_IE,
      served_except_condition    => served_except_condition,
      served_mret_condition      => served_mret_condition,
      served_irq                 => served_irq,
      pc_except_value            => pc_except_value,
      dbg_req_o                  => dbg_req_o,
      data_addr_internal         => data_addr_internal,
      jump_instr                 => jump_instr,
      branch_instr               => branch_instr,
      data_valid_waiting_counter => data_valid_waiting_counter,
      set_branch_condition       => set_branch_condition,
      csr_instr_req              => csr_instr_req,
      misaligned_err             => misaligned_err,
      WFI_Instr			         => WFI_Instr,
      csr_wdata_i                => csr_wdata_i,
      csr_op_i                   => csr_op_i,
      csr_addr_i                 => csr_addr_i,
      csr_instr_done             => csr_instr_done,
      csr_access_denied_o        => csr_access_denied_o,
      csr_rdata_o                => csr_rdata_o,
      MVSIZE                     => MVSIZE,
      MSTATUS                    => MSTATUS,
      MEPC                       => MEPC,
      MCAUSE                     => MCAUSE,
      MIP                        => MIP,
      MTVEC                      => MTVEC,
      fetch_enable_i             => fetch_enable_i,
      clk_i                      => clk_i,
      rst_ni                     => rst_ni,
      cluster_id_i               => cluster_id_i,
      instr_rvalid_i             => instr_rvalid_i,
      data_we_o                  => data_we_o,
      data_req_o                 => data_req_o,
      data_gnt_i                 => data_gnt_i,
      irq_i                      => irq_i,
      irq_id_i                   => irq_id_i,
      irq_id_o                   => irq_id_o,
      irq_ack_o                  => irq_ack_o
      );

  DBG : Debug_Unit
    port map(
      set_branch_condition     => set_branch_condition,
      set_except_condition     => set_except_condition,
      set_mret_condition       => set_mret_condition,
      branch_condition_pending => branch_condition_pending,
      except_condition_pending => except_condition_pending,
      mret_condition_pending   => mret_condition_pending,
      served_irq               => served_irq,
      irq_pending              => irq_pending,
      taken_branch_pc_lat      => taken_branch_pc_lat,
      incremented_pc           => incremented_pc,
      MTVEC                    => MTVEC,
      MIP                      => MIP,
      MSTATUS                  => MSTATUS,
      MCAUSE                   => MCAUSE,
      mepc_incremented_pc      => mepc_incremented_pc,
      mepc_interrupt_pc        => mepc_interrupt_pc,
      regfile                  => regfile,
      pc_IE                    => pc_IE,
      harc_EXEC                => harc_EXEC,
      ebreak_instr             => ebreak_instr,
      dbg_ack_i                => dbg_ack_i,
      taken_branch	           => taken_branch,
      taken_branch_pending     => taken_branch_pending,
      dbg_req_o                => dbg_req_o,
      dbg_halted_o             => dbg_halted_o,
      clk_i                    => clk_i,
      rst_ni                   => rst_ni,
      debug_req_i              => debug_req_i,
      debug_gnt_o              => debug_gnt_o,
      debug_rvalid_o           => debug_rvalid_o,
      debug_addr_i             => debug_addr_i,
      debug_we_i               => debug_we_i,
      debug_wdata_i            => debug_wdata_i,
      debug_rdata_o            => debug_rdata_o,
      debug_halted_o           => debug_halted_o,
      debug_halt_i             => debug_halt_i,
      debug_resume_i           => debug_resume_i
      );

  Pipe : Pipeline
    port map(
      pc_IF                      => pc_IF,
      harc_IF                    => harc_IF,
      irq_pending                => irq_pending,
      csr_instr_done             => csr_instr_done,
      csr_access_denied_o        => csr_access_denied_o,
      csr_rdata_o                => csr_rdata_o,
      dbg_req_o                  => dbg_req_o,
      dbg_halted_o               => dbg_halted_o,
      pc_IE                      => pc_IE,
      ie_except_data             => ie_except_data,
      ls_except_data             => ls_except_data,
      dsp_except_data            => dsp_except_data,
      MVSIZE                     => MVSIZE,
      MSTATUS                    => MSTATUS,
      served_irq                 => served_irq,	
      WFI_Instr			         => WFI_Instr,
      reset_state                => reset_state,
      misaligned_err             => misaligned_err,
      taken_branch               => taken_branch,
      ie_taken_branch            => ie_taken_branch,
      ls_taken_branch            => ls_taken_branch,
      dsp_taken_branch           => dsp_taken_branch,
      set_branch_condition       => set_branch_condition,
      ie_except_condition        => ie_except_condition,
      ls_except_condition        => ls_except_condition,
      dsp_except_condition       => dsp_except_condition, 
      set_except_condition       => set_except_condition,
      set_mret_condition         => set_mret_condition,
      set_wfi_condition          => set_wfi_condition,
      csr_instr_req              => csr_instr_req,
      instr_rvalid_IE            => instr_rvalid_IE,
      csr_addr_i                 => csr_addr_i,
      csr_wdata_i                => csr_wdata_i,
      csr_op_i                   => csr_op_i,
      jump_instr                 => jump_instr,
      jump_instr_lat             => jump_instr_lat,
      branch_instr               => branch_instr,
      branch_instr_lat           => branch_instr_lat,
      data_valid_waiting_counter => data_valid_waiting_counter,
      harc_ID                    => harc_ID,
      harc_LS                    => harc_LS,
      harc_DSP                   => harc_DSP,
      harc_EXEC                  => harc_EXEC,
      harc_to_csr                => harc_to_csr,
      instr_word_IE              => instr_word_IE,
      PC_offset                  => PC_offset,
      pc_except_value            => pc_except_value,
      dbg_ack_i                  => dbg_ack_i,
      ebreak_instr               => ebreak_instr,
      data_addr_internal         => data_addr_internal,
      absolute_jump              => absolute_jump,
      regfile                    => regfile,
      clk_i                      => clk_i,
      rst_ni                     => rst_ni,
      instr_req_o                => instr_req_o,
      instr_gnt_i                => instr_gnt_i,
      instr_rvalid_i             => instr_rvalid_i,
      instr_addr_o               => instr_addr_o,
      instr_rdata_i              => instr_rdata_i,
      data_req_o                 => data_req_o,
      data_gnt_i                 => data_gnt_i,
      data_rvalid_i              => data_rvalid_i,
      data_we_o                  => data_we_o,
      data_be_o                  => data_be_o,
      data_addr_o                => data_addr_o,
      data_wdata_o               => data_wdata_o,
      data_rdata_i               => data_rdata_i,
      data_err_i                 => data_err_i,
      irq_i                      => irq_i,
      debug_halted_o             => debug_halted_o,
      fetch_enable_i             => fetch_enable_i,
      core_busy_o                => core_busy_o
      );

end Klessydra_T1;
