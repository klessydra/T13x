library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;


entity Program_Counter is
  port (
    absolute_jump                     : in  std_logic;
    data_we_o_lat                     : in  std_logic;
    PC_offset                         : in  replicated_32b_reg;
    taken_branch                      : in  std_logic;
    set_branch_condition              : in  std_logic;
    ls_except_condition               : in  std_logic;
    ie_except_condition               : in  std_logic;
    dsp_except_condition              : in  std_logic;
    set_except_condition              : in  std_logic;
    set_mret_condition                : in  std_logic;
    set_wfi_condition                 : in  std_logic;
    harc_ID                           : in  harc_range;
    harc_LS                           : in  harc_range;
    harc_DSP                          : in  harc_range;
    harc_EXEC                         : in  harc_range;
    instr_rvalid_IE                   : in  std_logic;
    pc_IE                             : in  std_logic_vector(31 downto 0);
    MIP, MEPC, MSTATUS, MCAUSE, MTVEC : in  replicated_32b_reg;
    instr_word_IE                     : in  std_logic_vector(31 downto 0);
    reset_state                       : in  std_logic;
    pc_IF                             : out std_logic_vector(31 downto 0);
    harc_IF                           : out harc_range;
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
end entity;



architecture PC of Program_counter is

  signal served_except_condition_lat     : std_logic;
  signal pc_update_enable                : replicated_bit;
  signal wfi_condition_pending           : replicated_bit;
  signal taken_branch_replicated         : replicated_bit;
  signal set_branch_condition_replicated : replicated_bit;
  signal set_wfi_condition_replicated    : replicated_bit;
  signal ls_except_condition_replicated  : replicated_bit;
  signal ie_except_condition_replicated  : replicated_bit;
  signal dsp_except_condition_replicated : replicated_bit;
  signal set_except_condition_replicated : replicated_bit;
  signal set_mret_condition_replicated   : replicated_bit;
  signal relative_to_PC                  : replicated_32b_reg;
  signal pc                              : replicated_32b_reg;
  signal boot_pc                         : std_logic_vector(31 downto 0);

  signal harc_IF_internal                  : harc_range;
  signal harc_IF_comb                      : harc_range;
  signal mret_condition_pending_internal   : replicated_bit;
  signal mepc_incremented_pc_internal      : replicated_32b_reg;
  signal incremented_pc_internal           : replicated_32b_reg;
  signal mepc_interrupt_pc_internal        : replicated_32b_reg;
  signal taken_branch_pc_lat_internal      : replicated_32b_reg;
  signal taken_branch_pending_internal     : replicated_bit;
  signal except_condition_pending_internal : replicated_bit;
  signal irq_pending_internal              : replicated_bit;

  procedure pc_update(
    signal MTVEC                     : in    std_logic_vector(31 downto 0);
    signal instr_gnt_i, taken_branch : in    std_logic;
    signal wfi_condition_pending     : inout std_logic;
    signal set_wfi_condition         : in    std_logic;
    signal taken_branch_pending      : inout std_logic;
    signal irq_pending               : in    std_logic;
    signal set_except_condition      : in    std_logic;
    signal set_mret_condition        : in    std_logic;
    signal pc                        : inout std_logic_vector(31 downto 0);
    signal taken_branch_pc_lat       : in    std_logic_vector(31 downto 0);
    signal incremented_pc            : in    std_logic_vector(31 downto 0);
    signal boot_pc                   : in    std_logic_vector(31 downto 0);
    signal pc_update_enable          : in    std_logic;
    signal served_except_condition   : out   std_logic;
    signal served_mret_condition     : out   std_logic) is
  begin
    if pc_update_enable = '1' then

      if not taken_branch = '1' and not taken_branch_pending = '1'
      then
        pc                      <= incremented_pc;
        served_except_condition <= '0';
        served_mret_condition   <= '0';
      elsif taken_branch = '1' or taken_branch_pending = '1' then
        pc                      <= taken_branch_pc_lat;
        taken_branch_pending    <= '0';
        served_except_condition <= '1' when set_except_condition = '1' else '0';
        served_mret_condition   <= '1' when set_mret_condition = '1' else '0';
      else
        pc <= boot_pc;
      end if;
    else
      served_except_condition <= '0';
      served_mret_condition   <= '0';
      if taken_branch = '1' then
        taken_branch_pending <= '1';
      end if;
      if set_except_condition = '1' then
        served_except_condition <= '1';
      end if;
      if set_mret_condition = '1' then
        served_mret_condition <= '1';
      end if;
      if set_wfi_condition = '1' then
         wfi_condition_pending <= '1';
      end if;
    end if;
  end pc_update;

begin

  harc_IF                  <= harc_IF_internal;
  mret_condition_pending   <= mret_condition_pending_internal;
  mepc_incremented_pc      <= mepc_incremented_pc_internal;
  mepc_interrupt_pc        <= mepc_interrupt_pc_internal;
  taken_branch_pc_lat      <= taken_branch_pc_lat_internal;
  incremented_pc           <= incremented_pc_internal;
  taken_branch_pending     <= taken_branch_pending_internal;
  except_condition_pending <= except_condition_pending_internal;
  irq_pending              <= irq_pending_internal;

  hardware_context_counter : process(all)
  begin
    if rst_ni = '0' then
      harc_IF_internal <= THREAD_POOL_SIZE -1;
    elsif rising_edge(clk_i) then
      if instr_gnt_i = '1' then
        harc_IF_internal <= harc_IF_internal - 1 when harc_IF_internal > 0 else THREAD_POOL_SIZE -1;
      end if;
    end if;
  end process hardware_context_counter;

  pc_IF <= pc(harc_IF_internal);

  boot_pc                                 <= boot_addr_i(31 downto 8) & std_logic_vector(to_unsigned(128, 8));
  mepc_incremented_pc_internal(harc_EXEC) <= MEPC(harc_EXEC);
  mepc_interrupt_pc_internal(harc_EXEC)   <= MEPC(harc_EXEC) when MCAUSE(harc_EXEC)(30) = '0' else std_logic_vector(unsigned(MEPC(harc_EXEC)) + 4);
  pc_update_logic : for h in harc_range generate

    relative_to_PC(h) <= std_logic_vector(to_unsigned(0, 32)) when (absolute_jump = '1')
                         else pc_IE;
    incremented_pc_internal(h) <= std_logic_vector(unsigned(pc(h))+4);
    irq_pending_internal(h)    <= ((MIP(h)(11) or MIP(h)(7) or MIP(h)(3)) and MSTATUS(h)(3));

    set_wfi_condition_replicated(h) <= '1' when set_wfi_condition = '1' and (harc_EXEC = h)
                                  else '0';
    taken_branch_replicated(h) <=      '1' when dsp_except_condition = '1' and (harc_DSP = h)
	                              else '1' when taken_branch = '1' and (harc_EXEC = h)
                                  else '0';
    set_branch_condition_replicated(h) <= '1' when set_branch_condition = '1' and (harc_EXEC = h)
                                     else '0';
    dsp_except_condition_replicated(h) <= '1' when dsp_except_condition  = '1' and (harc_DSP  = h)
                                     else '0';
    ls_except_condition_replicated(h)  <= '1' when ls_except_condition   = '1' and (harc_LS   = h)
                                     else '0';
    ie_except_condition_replicated(h) <= '1' when ie_except_condition  = '1' and (harc_EXEC = h)
                                     else '0';
    set_except_condition_replicated(h) <= '1' when dsp_except_condition_replicated(h)  = '1' or ls_except_condition_replicated(h) = '1' or ie_except_condition_replicated(h) = '1'
                                     else '0';
    set_mret_condition_replicated(h)   <= '1' when set_mret_condition = '1' and (harc_EXEC = h)
                                     else '0';


    taken_branch_pc_lat_internal(h) <=
      MTVEC(h)                                                         when dsp_except_condition_replicated(h) = '1'                       else
      std_logic_vector(signed(relative_to_PC(h))+signed(PC_offset(h))) when set_branch_condition_replicated(h) = '1'                       else
      std_logic_vector(signed(relative_to_PC(h)))                      when set_wfi_condition_replicated(h) = '1'                          else
      MTVEC(h)                                                         when ie_except_condition_replicated(h) = '1'                       else
      mepc_incremented_pc_internal(h)                                  when set_mret_condition_replicated(h) = '1' and MCAUSE(h)(31) = '0' else
      mepc_interrupt_pc_internal(h)                                    when set_mret_condition_replicated(h) = '1' and MCAUSE(h)(31) = '1' else
      MTVEC(h)                                                         when served_irq(h);


    pc_update_enable(h) <= '1' when instr_gnt_i = '1'
                           and (harc_IF_internal = h
                                or taken_branch_replicated(h) = '1'
                                or set_wfi_condition_replicated(h) = '1'
                                or taken_branch_pending_internal(h) = '1'
                                or wfi_condition_pending(h) = '1')
                           else '0';

    pc_updater : process(clk_i, rst_ni, boot_pc)
    begin
      if rst_ni = '0' then
        pc(h)                            <= (others => '0');
        taken_branch_pending_internal(h) <= '0';
        wfi_condition_pending(h)         <= '0';
        served_except_condition(h)       <= '0';
        served_mret_condition(h)         <= '0';
        served_except_condition_lat      <= '0';
      elsif rising_edge(clk_i) then
        served_except_condition_lat <= served_except_condition(h);
        if reset_state = '1' then
          pc(h) <= boot_pc;
        else
          pc_update(MTVEC(h), instr_gnt_i, taken_branch_replicated(h), wfi_condition_pending(h), set_wfi_condition_replicated(h), taken_branch_pending_internal(h),
                    irq_pending_internal(h), set_except_condition_replicated(h), set_mret_condition_replicated(h), pc(h),
                    taken_branch_pc_lat_internal(h), incremented_pc_internal(h), boot_pc, pc_update_enable(h), served_except_condition(h),
                    served_mret_condition(h));
        end if;
      end if;
    end process;


  end generate pc_update_logic;



end PC;
