library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

entity CSR_Unit is
  port (
    pc_IE                      : in  std_logic_vector(31 downto 0);
    harc_EXEC                  : in  harc_range;
    harc_to_csr                : in  harc_range;
    instr_word_IE              : in  std_logic_vector(31 downto 0);
    served_except_condition    : in  replicated_bit;
    served_mret_condition      : in  replicated_bit;
    served_irq                 : in  replicated_bit;
    pc_except_value            : in  replicated_32b_reg;
    dbg_req_o                  : in  std_logic;
    data_addr_internal         : in  std_logic_vector(31 downto 0);
    jump_instr                 : in  std_logic;
    branch_instr               : in  std_logic;
    data_valid_waiting_counter : in  std_logic;
    set_branch_condition       : in  std_logic;
    csr_instr_req              : in  std_logic;
    misaligned_err             : in  std_logic;
    WFI_Instr                  : in  std_logic;
    csr_wdata_i                : in  std_logic_vector (31 downto 0);
    csr_op_i                   : in  std_logic_vector (2 downto 0);
    csr_addr_i                 : in  std_logic_vector (11 downto 0);
    csr_instr_done             : out std_logic;
    csr_access_denied_o        : out std_logic;
    csr_rdata_o                : out std_logic_vector (31 downto 0);
    MVSIZE                     : out replicated_32b_reg;
    MSTATUS                    : out replicated_32b_reg;
    MEPC                       : out replicated_32b_reg;
    MCAUSE                     : out replicated_32b_reg;
    MIP                        : out replicated_32b_reg;
    MTVEC                      : out replicated_32b_reg;
    fetch_enable_i             : in  std_logic;
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic;
    cluster_id_i               : in  std_logic_vector(5 downto 0);
    instr_rvalid_i             : in  std_logic;
    data_we_o                  : in  std_logic;
    data_req_o                 : in  std_logic;
    data_gnt_i                 : in  std_logic;
    irq_i                      : in  std_logic;
    irq_id_i                   : in  std_logic_vector(4 downto 0);
    irq_id_o                   : out std_logic_vector(4 downto 0);
    irq_ack_o                  : out std_logic
    );
end entity;


architecture CSR of CSR_Unit is

  signal pc_IE_replicated	: replicated_32b_reg;	
	
  signal PCCRs       : replicated_32b_reg;
  signal PCER        : replicated_32b_reg;
  signal PCMR        : replicated_32b_reg;
  signal MESTATUS    : replicated_32b_reg;
  signal MCPUID      : replicated_32b_reg;
  signal MIMPID      : replicated_32b_reg;
  signal MHARTID     : replicated_32b_reg;
  signal MIRQ        : replicated_32b_reg;
  signal MBADADDR    : replicated_32b_reg;

  signal MCYCLE        : replicated_32b_reg;
  signal MINSTRET      : replicated_32b_reg;
  signal MHPMCOUNTER3  : replicated_32b_reg;
  signal MHPMCOUNTER6  : replicated_32b_reg;
  signal MHPMCOUNTER7  : replicated_32b_reg;
  signal MHPMCOUNTER8  : replicated_32b_reg;
  signal MHPMCOUNTER9  : replicated_32b_reg;
  signal MHPMCOUNTER10 : replicated_32b_reg;
  signal MHPMCOUNTER11 : replicated_32b_reg;
  signal MCYCLEH       : replicated_32b_reg;
  signal MINSTRETH     : replicated_32b_reg;
  signal MHPMEVENT3    : replicated_bit;
  signal MHPMEVENT6    : replicated_bit;
  signal MHPMEVENT7    : replicated_bit;
  signal MHPMEVENT8    : replicated_bit;
  signal MHPMEVENT9    : replicated_bit;
  signal MHPMEVENT10   : replicated_bit;
  signal MHPMEVENT11   : replicated_bit;
  signal MIP_7         : std_logic;
  signal MIP_11        : std_logic;


  signal csr_instr_req_replicated       : replicated_bit;
  signal csr_instr_done_replicated      : replicated_bit;
  signal csr_access_denied_o_replicated : replicated_bit;
  signal csr_rdata_o_replicated         : replicated_32b_reg;

  signal MSTATUS_internal       : replicated_32b_reg;
  signal MEPC_internal          : replicated_32b_reg;
  signal MCAUSE_internal        : replicated_32b_reg;
  signal MIP_internal           : replicated_32b_reg;
  signal MTVEC_internal         : replicated_32b_reg;
  signal irq_ack_o_internal     : std_logic;
  signal trap_hndlr         	: replicated_bit;
  


begin

  MSTATUS       <= MSTATUS_internal;
  MEPC          <= MEPC_internal;
  MCAUSE        <= MCAUSE_internal;
  MIP           <= MIP_internal;
  MTVEC         <= MTVEC_internal;
  irq_ack_o     <= irq_ack_o_internal;

  CSR_updating_logic : for h in harc_range generate

    MCPUID(h) <= std_logic_vector(to_unsigned(256, 32));
    MIMPID(h) <= std_logic_vector(to_unsigned(32768, 32));
    MHARTID(h) <= std_logic_vector(resize(unsigned(cluster_id_i) &
                                          to_unsigned(harc_EXEC, THREAD_ID_SIZE), 32));

    MIRQ(h) <= "0000000000000000000000000" & irq_id_i & "00";
	pc_IE_replicated(harc_EXEC) <= pc_IE;
    csr_instr_req_replicated(h) <= '1' when csr_instr_req = '1' and harc_to_csr = h else '0';
    trap_hndlr(h)               <= '1' when pc_IE_replicated(h) = MTVEC_RESET_VALUE(h)  else '0' when (pc_IE_replicated(h) = MEPC_internal(h)) or (pc_IE_replicated(h) = std_logic_vector(unsigned(MEPC_internal(h)) + 4));

    CSR_unit_op : process(clk_i, rst_ni)

      variable MIP_3_wire : replicated_bit;

    begin

      if rst_ni = '0' then
        MSTATUS_internal(h)                   <= MSTATUS_RESET_VALUE;
        MVSIZE(h)                             <= MVSIZE_RESET_VALUE;
        MESTATUS(h)                           <= MESTATUS_RESET_VALUE;
        MEPC_internal(h)                      <= MEPC_RESET_VALUE;
        MCAUSE_internal(h)                    <= MCAUSE_RESET_VALUE;
        MTVEC_internal(h)                     <= MTVEC_RESET_VALUE(h);
        PCER(h)                           <= PCER_RESET_VALUE(h);
        MCYCLE(h)                         <= x"00000000";
        MINSTRET(h)                       <= x"00000000";
        MHPMCOUNTER3(h)                   <= x"00000000";
        MHPMCOUNTER6(h)                   <= x"00000000";
        MHPMCOUNTER7(h)                   <= x"00000000";
        MHPMCOUNTER8(h)                   <= x"00000000";
        MHPMCOUNTER9(h)                   <= x"00000000";
        MHPMCOUNTER10(h)                  <= x"00000000";
        MCYCLEH(h)                        <= x"00000000";
        MINSTRETH(h)                      <= x"00000000";
        MHPMEVENT3(h)                     <= PCER_RESET_VALUE(h)(2);
        MHPMEVENT6(h)                     <= PCER_RESET_VALUE(h)(5);
        MHPMEVENT7(h)                     <= PCER_RESET_VALUE(h)(6);
        MHPMEVENT8(h)                     <= PCER_RESET_VALUE(h)(7);
        MHPMEVENT9(h)                     <= PCER_RESET_VALUE(h)(8);
        MHPMEVENT10(h)                    <= PCER_RESET_VALUE(h)(9);
        MIP_internal(h)                   <= MIP_RESET_VALUE;

        csr_instr_done_replicated(h)      <= '0';
        csr_access_denied_o_replicated(h) <= '0';
        csr_rdata_o_replicated(h)         <= (others => '0');

      elsif rising_edge(clk_i) then



        if served_irq(h) = '1' and MIP_internal(h)(11) = '1' then
          MCAUSE_internal(h) <= "1" & std_logic_vector(to_unsigned(11, 31));
          MESTATUS(h)    <= MSTATUS_internal(h);
          if trap_hndlr(h) = '0' then
            MEPC_internal(h) <= pc_IE;
          end if;     
          if WFI_Instr = '1' then
			MCAUSE_internal(h)(30) <= '1';
          else
			MCAUSE_internal(h)(30) <= '0';
          end if;
          MSTATUS_internal(h)(3) <= '0';
          MSTATUS_internal(h)(7) <= MSTATUS_internal(h)(3);
        elsif served_irq(h) = '1' and MIP_internal(h)(3) = '1' then
          MCAUSE_internal(h) <= "1" & std_logic_vector(to_unsigned(3, 31));
          MIP_internal(h)(3) <= '0';
          MESTATUS(h)    <= MSTATUS_internal(h);
          if trap_hndlr(h) = '0' then
            MEPC_internal(h) <= pc_IE;
          end if;     
          if WFI_Instr = '1' then
			MCAUSE_internal(h)(30) <= '1';
          else
			MCAUSE_internal(h)(30) <= '0';
          end if;
          MSTATUS_internal(h)(3) <= '0';
          MSTATUS_internal(h)(7) <= MSTATUS_internal(h)(3);
        elsif served_irq(h) = '1' and MIP_internal(h)(7) = '1' then
          MCAUSE_internal(h) <= "1" & std_logic_vector(to_unsigned(7, 31));
          MESTATUS(h)    <= MSTATUS_internal(h);
          if trap_hndlr(h) = '0' then
            MEPC_internal(h) <= pc_IE;
          end if;   
          if WFI_Instr = '1' then
			MCAUSE_internal(h)(30) <= '1';
          else
			MCAUSE_internal(h)(30) <= '0';
          end if;
          MSTATUS_internal(h)(3) <= '0';
          MSTATUS_internal(h)(7) <= MSTATUS_internal(h)(3);
          
        elsif served_except_condition(h) = '1' then
          MCAUSE_internal(h)     <= csr_wdata_i;
          MESTATUS(h)        <= MSTATUS_internal(h);
          MEPC_internal(h)       <= pc_except_value(h);
          MSTATUS_internal(h)(3) <= '0';
          MSTATUS_internal(h)(7) <= '1';
          if misaligned_err = '1' then
            MBADADDR(h) <= data_addr_internal;
          end if;

        elsif served_mret_condition(h) = '1' then
          MSTATUS_internal(h)(7) <= '1';
          MSTATUS_internal(h)(3) <= MSTATUS_internal(h)(7);

        elsif(csr_instr_done_replicated(h) = '1') then
          csr_instr_done_replicated(h)      <= '0';
          csr_access_denied_o_replicated(h) <= '0';
        elsif csr_instr_req_replicated(h) = '1' then
          csr_instr_done_replicated(h) <= '1';
          if (csr_op_i /= "000" and csr_op_i /= "100") then
            case csr_addr_i is
              when MVSIZE_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MVSIZE(h);
                    MVSIZE(h)              <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MVSIZE(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MVSIZE(h) <= (MVSIZE(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MVSIZE(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MVSIZE(h) <= (MVSIZE(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;
              when MSTATUS_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MSTATUS_internal(h);
                    MSTATUS_internal(h)(7)        <= csr_wdata_i(7);
                    MSTATUS_internal(h)(3)        <= csr_wdata_i(3);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MSTATUS_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MSTATUS_internal(h)(7) <= (MSTATUS_internal(h)(7) or csr_wdata_i(7));
                      MSTATUS_internal(h)(3) <= (MSTATUS_internal(h)(3) or csr_wdata_i(3));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MSTATUS_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MSTATUS_internal(h)(7) <= MSTATUS_internal(h)(7) and (not csr_wdata_i(7));
                      MSTATUS_internal(h)(3) <= MSTATUS_internal(h)(3) and (not csr_wdata_i(3));
                    end if;
                  when others =>
                    null;
                end case;
              when MIP_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= (11 => MIP_internal(h)(11), 7 => MIP_internal(h)(7), 3 => MIP_internal(h)(3), others => '0');
                    MIP_internal(h)(3)             <= csr_wdata_i(3);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= (11 => MIP_internal(h)(11), 7 => MIP_internal(h)(7), 3 => MIP_internal(h)(3), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MIP_internal(h)(3) <= (MIP_internal(h)(3) or csr_wdata_i(3));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= (11 => MIP_internal(h)(11), 7 => MIP_internal(h)(7), 3 => MIP_internal(h)(3), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MIP_internal(h)(3) <= (MIP_internal(h)(3) and (not csr_wdata_i(3)));
                    end if;
                  when others =>
                    null;
                end case;
              when MEPC_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MEPC_internal(h);
                    MEPC_internal(h)              <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MEPC_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MEPC_internal(h) <= (MEPC_internal(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MEPC_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MEPC_internal(h) <= (MEPC_internal(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;
              when MTVEC_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MTVEC_internal(h);
                    MEPC_internal(h)              <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MTVEC_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MTVEC_internal(h) <= (MTVEC_internal(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MTVEC_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MTVEC_internal(h) <= (MTVEC_internal(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;
              when MCAUSE_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h)  <= MCAUSE_internal(h);
                    MCAUSE_internal(h)(31)         <= csr_wdata_i(31);
                    MCAUSE_internal(h)(4 downto 0) <= csr_wdata_i(4 downto 0);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MCAUSE_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MCAUSE_internal(h)(31)         <= (MCAUSE_internal(h)(31) or csr_wdata_i(31));
                      MCAUSE_internal(h)(4 downto 0) <= (MCAUSE_internal(h)(4 downto 0) or csr_wdata_i(4 downto 0));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MCAUSE_internal(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MCAUSE_internal(h)(4 downto 0) <= (MCAUSE_internal(h)(4 downto 0) and not(csr_wdata_i(4 downto 0)));
                      MCAUSE_internal(h)(31)         <= (MCAUSE_internal(h)(31) and not(csr_wdata_i(31)));
                    end if;
                  when others =>
                    null;
                end case;
              when MESTATUS_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MESTATUS(h);
                    MESTATUS(h)(0)            <= csr_wdata_i(0);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MESTATUS(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MESTATUS(h)(0) <= (MESTATUS(h)(0) or csr_wdata_i(0));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MESTATUS(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MESTATUS(h)(0) <= (MESTATUS(h)(0) and (not csr_wdata_i(0)));
                    end if;
                  when others =>
                    null;
                end case;
              when MCPUID_addr =>
                case csr_op_i is
                  when CSRRC|CSRRS|CSRRCI|CSRRSI =>
                    if(rs1(instr_word_IE) = 0) then
                      csr_rdata_o_replicated(h) <= MCPUID(h);
                    else
                      csr_access_denied_o_replicated(h) <= '1';
                    end if;
                  when CSRRW|CSRRWI =>
                    csr_access_denied_o_replicated(h) <= '1';
                  when others =>
                    null;
                end case;
              when MIMPID_addr =>
                case csr_op_i is
                  when CSRRC|CSRRS|CSRRCI|CSRRSI =>
                    if(rs1(instr_word_IE) = 0) then
                      csr_rdata_o_replicated(h) <= MIMPID(h);
                    else
                      csr_access_denied_o_replicated(h) <= '1';
                    end if;
                  when CSRRW|CSRRWI =>
                    csr_access_denied_o_replicated(h) <= '1';
                  when others =>
                    null;
                end case;
              when MHARTID_addr =>
                case csr_op_i is
                  when CSRRC|CSRRS|CSRRCI|CSRRSI =>
                    if(rs1(instr_word_IE) = 0) then
                      csr_rdata_o_replicated(h) <= MHARTID(h);
                    else
                      csr_access_denied_o_replicated(h) <= '1';
                    end if;
                  when CSRRW|CSRRWI =>
                    csr_access_denied_o_replicated(h) <= '1';
                  when others =>
                    null;
                end case;
              when MIRQ_addr =>
                case csr_op_i is
                  when CSRRC|CSRRS|CSRRCI|CSRRSI =>
                    if(rs1(instr_word_IE) = 0) then
                      csr_rdata_o_replicated(h) <= MIRQ(h);
                    else
                      csr_access_denied_o_replicated(h) <= '1';
                    end if;
                  when CSRRW|CSRRWI =>
                    csr_access_denied_o_replicated(h) <= '1';
                  when others =>
                    null;
                end case;
              when BADADDR_addr =>
                case csr_op_i is
                  when CSRRC|CSRRS|CSRRCI|CSRRSI =>
                    if(rs1(instr_word_IE) = 0) then
                      csr_rdata_o_replicated(h) <= MBADADDR(h);
                    else
                      csr_access_denied_o_replicated(h) <= '1';
                    end if;
                  when CSRRW|CSRRWI =>
                    csr_access_denied_o_replicated(h) <= '1';
                  when others =>
                    null;
                end case;

              when MCYCLE_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MCYCLE(h);
                    MCYCLE(h)                 <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MCYCLE(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MCYCLE(h) <= (MCYCLE(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MCYCLE(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MCYCLE(h) <= (MCYCLE(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MINSTRET_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= std_logic_vector(unsigned(MINSTRET(h))-1);
                    MINSTRET(h)               <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= std_logic_vector(unsigned(MINSTRET(h))-1);
                    if(rs1(instr_word_IE) /= 0) then
                      MINSTRET(h) <= (MINSTRET(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= std_logic_vector(unsigned(MINSTRET(h))-1);
                    if(rs1(instr_word_IE) /= 0) then
                      MINSTRET(h) <= (MINSTRET(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MCYCLEH_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MCYCLEH(h);
                    MCYCLEH(h)                <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MCYCLEH(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MCYCLEH(h) <= (MCYCLEH(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MCYCLEH(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MCYCLEH(h) <= (MCYCLEH(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MINSTRETH_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    if(MINSTRET(h) = x"00000000" and MINSTRETH(h) /= x"00000000") then
                      csr_rdata_o_replicated(h) <= std_logic_vector(unsigned(MINSTRETH(h))-1);
                    else
                      csr_rdata_o_replicated(h) <= MINSTRETH(h);
                    end if;
                    MINSTRETH(h) <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    if(MINSTRET(h) = x"00000000" and MINSTRETH(h) /= x"00000000") then
                      csr_rdata_o_replicated(h) <= std_logic_vector(unsigned(MINSTRETH(h))-1);
                    else
                      csr_rdata_o_replicated(h) <= MINSTRETH(h);
                    end if;
                    if(rs1(instr_word_IE) /= 0) then
                      MINSTRETH(h) <= (MINSTRETH(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    if(MINSTRET(h) = x"00000000" and MINSTRETH(h) /= x"00000000") then
                      csr_rdata_o_replicated(h) <= std_logic_vector(unsigned(MINSTRETH(h))-1);
                    else
                      csr_rdata_o_replicated(h) <= MINSTRETH(h);
                    end if;
                    if(rs1(instr_word_IE) /= 0) then
                      MINSTRETH(h) <= (MINSTRETH(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMCOUNTER3_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER3(h);
                    MHPMCOUNTER3(h)           <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER3(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER3(h) <= (MHPMCOUNTER3(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER3(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER3(h) <= (MHPMCOUNTER3(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;



              when MHPMCOUNTER6_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER6(h);
                    MHPMCOUNTER6(h)           <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER6(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER6(h) <= (MHPMCOUNTER6(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER6(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER6(h) <= (MHPMCOUNTER6(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMCOUNTER7_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER7(h);
                    MHPMCOUNTER7(h)           <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER7(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER7(h) <= (MHPMCOUNTER7(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER7(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER7(h) <= (MHPMCOUNTER7(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMCOUNTER8_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER8(h);
                    MHPMCOUNTER8(h)           <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER8(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER8(h) <= (MHPMCOUNTER8(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER8(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER8(h) <= (MHPMCOUNTER8(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMCOUNTER9_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER9(h);
                    MHPMCOUNTER9(h)           <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER9(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER9(h) <= (MHPMCOUNTER9(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER9(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER9(h) <= (MHPMCOUNTER9(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMCOUNTER10_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER10(h);
                    MHPMCOUNTER10(h)          <= csr_wdata_i;
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER10(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER10(h) <= (MHPMCOUNTER10(h) or csr_wdata_i);
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= MHPMCOUNTER10(h);
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMCOUNTER10(h) <= (MHPMCOUNTER10(h) and not(csr_wdata_i));
                    end if;
                  when others =>
                    null;
                end case;


              when PCER_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= PCER(h);
                    PCER(h)                   <= csr_wdata_i;
                    MHPMEVENT3(h)             <= csr_wdata_i(2);
                    MHPMEVENT6(h)             <= csr_wdata_i(5);
                    MHPMEVENT7(h)             <= csr_wdata_i(6);
                    MHPMEVENT8(h)             <= csr_wdata_i(7);
                    MHPMEVENT9(h)             <= csr_wdata_i(8);
                    MHPMEVENT10(h)            <= csr_wdata_i(9);

                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= PCER(h);
                    if(rs1(instr_word_IE) /= 0) then
                      PCER(h)        <= (PCER(h) or csr_wdata_i);
                      MHPMEVENT3(h)  <= (PCER(h)(2) or csr_wdata_i(2));
                      MHPMEVENT6(h)  <= (PCER(h)(5) or csr_wdata_i(5));
                      MHPMEVENT7(h)  <= (PCER(h)(6) or csr_wdata_i(6));
                      MHPMEVENT8(h)  <= (PCER(h)(7) or csr_wdata_i(7));
                      MHPMEVENT9(h)  <= (PCER(h)(8) or csr_wdata_i(8));
                      MHPMEVENT10(h) <= (PCER(h)(9) or csr_wdata_i(9));

                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= PCER(h);
                    if(rs1(instr_word_IE) /= 0) then
                      PCER(h)        <= (PCER(h) and not(csr_wdata_i));
                      MHPMEVENT3(h)  <= (PCER(h)(2) and not (csr_wdata_i(2)));
                      MHPMEVENT6(h)  <= (PCER(h)(5) and not (csr_wdata_i(5)));
                      MHPMEVENT7(h)  <= (PCER(h)(6) and not (csr_wdata_i(6)));
                      MHPMEVENT8(h)  <= (PCER(h)(7) and not (csr_wdata_i(7)));
                      MHPMEVENT9(h)  <= (PCER(h)(8) and not (csr_wdata_i(8)));
                      MHPMEVENT10(h) <= (PCER(h)(9) and not (csr_wdata_i(9)));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMEVENT3_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= (2 => MHPMEVENT3(h), others => '0');
                    MHPMEVENT3(h)             <= csr_wdata_i(2);
                    PCER(h)(2)                <= csr_wdata_i(2);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= (2 => MHPMEVENT3(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT3(h) <= (MHPMEVENT3(h) or csr_wdata_i(2));
                      PCER(h)(2)    <= (PCER(h)(2) or csr_wdata_i(2));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= (2 => MHPMEVENT3(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT3(h) <= (MHPMEVENT3(h) and not(csr_wdata_i(2)));
                    end if;
                  when others =>
                    null;
                end case;



              when MHPMEVENT6_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= (5 => MHPMEVENT6(h), others => '0');
                    MHPMEVENT6(h)             <= csr_wdata_i(5);
                    PCER(h)(5)                <= csr_wdata_i(5);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= (5 => MHPMEVENT6(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT6(h) <= (MHPMEVENT6(h) or csr_wdata_i(5));
                      PCER(h)(5)    <= (PCER(h)(5) or csr_wdata_i(5));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= (5 => MHPMEVENT6(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT6(h) <= (MHPMEVENT6(h) and not(csr_wdata_i(5)));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMEVENT7_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= (6 => MHPMEVENT7(h), others => '0');
                    MHPMEVENT7(h)             <= csr_wdata_i(6);
                    PCER(h)(6)                <= csr_wdata_i(6);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= (6 => MHPMEVENT7(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT7(h) <= (MHPMEVENT7(h) or csr_wdata_i(6));
                      PCER(h)(6)    <= (PCER(h)(6) or csr_wdata_i(6));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= (6 => MHPMEVENT7(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT7(h) <= (MHPMEVENT7(h) and not(csr_wdata_i(6)));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMEVENT8_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= (7 => MHPMEVENT8(h), others => '0');
                    MHPMEVENT8(h)             <= csr_wdata_i(7);
                    PCER(h)(7)                <= csr_wdata_i(7);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= (7 => MHPMEVENT8(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT8(h) <= (MHPMEVENT8(h) or csr_wdata_i(7));
                      PCER(h)(7)    <= (PCER(h)(7) or csr_wdata_i(7));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= (7 => MHPMEVENT8(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT8(h) <= (MHPMEVENT8(h) and not(csr_wdata_i(7)));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMEVENT9_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= (8 => MHPMEVENT9(h), others => '0');
                    MHPMEVENT9(h)             <= csr_wdata_i(8);
                    PCER(h)(8)                <= csr_wdata_i(8);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= (8 => MHPMEVENT9(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT9(h) <= (MHPMEVENT9(h) or csr_wdata_i(8));
                      PCER(h)(8)    <= (PCER(h)(8) or csr_wdata_i(8));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= (8 => MHPMEVENT9(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT9(h) <= (MHPMEVENT9(h) and not(csr_wdata_i(8)));
                    end if;
                  when others =>
                    null;
                end case;

              when MHPMEVENT10_addr =>
                case csr_op_i is
                  when CSRRW|CSRRWI =>
                    csr_rdata_o_replicated(h) <= (9 => MHPMEVENT10(h), others => '0');
                    MHPMEVENT10(h)            <= csr_wdata_i(9);
                    PCER(h)(9)                <= csr_wdata_i(9);
                  when CSRRS|CSRRSI =>
                    csr_rdata_o_replicated(h) <= (9 => MHPMEVENT10(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT10(h) <= (MHPMEVENT10(h) or csr_wdata_i(9));
                      PCER(h)(9)     <= (PCER(h)(9) or csr_wdata_i(9));
                    end if;
                  when CSRRC|CSRRCI =>
                    csr_rdata_o_replicated(h) <= (9 => MHPMEVENT10(h), others => '0');
                    if(rs1(instr_word_IE) /= 0) then
                      MHPMEVENT10(h) <= (MHPMEVENT10(h) and not(csr_wdata_i(9)));
                    end if;
                  when others =>
                    null;
                end case;

              when others =>
                csr_rdata_o_replicated(h) <= (others => '0');
            end case;
          else
            null;
          end if;
        end if;


        if dbg_req_o = '0' then
          if (PCER(h)(0) = '1'
              and not(csr_instr_req = '1'
                      and (csr_addr_i = (MCYCLE_addr)
                           or csr_addr_i = MCYCLEH_addr)
                      and (csr_op_i = CSRRWI
                           or csr_op_i = CSRRW
                           or (csr_op_i = CSRRS and rs1(instr_word_IE) /= 0)
                           or (csr_op_i = CSRRSI and rs1(instr_word_IE) /= 0)
                           or (csr_op_i = CSRRC and rs1(instr_word_IE) /= 0)
                           or (csr_op_i = CSRRCI and rs1(instr_word_IE) /= 0)
                           )
                      )
              )
          then
            if(MCYCLE(h) = x"FFFFFFFF") then
              MCYCLEH(h) <= std_logic_vector(unsigned(MCYCLEH(h))+1);
              MCYCLE(h)  <= x"00000000";
            else
              MCYCLE(h) <= std_logic_vector(unsigned(MCYCLE(h))+1);
            end if;
          end if;

          if (PCER(h)(1) = '1'
              and not(csr_instr_req = '1'
                      and (csr_addr_i = (MINSTRET_addr)
                           or csr_addr_i = MINSTRETH_addr)
                      and (csr_op_i = CSRRWI
                           or csr_op_i = CSRRW
                           or (csr_op_i = CSRRS and rs1(instr_word_IE) /= 0)
                           or (csr_op_i = CSRRSI and rs1(instr_word_IE) /= 0)
                           or (csr_op_i = CSRRC and rs1(instr_word_IE) /= 0)
                           or (csr_op_i = CSRRCI and rs1(instr_word_IE) /= 0)
                           )
                      )
              )
          then
            if(instr_rvalid_i = '1') then
              if (MINSTRET(h) = x"FFFFFFFF") then
                MINSTRETH(h) <= std_logic_vector(unsigned(MINSTRETH(h))+1);
                MINSTRET(h)  <= x"00000000";
              else
                MINSTRET(h) <= std_logic_vector(unsigned(MINSTRET(h))+1);
              end if;
            end if;
          end if;

          if (PCER(h)(2) = '1') then
            if (((data_req_o = '1' and data_gnt_i = '0') and data_valid_waiting_counter = '0') or ((not(data_req_o = '1' and data_gnt_i = '0')) and data_valid_waiting_counter = '1')) then
              MHPMCOUNTER3(h) <= std_logic_vector(unsigned(MHPMCOUNTER3(h))+1);
            elsif((data_req_o = '1' and data_gnt_i = '0') and (data_valid_waiting_counter = '1')) then
              MHPMCOUNTER3(h) <= std_logic_vector(unsigned(MHPMCOUNTER3(h))+2);
            end if;
          end if;


          if(PCER(h)(5) = '1') then
            if (data_req_o = '1' and data_gnt_i = '1' and data_we_o = '0') then
              MHPMCOUNTER6(h) <= std_logic_vector(unsigned(MHPMCOUNTER6(h))+1);
            end if;
          end if;

          if(PCER(h)(6) = '1') then
            if (data_req_o = '1' and data_gnt_i = '1' and data_we_o = '1') then
              MHPMCOUNTER7(h) <= std_logic_vector(unsigned(MHPMCOUNTER7(h))+1);
            end if;
          end if;

          if(PCER(h)(7) = '1') then
            if (jump_instr = '1') then
              MHPMCOUNTER8(h) <= std_logic_vector(unsigned(MHPMCOUNTER8(h))+1);
            end if;
          end if;

          if(PCER(h)(8) = '1') then
            if (branch_instr = '1') then
              MHPMCOUNTER9(h) <= std_logic_vector(unsigned(MHPMCOUNTER9(h))+1);
            end if;
          end if;

          if(PCER(h)(9) = '1') then
            if (branch_instr = '1' and set_branch_condition = '1') then
              MHPMCOUNTER10(h) <= std_logic_vector(unsigned(MHPMCOUNTER10(h))+1);
            end if;
          end if;
        end if;
        if h = 0 and unsigned(irq_id_i) >= 28 and irq_i = '1' then
          MIP_internal(h)(7) <= '1';
        else
          MIP_internal(h)(7) <= '0';
        end if;
        if h = 0 and unsigned(irq_id_i) < 28 and irq_i = '1' then
          MIP_internal(h)(11) <= '1';
        else
          MIP_internal(h)(11) <= '0';
        end if;
      end if;
    end process;

  end generate CSR_updating_logic;

  process(all)
    variable wire1, wire2 : std_logic;
  begin
    wire1 := '0'; wire2 := '0';
    for h in harc_range loop
      wire1 := wire1 or csr_instr_done_replicated(h);
      wire2 := wire2 or csr_access_denied_o_replicated(h);
    end loop;
    csr_instr_done      <= wire1;
    csr_access_denied_o <= wire2;
  end process;

  csr_rdata_o <= csr_rdata_o_replicated(harc_EXEC);


  irq_ack_manager : process(clk_i, rst_ni)
    variable wire1 : std_logic;
  begin
    if rst_ni = '0' then
      irq_ack_o_internal <= '0';
    elsif rising_edge(clk_i) then
      wire1 := '0';
      for h in harc_range loop
        wire1 := wire1 or served_irq(h);
      end loop;
      case irq_ack_o_internal is
        when '0' =>
          if wire1 = '0' then
            irq_ack_o_internal <= '0';
          else
            irq_ack_o_internal <= '1';
            irq_id_o       <= irq_id_i;
          end if;
        when '1' =>
          irq_ack_o_internal <= '0';
        when others => null;
      end case;
    end if;
  end process irq_ack_manager;


end CSR;
