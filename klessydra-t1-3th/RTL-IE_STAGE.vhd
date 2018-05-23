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
entity IE_STAGE is
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
	harc_IE_WB                : out harc_range;
	pc_WB                  : out std_logic_vector(31 downto 0)
	   );
end entity;  ------------------------------------------


-- Klessydra T03x (4 stages) pipeline implementation -----------------------
architecture EXECUTE of IE_STAGE is

  type fsm_IE_states is (sleep, reset, normal, csr_instr_wait_state, debug, first_boot);

  signal state_IE, nextstate_IE : fsm_IE_states;

  -- signals for counting intructions
  signal clock_cycle         : std_logic_vector(63 downto 0);  -- RDCYCLE
  signal external_counter    : std_logic_vector(63 downto 0);  -- RDTIME
  signal instruction_counter : std_logic_vector(63 downto 0);  -- RDINSTRET
  signal flush_cycle_count   : replicated_positive_integer; -- delay slot counter to flush incoming instr. in IE stage

--------------------------------------------------------------------------------------------------
----------------------- ARCHITECTURE BEGIN -------------------------------------------------------
begin

----------------------------------------------------------------------------------------------------
-- stage IE -- (instruction decode/Execute)
----------------------------------------------------------------------------------------------------
-- This stage is composed of an fsm unit fsm_IE that performs synchronous operations,
-- and drives the control signals for accessing data memory and stalling the pipeline if needed
-- fsm_IE may invoke separate units for handling specific instructions (exceptions, csrs)
----------------------------------------------------------------------------------------------------	  
	  
  fsm_IE_sync : process(clk_i, rst_ni)

    -- pragma translate_off
    variable row : line;  -- local variable for instruction tracing, not synthesizable
    -- pragma translate_on

  begin
    if rst_ni = '0' then
      IE_WB                  <= std_logic_vector(to_unsigned(0, 32));
      IE_WB_EN               <= '0';
      instruction_counter    <= std_logic_vector(to_unsigned(0, 64));
      csr_instr_req          <= '0';
      csr_wdata_en           <= '0';
--      dsp_instr_req          <= '0';
--      ld_word_count_internal <= (others => '0');
--      ld_word_count_lat      <= (others => '0');
      csr_op_i               <= (others => '0');
      ie_except_data         <= (others => '0');
      ie_csr_wdata_i         <= (others => '0');
      csr_addr_i             <= (others => '0');
--      dsp_op1                <= (others => '0');
--      dsp_op2                <= (others => '0');
--      dsp_op3                <= (others => '0');
--      KLESS_OP               <= (others => '0');
    elsif rising_edge(clk_i) then
		
      csr_instr_req  <= '0';

      case state_IE is                  -- stage state
        when sleep =>
          null;
        when reset =>
          null;
        when first_boot =>
          null;
        when debug =>
          null;
        when normal =>
          -- check if there is a valid instruction and the thread it belongs to is not in a delay slot: 
          if  ie_instr_req = '0'  or flush_cycle_count(harc_EXEC) /=0 then --instr_rvalid_IE = '0' or flush_cycle_count(harc_EXEC) /=0 then
            IE_WB_EN       <= '0';
            --instr_rvalid_WB <= '0'; -- do nothing and wait for valid instruction and finished delay slot
            -- in a generic version we would have conditions on busy_WB 
            -- in all states of the IE stage, and similarly in the comb process, just
            -- like we did in the ID stage.
          elsif irq_pending(harc_EXEC) = '1' then
            -- manage irq as an absolute branch to MTVEC, also defining mepc value properly in program counter unit
            -- irq is served only if we are not in a delay slot for the interrupted harc
            -- for simplicity presently only harc 0 is interrupted (decided in program counter unit)
            -- the current valid instruction is discarded, only its pc value gets used for mepc
            instr_rvalid_WB <= '0'; -- in the sync process we don't need to do anything here
          else
            instruction_counter <= std_logic_vector(unsigned(instruction_counter)+1);
            pc_WB               <= pc_IE;
            instr_rvalid_WB     <= '1';
            instr_word_IE_WB    <= instr_word_IE;
            harc_IE_WB          <= harc_EXEC;
            csr_wdata_en        <= '0';
--            misaligned_err      <= '0';
            -- pragma translate_off
            --write(row, OPCODE(instr_word_IE)); -- Writes OPCODE(instr_word_IE) value to line GGG
            hwrite(row, pc_IE);  --GGG I write on file instruction machine code and its position on memory program (pc_IE)
            write(row, '_');            --GGG
            hwrite(row, instr_word_IE);     --GGG
            write(row, "   " & to_string(now));  --Add a timestamp to line
            writeline(file_handler, row);  -- Writes line to instr. trace file
            -- pragma translate_on
            -- EXECUTE OF INSTRUCTION -------------------------------------------


            if decoded_instruction_IE(ADDI_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <= std_logic_vector(signed(RS1_Data_IE)+
                                                             signed(I_immediate(instr_word_IE)));
            end if;

            if decoded_instruction_IE(SLTI_bit_position) = '1' then
              if (signed(RS1_Data_IE) < signed (I_immediate(instr_word_IE))) then
                IE_WB_EN       <= '1';
                IE_WB <= std_logic_vector(to_unsigned(1, 32));
              else
                IE_WB_EN       <= '1';
                IE_WB <= std_logic_vector(to_unsigned(0, 32));
              end if;
            end if;

            if decoded_instruction_IE(SLTIU_bit_position) = '1' then
              if (unsigned(RS1_Data_IE) < unsigned (I_immediate(instr_word_IE))) then
                IE_WB_EN       <= '1';
                IE_WB <= std_logic_vector(to_unsigned(1, 32));
              else
                IE_WB_EN       <= '1';
                IE_WB <= std_logic_vector(to_unsigned(0, 32));
              end if;
            end if;

            if decoded_instruction_IE(ANDI_bit_position) = '1' then
              IE_WB_EN                   <= '1';
              IE_WB <= RS1_Data_IE and I_immediate(instr_word_IE);
            end if;

            if decoded_instruction_IE(ORI_bit_position) = '1' then
              IE_WB_EN                   <= '1';
              IE_WB <= RS1_Data_IE or I_immediate(instr_word_IE);
            end if;

            if decoded_instruction_IE(XORI_bit_position) = '1' then
              IE_WB_EN                   <= '1';
              IE_WB <= RS1_Data_IE xor I_immediate(instr_word_IE);
            end if;

            if decoded_instruction_IE(SLLI_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <=
                to_stdlogicvector(to_bitvector(RS1_Data_IE)
                                  sll to_integer(unsigned(SHAMT(instr_word_IE))));
            end if;

            if decoded_instruction_IE(SRLI7_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <=
                to_stdlogicvector(to_bitvector(RS1_Data_IE)
                                  srl to_integer(unsigned(SHAMT(instr_word_IE))));
            end if;

            if decoded_instruction_IE(SRAI7_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <=
                to_stdlogicvector(to_bitvector(RS1_Data_IE)
                                  sra to_integer(unsigned(SHAMT(instr_word_IE))));
            end if;

            if decoded_instruction_IE(LUI_bit_position) = '1' then
              IE_WB_EN                   <= '1';
              IE_WB <= U_immediate(instr_word_IE);
            end if;

            if decoded_instruction_IE(AUIPC_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <= std_logic_vector(signed(U_immediate(instr_word_IE))
                                                             + signed(pc_IE));  --GGG before it was signed(pc)
            end if;

            if decoded_instruction_IE(ADD7_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <= std_logic_vector(signed(RS1_Data_IE)
                                                             + signed(RS2_Data_IE));
            end if;

            if decoded_instruction_IE(SUB7_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <= std_logic_vector(signed(RS1_Data_IE)
                                                             - signed(RS2_Data_IE));
            end if;

            if decoded_instruction_IE(SLT_bit_position) = '1' then
              IE_WB_EN <= '1';
              if (signed(RS1_Data_IE) < signed (RS2_Data_IE)) then
                IE_WB <= std_logic_vector(to_unsigned(1, 32));
              else
                IE_WB <= std_logic_vector(to_unsigned(0, 32));
              end if;
            end if;

            if decoded_instruction_IE(SLTU_bit_position) = '1' then
              IE_WB_EN <= '1';
              if (unsigned(RS1_Data_IE) < unsigned (RS2_Data_IE)) then
                IE_WB <= std_logic_vector(to_unsigned(1, 32));
              else
                IE_WB <= std_logic_vector(to_unsigned(0, 32));
              end if;
            end if;

            if decoded_instruction_IE(ANDD_bit_position) = '1' then
              IE_WB_EN                   <= '1';
              IE_WB <= RS1_Data_IE and RS2_Data_IE;
            end if;

            if decoded_instruction_IE(ORR_bit_position) = '1' then
              IE_WB_EN                   <= '1';
              IE_WB <= RS1_Data_IE or RS2_Data_IE;
            end if;

            if decoded_instruction_IE(XORR_bit_position) = '1' then
              IE_WB_EN                   <= '1';
              IE_WB <= RS1_Data_IE xor RS2_Data_IE;
            end if;

            if decoded_instruction_IE(SLLL_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <=
                to_stdlogicvector(to_bitvector(RS1_Data_IE)
                                  sll to_integer(unsigned(RS2_Data_IE
                                                          (4 downto 0))));
            end if;
            if decoded_instruction_IE(SRLL7_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <=
                to_stdlogicvector(to_bitvector(RS1_Data_IE)
                                  srl to_integer(unsigned(RS2_Data_IE
                                                          (4 downto 0))));
            end if;

            if decoded_instruction_IE(SRAA7_bit_position) = '1' then
              IE_WB_EN <= '1';
              IE_WB <=
                to_stdlogicvector(to_bitvector(RS1_Data_IE)
                                  sra to_integer(unsigned(RS2_Data_IE
                                                          (4 downto 0))));
            end if;

            if decoded_instruction_IE(JAL_bit_position) = '1' or decoded_instruction_IE(JALR_bit_position) = '1' then
              if (rd(instr_word_IE) /= 0) then
                IE_WB_EN                   <= '1';
                IE_WB <= std_logic_vector(unsigned(pc_IE) + "100");
              else                      -- plain unconditional jump
                IE_WB_EN <= '0';
                null;
              end if;
            end if;



            if decoded_instruction_IE(BEQ_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

            if decoded_instruction_IE(BNE_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

            if decoded_instruction_IE(BLT_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

            if decoded_instruction_IE(BLTU_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

            if decoded_instruction_IE(BGE_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

            if decoded_instruction_IE(BGEU_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

            if decoded_instruction_IE(SW_MIP_bit_position) = '1' then
              if sw_mip = '1' then
                csr_op_i      <= CSRRW;
                csr_instr_req <= '1';
                ie_csr_wdata_i   <= RS2_Data_IE;
                csr_wdata_en   <= '1';
                csr_addr_i    <= MIP_ADDR;

				for i in harc_range loop
                	if data_addr_internal_IE(3 downto 0) = std_logic_vector(to_unsigned((4*i),4)) then
                  	harc_to_csr <= i;
                	end if;
				end loop;
              end if;
            end if;

            if decoded_instruction_IE(FENCE_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;                     -- WARNING: still not implemented
            end if;

            if decoded_instruction_IE(FENCEI_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;                     -- WARNING: still not implemented
            end if;

            if decoded_instruction_IE(ECALL_bit_position) = '1' then
              IE_WB_EN                      <= '0';
              ie_except_data                <= ECALL_EXCEPT_CODE;
			  csr_wdata_en                  <= '1';
              pc_IE_except_value(harc_EXEC) <= pc_IE;
            end if;

            if decoded_instruction_IE(EBREAK_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;                     -- WARNING: still not implemented
            end if;

            if decoded_instruction_IE(MRET_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;                     -- managed by combinat. signal
            end if;

            if decoded_instruction_IE(WFI_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

            if decoded_instruction_IE(CSRRW_bit_position) = '1' then
              IE_WB_EN      <= '0';
              csr_op_i      <= FUNCT3(instr_word_IE);
              csr_instr_req <= '1';
              ie_csr_wdata_i  <= RS1_Data_IE;
              csr_wdata_en    <= '1';
              csr_addr_i      <= std_logic_vector(to_unsigned(to_integer(unsigned(CSR_ADDR(instr_word_IE))), 12));
              harc_to_csr     <= harc_EXEC;
            end if;

            if decoded_instruction_IE(CSRRC_bit_position) = '1' or decoded_instruction_IE(CSRRS_bit_position) = '1' then
              IE_WB_EN      <= '0';
              csr_op_i      <= FUNCT3(instr_word_IE);
              csr_instr_req <= '1';
              ie_csr_wdata_i   <= RS1_Data_IE;
              csr_wdata_en   <= '1';
              csr_addr_i    <= std_logic_vector(to_unsigned(to_integer(unsigned(CSR_ADDR(instr_word_IE))), 12));
              harc_to_csr   <= harc_EXEC;
            end if;

            if decoded_instruction_IE(CSRRWI_bit_position) = '1' then
              IE_WB_EN      <= '0';
              csr_op_i      <= FUNCT3(instr_word_IE);
              csr_instr_req <= '1';
              ie_csr_wdata_i   <= std_logic_vector(resize(to_unsigned(rs1(instr_word_IE), 5), 32));
              csr_wdata_en   <= '1';
              csr_addr_i    <= std_logic_vector(to_unsigned(to_integer(unsigned(CSR_ADDR(instr_word_IE))), 12));
              harc_to_csr   <= harc_EXEC;
            end if;

            if decoded_instruction_IE(CSRRSI_bit_position) = '1'or decoded_instruction_IE(CSRRCI_bit_position) = '1' then
              IE_WB_EN      <= '0';
              csr_op_i      <= FUNCT3(instr_word_IE);
              csr_instr_req <= '1';
              ie_csr_wdata_i   <= std_logic_vector(resize(to_unsigned(rs1(instr_word_IE), 5), 32));
              csr_wdata_en   <= '1';
              csr_addr_i    <= std_logic_vector(to_unsigned(to_integer(unsigned(CSR_ADDR(instr_word_IE))), 12));
              harc_to_csr   <= harc_EXEC;
            end if;

            if decoded_instruction_IE(ILL_bit_position) = '1' then
              IE_WB_EN                             <= '0';
              ie_except_data                       <= ILLEGAL_INSN_EXCEPT_CODE;
              csr_wdata_en                         <= '1';
              pc_IE_except_value(harc_EXEC) <= pc_IE;
            end if;

            if decoded_instruction_IE(NOP_bit_position) = '1' then
              IE_WB_EN <= '0';
              null;
            end if;

          -- EXECUTE OF INSTRUCTION (END) --------------------------
          end if;  -- instr_rvalid_IE values
          
        when csr_instr_wait_state =>
          csr_instr_req <= '0';
          if (csr_instr_done = '1' and csr_access_denied_o = '0') then
            if (rd(instr_word_IE) /= 0) then
              IE_WB_EN <= '1';
              IE_WB <= csr_rdata_o;
            else
              IE_WB_EN <= '0';
              null;
            end if;
          elsif (csr_instr_done = '1' and csr_access_denied_o = '1') then  -- ILLEGAL_INSTRUCTION
            IE_WB_EN                             <= '0';
            csr_wdata_en                         <= '1';
            ie_except_data                       <= ILLEGAL_INSN_EXCEPT_CODE;
            pc_IE_except_value  (harc_EXEC) <= pc_IE;
          else
            IE_WB_EN <= '0'; -- do nothing and wait
          end if;
      end case;  -- fsm_IE state cases
    end if;  -- reset, clk_i
  end process;

  fsm_IE_comb : process(all)

    variable PC_offset_wires                  : replicated_32b_reg;
    variable absolute_jump_wires              : std_logic;
    variable core_busy_IE_wires               : std_logic;
    variable IE_except_condition_wires        : std_logic;
    variable set_branch_condition_wires       : std_logic;
    variable ie_taken_branch_wires            : std_logic;
    variable set_mret_condition_wires         : std_logic;
    variable set_wfi_condition_wires          : std_logic;
    variable jump_instr_wires                 : std_logic;
    variable branch_instr_wires               : std_logic;
    variable ebreak_instr_wires               : std_logic;
    variable dbg_ack_i_wires                  : std_logic;
    variable WFI_Instr_wires		          : std_logic;
    variable served_irq_wires                 : replicated_bit;
    variable nextstate_IE_wires               : fsm_IE_states;

  begin
    served_irq_wires		         := (others => '0');
    absolute_jump_wires              := '0';
    core_busy_IE_wires                    := '0';
    IE_except_condition_wires       := '0';
    set_branch_condition_wires       := '0';
    set_wfi_condition_wires          := '0';    
    ie_taken_branch_wires               := '0';
    set_mret_condition_wires         := '0';
    jump_instr_wires                 := '0';
    branch_instr_wires               := '0';
    ebreak_instr_wires               := '0';
    dbg_ack_i_wires                  := '0';
--    data_valid_waiting_counter_wires := '0';
    WFI_Instr_wires                  := '0';
--    amo_store                        <= '0';
--    amo_load_lat                     <= '0';
--    nextstate_IE_wires               := sleep;
    reset_state                      <= '0';

    if rst_ni = '0' then
      if fetch_enable_i = '1' then
        null;
      else
        core_busy_IE_wires := '1';
      end if;
      nextstate_IE_wires := normal;  -- ignored, but allows combinational synthesis
    else

      case state_IE is                  -- stage status
        when sleep =>
          if dbg_req_o = '1' then
            dbg_ack_i_wires    := '1';
            core_busy_IE_wires      := '1';
            nextstate_IE_wires := sleep;
          elsif irq_i = '1' or fetch_enable_i = '1' then
            nextstate_IE_wires := normal;
          else
            core_busy_IE_wires      := '1';
            nextstate_IE_wires := sleep;
          end if;

        when reset =>
          reset_state <= '1';
          if dbg_req_o = '1' then
            dbg_ack_i_wires    := '1';
            core_busy_IE_wires      := '1';
            nextstate_IE_wires := reset;
          elsif fetch_enable_i = '0' then
            nextstate_IE_wires := reset;
            core_busy_IE_wires      := '1';
          else
            nextstate_IE_wires := normal;
          end if;

        when first_boot =>
          nextstate_IE_wires := normal;

        when debug =>
          dbg_ack_i_wires := '1';
          if dbg_req_o = '0' then
            nextstate_IE_wires := normal;
          else
            nextstate_IE_wires := debug;
            core_busy_IE_wires      := '1';
          end if;

        when normal =>
          -- in the 4 stage version we will have conditions on busy_WB 
          -- in all states of the IE stage, and similarly in the comb process, just
          -- like we did in the ID stage.
          if ie_instr_req = '0' or flush_cycle_count(harc_EXEC) /=0  then
            nextstate_IE_wires := normal; -- does nothing and wait
          elsif irq_pending(harc_EXEC)= '1' then
            -- manage irq as an absolute branch to MTVEC, also defining mepc value properly in program counter unit
            -- irq is served only if we are not in a delay slot for the interrupted harc
            -- for simplicity presently only harc 0 is interrupted (decided in program counter unit)
            -- the current valid instruction is discarded, only its pc value gets used for mepc
              nextstate_IE_wires         := normal;
              served_irq_wires(harc_EXEC) := '1';
              ie_taken_branch_wires     := '1';
              if decoded_instruction_IE(WFI_bit_position) = '1' then -- Inform the CSR unit that the last instruction before we went to the subroutine was a WFI instruction.
				WFI_Instr_wires		 := '1';
			  end if;
          else                         -- process the instruction
 
            -- EXECUTE OF INSTRUCTION ---------------------
 
            if decoded_instruction_IE(ADDI_bit_position) = '1' or decoded_instruction_IE(SLTI_bit_position) = '1'
              or decoded_instruction_IE(SLTIU_bit_position) = '1' or decoded_instruction_IE(ANDI_bit_position) = '1'
              or decoded_instruction_IE(ORI_bit_position) = '1' or decoded_instruction_IE(XORI_bit_position) = '1'
              or decoded_instruction_IE(SLLI_bit_position) = '1' or decoded_instruction_IE(SRLI7_bit_position) = '1'
              or decoded_instruction_IE(SRAI7_bit_position) = '1' then
              nextstate_IE_wires := normal;
            end if;

            if decoded_instruction_IE(LUI_bit_position) = '1' or decoded_instruction_IE(AUIPC_bit_position) = '1' then
              nextstate_IE_wires := normal;
            end if;

            if decoded_instruction_IE(ADD7_bit_position) = '1' or decoded_instruction_IE(SUB7_bit_position) = '1'
              or decoded_instruction_IE(SLT_bit_position) = '1' or decoded_instruction_IE(SLTU_bit_position) = '1'
              or decoded_instruction_IE(ANDD_bit_position) = '1' or decoded_instruction_IE(ORR_bit_position) = '1'
              or decoded_instruction_IE(XORR_bit_position) = '1' or decoded_instruction_IE(SLLL_bit_position) = '1'
              or decoded_instruction_IE(SRLL7_bit_position) = '1' or decoded_instruction_IE(SRAA7_bit_position) = '1' then
              nextstate_IE_wires := normal;
            end if;

            if decoded_instruction_IE(FENCE_bit_position) = '1' or decoded_instruction_IE(FENCEI_bit_position) = '1' then
              nextstate_IE_wires := normal;
            end if;

            if decoded_instruction_IE(JAL_bit_position) = '1' then  -- JAL instruction
              nextstate_IE_wires                   := normal;
              jump_instr_wires                     := '1';
              set_branch_condition_wires           := '1';
              ie_taken_branch_wires                := '1';
              PC_offset_wires(harc_EXEC) := UJ_immediate(instr_word_IE);
            end if;

            if decoded_instruction_IE(JALR_bit_position) = '1' then  --JALR instruction
              nextstate_IE_wires         := normal;
              set_branch_condition_wires := '1';
              ie_taken_branch_wires      := '1';
              PC_offset_wires(harc_EXEC) := std_logic_vector(signed(RS1_Data_IE)
                                                                       + signed(I_immediate(instr_word_IE)))
                                                      and X"FFFFFFFE";  -- bitwise and to set '0' the LSB
              jump_instr_wires    := '1';
              absolute_jump_wires := '1';
            end if;

            if decoded_instruction_IE(BEQ_bit_position) = '1' then
              nextstate_IE_wires                   := normal;
              branch_instr_wires                   := '1';
              PC_offset_wires(harc_EXEC) := SB_immediate(instr_word_IE);
              if pass_BEQ_ID = '1' then
                set_branch_condition_wires := '1';
                ie_taken_branch_wires      := '1';
              end if;
            end if;

            if decoded_instruction_IE(BNE_bit_position) = '1' then
              nextstate_IE_wires                   := normal;
              branch_instr_wires                   := '1';
              PC_offset_wires(harc_EXEC) := SB_immediate(instr_word_IE);
              if pass_BNE_ID = '1' then
                set_branch_condition_wires := '1';
                ie_taken_branch_wires      := '1';
              end if;
            end if;

            if decoded_instruction_IE(BLT_bit_position) = '1' then
              nextstate_IE_wires                   := normal;
              branch_instr_wires                   := '1';
              PC_offset_wires(harc_EXEC) := SB_immediate(instr_word_IE);
              if pass_BLT_ID = '1' then
                set_branch_condition_wires := '1';
                ie_taken_branch_wires      := '1';
              end if;
            end if;

            if decoded_instruction_IE(BLTU_bit_position) = '1' then
              nextstate_IE_wires                   := normal;
              branch_instr_wires                   := '1';
              PC_offset_wires(harc_EXEC) := SB_immediate(instr_word_IE);
              if pass_BLTU_ID = '1' then
                set_branch_condition_wires := '1';
                ie_taken_branch_wires      := '1';
              end if;
            end if;

            if decoded_instruction_IE(BGE_bit_position) = '1' then
              nextstate_IE_wires                   := normal;
              branch_instr_wires                   := '1';
              PC_offset_wires(harc_EXEC) := SB_immediate(instr_word_IE);
              if pass_BGE_ID = '1' then
                set_branch_condition_wires := '1';
                ie_taken_branch_wires      := '1';
              end if;
            end if;

            if decoded_instruction_IE(BGEU_bit_position) = '1' then
              nextstate_IE_wires                   := normal;
              branch_instr_wires                   := '1';
              PC_offset_wires(harc_EXEC) := SB_immediate(instr_word_IE);
              if pass_BGEU_ID = '1' then
                set_branch_condition_wires := '1';
                ie_taken_branch_wires      := '1';
              end if;
            end if;

            if decoded_instruction_IE(SW_MIP_bit_position) = '1' then
                if sw_mip = '1' then
                  core_busy_IE_wires      := '1';
                  nextstate_IE_wires := csr_instr_wait_state;
              end if;
            end if;

            if decoded_instruction_IE(CSRRW_bit_position) = '1' or decoded_instruction_IE(CSRRWI_bit_position) = '1' then
              nextstate_IE_wires := csr_instr_wait_state;
              core_busy_IE_wires      := '1';
            end if;

            if decoded_instruction_IE(CSRRC_bit_position) = '1' or decoded_instruction_IE(CSRRCI_bit_position) = '1'
              or decoded_instruction_IE(CSRRS_bit_position) = '1' or decoded_instruction_IE(CSRRSI_bit_position) = '1' then
              nextstate_IE_wires := csr_instr_wait_state;
              core_busy_IE_wires      := '1';
            end if;

            if decoded_instruction_IE(ECALL_bit_position) = '1' then
              nextstate_IE_wires        := normal;  -- was except_wait_state;
              IE_except_condition_wires := '1';
              ie_taken_branch_wires     := '1';
            end if;

            if decoded_instruction_IE(EBREAK_bit_position) = '1' then
              ebreak_instr_wires := '1';
              nextstate_IE_wires := normal;
            end if;

            if decoded_instruction_IE(MRET_bit_position) = '1' then
              set_mret_condition_wires := '1';
              ie_taken_branch_wires    := '1';
              if fetch_enable_i = '0' then
                nextstate_IE_wires := sleep;
				core_busy_IE_wires      := '1';
              else
                nextstate_IE_wires := normal;
              end if;
            end if;

            if decoded_instruction_IE(WFI_bit_position) = '1' then
              if MSTATUS(harc_EXEC)(3) = '1' then
                set_wfi_condition_wires  := '1';
                ie_taken_branch_wires    := '1';
              end if;
              nextstate_IE_wires := normal;
            end if;

            if decoded_instruction_IE(ILL_bit_position) = '1' then  -- ILLEGAL_INSTRUCTION
              nextstate_IE_wires         := normal;
              IE_except_condition_wires := '1';
              ie_taken_branch_wires     := '1';
            end if;

            if decoded_instruction_IE(NOP_bit_position) = '1' then
              nextstate_IE_wires := normal;
            end if;

            if dbg_req_o = '1' then
              nextstate_IE_wires := debug;
              dbg_ack_i_wires    := '1';
              core_busy_IE_wires      := '1';
            end if;

          -- EXECUTE OF INSTRUCTION (END)
          end if;  -- instr_rvalid_IE values 

        when csr_instr_wait_state =>
          if csr_instr_done = '0' then
            nextstate_IE_wires := csr_instr_wait_state;
            core_busy_IE_wires      := '1';
          elsif (csr_instr_done = '1' and csr_access_denied_o = '1') then  -- ILLEGAL_INSTRUCTION
            nextstate_IE_wires         := normal;
            IE_except_condition_wires := '1';
            ie_taken_branch_wires     := '1';
          else
            nextstate_IE_wires := normal;
          end if;

      end case;  -- fsm_IE state cases
    end if;  -- refers to reset signal

    PC_offset                  <= PC_offset_wires;
    absolute_jump              <= absolute_jump_wires;
    core_busy_IE               <= core_busy_IE_wires;
    IE_except_condition        <= IE_except_condition_wires;
    set_branch_condition       <= set_branch_condition_wires;
    served_irq                 <= served_irq_wires;
    ie_taken_branch            <= ie_taken_branch_wires;
    set_mret_condition         <= set_mret_condition_wires;    
    set_wfi_condition          <= set_wfi_condition_wires;
    jump_instr                 <= jump_instr_wires;
    branch_instr               <= branch_instr_wires;
    ebreak_instr               <= ebreak_instr_wires;
    dbg_ack_i                  <= dbg_ack_i_wires;
    nextstate_IE               <= nextstate_IE_wires;
    WFI_Instr		           <= WFI_Instr_wires;
  end process;

  fsm_IE_state : process(clk_i, rst_ni) -- also implements the delay slot counters and some aux signals
  begin
    
    if rst_ni = '0' then
      branch_instr_lat <= '0'; 
      jump_instr_lat   <= '0';
      for h in harc_range loop
        flush_cycle_count(h) <= 0;
      end loop;
      state_IE         <= reset;
      
    elsif rising_edge(clk_i) then
      branch_instr_lat       <= branch_instr;
      jump_instr_lat         <= jump_instr;
      for h in harc_range loop
        if (dsp_taken_branch = '1' and harc_DSP = h) or (ie_taken_branch = '1' and harc_EXEC = h) then 
        flush_cycle_count(h) <= NOP_POOL_SIZE;
        elsif flush_cycle_count(h) /= 0 and core_busy_IE = '0' then
          flush_cycle_count(h) <= flush_cycle_count(h) - 1;
        end if;
      end loop;
      state_IE               <= nextstate_IE;

    end if;
  end process;
-------------------------------------------------------------------end of IE stage -----------------
----------------------------------------------------------------------------------------------------

end EXECUTE;
--------------------------------------------------------------------------------------------------
-- END of Processing-Pipeline architecture -------------------------------------------------------
--------------------------------------------------------------------------------------------------
