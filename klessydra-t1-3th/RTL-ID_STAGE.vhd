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
entity ID_STAGE is
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
    vec_read_rs2_ID            : out std_logic;
    vec_write_rd_ID            : out std_logic;
    vec_width_ID               : out std_logic_vector(1 downto 0);
    regfile                    : in regfile_replicated_array;
    -- clock, reset active low
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic
    );
end entity;  ------------------------------------------


-- Klessydra T03x (4 stages) pipeline implementation -----------------------
architecture DECODE of ID_STAGE is

  signal data_addr_internal_ID  : std_logic_vector(31 downto 0);
  signal ls_parallel_exec  : std_logic;
  signal dsp_parallel_exec : std_logic;

  -- instruction operands
  signal S_Imm_IE           : std_logic_vector(11 downto 0);  -- unused
  signal I_Imm_IE           : std_logic_vector(11 downto 0);  -- unused
  signal SB_Imm_IE          : std_logic_vector(11 downto 0);  -- unused
  signal CSR_ADDR_IE        : std_logic_vector(11 downto 0);  -- unused
  signal RS1_Addr_IE        : std_logic_vector(4 downto 0);   -- unused
  signal RS2_Addr_IE        : std_logic_vector(4 downto 0);   -- unused
  signal RD_Addr_IE         : std_logic_vector(4 downto 0);   -- unused

--------------------------------------------------------------------------------------------------
----------------------- ARCHITECTURE BEGIN -------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- Stage ID - (read operands)
-----------------------------------------------------------------------------------------------------
-- Does source operand decoding and reading + operation decoding
-- This pipeline stage always takes one cycle latency
-----------------------------------------------------------------------------------------------------
begin
  fsm_ID_sync : process(clk_i, rst_ni)  -- synch single state process

    variable OPCODE_wires  : std_logic_vector (6 downto 0);
    variable FUNCT3_wires  : std_logic_vector (2 downto 0);
    variable FUNCT7_wires  : std_logic_vector (6 downto 0);
    variable FUNCT12_wires : std_logic_vector (11 downto 0);

  begin

    OPCODE_wires  := OPCODE(instr_word_ID_lat);
    FUNCT3_wires  := FUNCT3(instr_word_ID_lat);
    FUNCT7_wires  := FUNCT7(instr_word_ID_lat);
    FUNCT12_wires := FUNCT12(instr_word_ID_lat);
		
    if rst_ni = '0' then
      pc_IE <= (others => '0');
      harc_EXEC     <= 0;
      instr_rvalid_IE <= '0';
	  ie_instr_req  <= '0';
	  ls_instr_req  <= '0';
	  dsp_instr_req <= '0';
    elsif rising_edge(clk_i) then
      if core_busy_IE = '1' or core_busy_LS = '1' or ls_parallel_exec = '0' or dsp_parallel_exec = '0' then
        null;  -- do nothing and wait for the stall to finish; don't touch instr_rvalid_IE
      elsif instr_rvalid_ID = '0' then
        instr_rvalid_IE <= '0';         -- wait for a valid instruction
      else                              -- propagate the instruction
        instr_rvalid_IE  <= '1';
        instr_word_IE    <= instr_word_ID_lat;
        -- pc propagation
        pc_IE            <= pc_ID_lat;
        -- harc propagation
        harc_EXEC             <= harc_ID_lat;
        RS1_Addr_IE           <= std_logic_vector(to_unsigned(rs1(instr_word_ID_lat), 5));
        RS2_Addr_IE           <= std_logic_vector(to_unsigned(rs2(instr_word_ID_lat), 5));
        RD_Addr_IE            <= std_logic_vector(to_unsigned(rd(instr_word_ID_lat), 5));
        data_addr_internal_IE <= data_addr_internal_ID;
        --S_Imm_IE           <= std_logic_vector(to_unsigned(S_immediate(instr_word_ID_lat), 12));
        --I_Imm_IE           <= std_logic_vector(to_unsigned(to_integer(unsigned(I_immediate(instr_word_ID_lat))), 12));
        --SB_Imm_IE          <= std_logic_vector(to_unsigned(to_integer(unsigned(SB_immediate(instr_word_ID_lat))), 12));
        --CSR_ADDR_IE        <= std_logic_vector(to_unsigned(to_integer(unsigned(CSR_ADDR(instr_word_ID_lat))), 12));

        RS1_Data_IE <= regfile  (harc_ID_lat)(rs1(instr_word_ID_lat));
        RS2_Data_IE <= regfile  (harc_ID_lat)(rs2(instr_word_ID_lat));
        RD_Data_IE  <= regfile  (harc_ID_lat)(rd(instr_word_ID_lat));
      end if;  -- instr. conditions
      if core_busy_IE = '0' and core_busy_LS = '0' and ls_parallel_exec = '1' and dsp_parallel_exec = '1' and instr_rvalid_ID = '1' then
        -- process the instruction
        -- read data from the operand registers
        -- Decode Starts here
        pass_BEQ_ID      <= '0';
        pass_BNE_ID      <= '0';
        pass_BLT_ID      <= '0';
        pass_BLTU_ID     <= '0';
        pass_BGE_ID      <= '0';
        pass_BGEU_ID     <= '0';
	    ie_instr_req     <= '0';
	    ls_instr_req     <= '0';
	    dsp_instr_req    <= '0';
        amo_load_skip    <= '0';
        amo_load         <= '0';
        sw_mip           <= '0';
        vec_write_rd_ID  <= '0';
        vec_read_rs2_ID  <= '0';
        vec_width_ID     <= "00";


-------- LOGIC BELOW IS TO RELIEVE THE EXECUTE STAGE FROM ALL THE WORK AND BALANCE THE PIPELINES ------------------------------------------------------------------------
        if data_addr_internal_ID(31 downto 4) = x"0000FF0" then
          sw_mip <= '1';
        end if;
        if (signed(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))(31 downto 0)) = signed(regfile  (harc_ID_lat)(rs2(instr_word_ID_lat))(31 downto 0))) then
          pass_BEQ_ID <= '1';
        end if;
        if (signed(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))(31 downto 0)) /= signed(regfile  (harc_ID_lat)(rs2(instr_word_ID_lat))(31 downto 0))) then
          pass_BNE_ID <= '1';
        end if;
        if (signed(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))(31 downto 0)) < signed(regfile  (harc_ID_lat)(rs2(instr_word_ID_lat))(31 downto 0))) then
          pass_BLT_ID <= '1';
        end if;
        if (unsigned(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))(31 downto 0)) < unsigned(regfile  (harc_ID_lat)(rs2(instr_word_ID_lat))(31 downto 0))) then
          pass_BLTU_ID <= '1';
        end if;
        if (signed(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))(31 downto 0)) >= signed(regfile  (harc_ID_lat)(rs2(instr_word_ID_lat))(31 downto 0))) then
          pass_BGE_ID <= '1';
        end if;
        if (unsigned(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))(31 downto 0)) >= unsigned(regfile  (harc_ID_lat)(rs2(instr_word_ID_lat))(31 downto 0))) then
          pass_BGEU_ID <= '1';
        end if;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        case OPCODE_wires is
			
          when OP_IMM =>
            ie_instr_req <= '1';
            if(rd(instr_word_ID_lat) /= 0) then
              case FUNCT3_wires is
                when ADDI =>            -- ADDI instruction
                  decoded_instruction_IE <= ADDI_pattern;
                when SLTI =>            -- SLTI instruction
                  decoded_instruction_IE <= SLTI_pattern;
                when SLTIU =>           -- SLTIU instruction
                  decoded_instruction_IE <= SLTIU_pattern;
                when ANDI =>            -- ANDI instruction
                  decoded_instruction_IE <= ANDI_pattern;
                when ORI =>             -- ORI instruction
                  decoded_instruction_IE <= ORI_pattern;
                when XORI =>            -- XORI instruction
                  decoded_instruction_IE <= XORI_pattern;
                when SLLI =>            -- SLLI instruction
                  decoded_instruction_IE <= SLLI_pattern;
                when SRLI_SRAI =>
                  case FUNCT7_wires is
                    when SRLI7 =>       -- SRLI instruction
                      decoded_instruction_IE <= SRLI7_pattern;
                    when SRAI7 =>       -- SRAI instruction
                      decoded_instruction_IE <= SRAI7_pattern;
                    when others =>  -- ILLEGAL_INSTRUCTION                                      
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  -- FUNCT7_wires cases
                when others =>  -- ILLEGAL_INSTRUCTION                                  
                  decoded_instruction_IE <= ILL_pattern;
              end case;  -- FUNCT3_wires cases   
            else                -- R0_INSTRUCTION                             
              decoded_instruction_IE <= NOP_pattern;
            end if;  -- if rd(instr_word_ID_lat) /=0
				
          when LUI =>                   -- LUI instruction
			ie_instr_req <= '1';
            if (rd(instr_word_ID_lat) /= 0) then
              decoded_instruction_IE <= LUI_pattern;
            else                        -- R0_INSTRUCTION
              decoded_instruction_IE <= NOP_pattern;
            end if;
				
          when AUIPC =>                 -- AUIPC instruction
			ie_instr_req <= '1';
            if (rd(instr_word_ID_lat) /= 0) then
              decoded_instruction_IE <= AUIPC_pattern;
            else                        -- R0_INSTRUCTION
              decoded_instruction_IE <= NOP_pattern;
            end if;
				
          when OP =>
			ie_instr_req <= '1';
            if (rd(instr_word_ID_lat) /= 0) then
              case FUNCT3_wires is
                when ADD_SUB =>
                  case FUNCT7_wires is
                    when ADD7 =>        --ADD instruction
                      decoded_instruction_IE <= ADD7_pattern;
                    when SUB7 =>        -- SUB instruction    
                      decoded_instruction_IE <= SUB7_pattern;
                    when others =>      -- ILLEGAL_INSTRUCTION
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  -- FUNCT7_wires cases                                   
                when SLT =>             -- SLT instruction 
                  decoded_instruction_IE <= SLT_pattern;
                when SLTU =>            -- SLTU instruction
                  decoded_instruction_IE <= SLTU_pattern;
                when ANDD =>            -- AND instruction
                  decoded_instruction_IE <= ANDD_pattern;
                when ORR =>             -- OR instruction
                  decoded_instruction_IE <= ORR_pattern;
                when XORR =>            -- XOR instruction        
                  decoded_instruction_IE <= XORR_pattern;
                when SLLL =>            -- SLL instruction        
                  decoded_instruction_IE <= SLLL_pattern;
                when SRLL_SRAA =>
                  case FUNCT7_wires is
                    when SRLL7 =>       -- SRL instruction   
                      decoded_instruction_IE <= SRLL7_pattern;
                    when SRAA7 =>       -- SRA instruction
                      decoded_instruction_IE <= SRAA7_pattern;
                    when others =>  -- ILLEGAL_INSTRUCTION                                      
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  -- FUNCT7_wires cases
                when others =>  -- ILLEGAL_INSTRUCTION                                  
                  decoded_instruction_IE <= ILL_pattern;
              end case;  -- FUNCT3_wires cases
            else                        -- R0_INSTRUCTION
              decoded_instruction_IE <= NOP_pattern;
            end if;

          when JAL =>                   -- JAL instruction
            ie_instr_req <= '1';
            decoded_instruction_IE <= JAL_pattern;

          when JALR =>                  -- JAL instruction
            ie_instr_req <= '1';
            decoded_instruction_IE <= JALR_pattern;

          when BRANCH =>      -- BRANCH instruction         
			ie_instr_req <= '1';
            case FUNCT3_wires is
              when BEQ =>               -- BEQ instruction   
                decoded_instruction_IE <= BEQ_pattern;
              when BNE =>               -- BNE instruction
                decoded_instruction_IE <= BNE_pattern;
              when BLT =>               -- BLT instruction   
                decoded_instruction_IE <= BLT_pattern;
              when BLTU =>              -- BLTU instruction
                decoded_instruction_IE <= BLTU_pattern;
              when BGE =>               -- BGE instruction
                decoded_instruction_IE <= BGE_pattern;
              when BGEU =>              -- BGEU instruction
                decoded_instruction_IE <= BGEU_pattern;
              when others =>  -- ILLEGAL_INSTRUCTION                      
                decoded_instruction_IE <= ILL_pattern;
            end case;  -- FUNCT3_wires cases

          when LOAD =>                  -- LOAD instruction
            if (rd(instr_word_ID_lat) /= 0) then  -- is all in the next_state process
              case FUNCT3_wires is
                when LW =>
				  ls_instr_req <= '1';
				  data_be_ID <= "1111";
                  decoded_instruction_LS <= LW_pattern;
                when LH =>
				  ls_instr_req <= '1';
				  data_be_ID <= "0011";
                  decoded_instruction_LS <= LH_pattern;
                when LHU =>
				  ls_instr_req <= '1';
				  data_be_ID <= "0011";
                  decoded_instruction_LS <= LHU_pattern;
                when LB =>
				  ls_instr_req <= '1';
				   data_be_ID <= "0001";
                  decoded_instruction_LS <= LB_pattern;
                when LBU =>
				  ls_instr_req <= '1';
				   data_be_ID <= "0001";
                  decoded_instruction_LS <= LBU_pattern;
                when others =>          -- ILLEGAL_INSTRUCTION
				  ie_instr_req <= '1';
                  decoded_instruction_IE <= ILL_pattern;
              end case;
            else                        -- R0_INSTRUCTION
			  ie_instr_req <= '1';
              decoded_instruction_IE <= NOP_pattern;
            end if;

          when STORE =>                 -- STORE instruction
            case FUNCT3_wires is
              when SW =>                -- is all in the next_state process
				ls_instr_req <= '1';
				ie_instr_req <= '1';
				data_be_ID <= "1111";
                decoded_instruction_LS <= SW_pattern;
                decoded_instruction_IE <= SW_MIP_pattern;  --AAA
              when SH =>
				ls_instr_req <= '1';
				data_be_ID <= "0011";
                decoded_instruction_LS <= SH_pattern;
              when SB =>
				ls_instr_req <= '1';
				data_be_ID <= "0001";
                decoded_instruction_LS <= SB_pattern;
              when others =>  -- ILLEGAL_INSTRUCTION
				ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
            end case;

          when MISC_MEM =>
			ie_instr_req <= '1';
            case FUNCT3_wires is
              when FENCE =>             -- FENCE instruction
                decoded_instruction_IE <= FENCE_pattern;
              when FENCEI =>            -- FENCEI instruction
                decoded_instruction_IE <= FENCEI_pattern;
              when others =>            -- ILLEGAL_INSTRUCTION
                decoded_instruction_IE <= ILL_pattern;
            end case;  -- FUNCT3_wires cases

          when SYSTEM =>
            ie_instr_req <= '1';
            case FUNCT3_wires is
              when PRIV =>
                if (rs1(instr_word_ID_lat) = 0 and rd(instr_word_ID_lat) = 0) then
                  case FUNCT12_wires is
                    when ECALL =>       -- ECALL instruction
                      decoded_instruction_IE <= ECALL_pattern;
                    when EBREAK =>      -- EBREAK instruction       
                      decoded_instruction_IE <= EBREAK_pattern;
                    when mret =>        -- mret instruction   
                      decoded_instruction_IE <= MRET_pattern;
                    when WFI =>         -- WFI instruction     
                      decoded_instruction_IE <= WFI_pattern;
                    when others =>  -- ILLEGAL_INSTRUCTION                                              
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  -- FUNCT12_wires cases
                else  -- ILLEGAL_INSTRUCTION                            
                  decoded_instruction_IE <= ILL_pattern;
                end if;
              when CSRRW =>
                decoded_instruction_IE <= CSRRW_pattern;
              when CSRRS =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRS_pattern;
                else                    -- R0_INSTRUCTION
                  decoded_instruction_IE <= NOP_pattern;
                end if;
              when CSRRC =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRC_pattern;
                else                    -- R0_INSTRUCTION
                  decoded_instruction_IE <= NOP_pattern;
                end if;
              when CSRRWI =>
                decoded_instruction_IE <= CSRRWI_pattern;
              when CSRRSI =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRSI_pattern;
                else                    -- R0_INSTRUCTION
                  decoded_instruction_IE <= NOP_pattern; -- AAA highly likely not to be a NOP
                end if;
              when CSRRCI =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRCI_pattern;
                else                    -- R0_INSTRUCTION
                  decoded_instruction_IE <= NOP_pattern;
                end if;
              when others =>  -- ILLEGAL_INSTRUCTION                      
                decoded_instruction_IE <= ILL_pattern;
            end case;  -- FUNCT3_wires cases

          when AMO =>
            case FUNCT3_wires is
              when SINGLE =>
				ls_instr_req <= '1';
                decoded_instruction_LS <= AMOSWAP_pattern;
                if(rd(instr_word_ID_lat) /= 0) then
                  amo_load_skip          <= '0';
                  if amo_store = '1' then
                    amo_load <= '0';
                  elsif amo_store = '0' then
                    amo_load <= '1';
                  end if;
                elsif (rd(instr_word_ID_lat) = 0) then
                  amo_load_skip          <= '1';
                end if;
              when others =>            -- ILLEGAL_INSTRUCTION
                ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
            end case;

          when KMEM =>
            case FUNCT7_wires is
              when KMEMLD =>          -- KMEMLD_INSTRUCTION
			    ls_instr_req <= '1';
                decoded_instruction_LS <= KMEMLD_pattern;
			  when KMEMSTR =>
			    ls_instr_req <= '1';
                decoded_instruction_LS <= KMEMSTR_pattern;
              when others =>            -- ILLEGAL_INSTRUCTION
                ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
            end case;
				
          when KDSP =>
            case FUNCT7_wires is
              when KADDV =>           -- KADDV_INSTRUCTION
                dsp_instr_req <= '1';
                vec_write_rd_ID <= '1';
				vec_read_rs2_ID <= '1';
				case FUNCT3_wires is
                  when KADDV8 =>
                    vec_width_ID <= "00";
                    decoded_instruction_DSP <= KADDV8_pattern;
                  when KADDV16 =>
                    vec_width_ID <= "01";
                    decoded_instruction_DSP <= KADDV16_pattern;
                  when KADDV32 =>
                    vec_width_ID <= "10";
                    decoded_instruction_DSP <= KADDV32_pattern;
                  when others =>
                    decoded_instruction_IE <= ILL_pattern;
                end case;
              when KDOTP =>           -- KDOTP_INSTRUCTION
				vec_read_rs2_ID <= '1';
                dsp_instr_req <= '1';
				case FUNCT3_wires is
                  when KDOTP8 =>
                    vec_width_ID <= "00";
                    decoded_instruction_DSP <= KDOTP8_pattern;
                  when KDOTP16 =>
                    vec_width_ID <= "01";
                    decoded_instruction_DSP <= KDOTP16_pattern;
                  when KDOTP32 =>
                    vec_width_ID <= "10";
                    decoded_instruction_DSP <= KDOTP32_pattern;
                  when others =>
                    decoded_instruction_IE <= ILL_pattern;
                end case;
              when KSVMUL =>
                dsp_instr_req <= '1';
                vec_write_rd_ID <= '1';
				case FUNCT3_wires is
                  when KDOTP8 =>
                    vec_width_ID <= "00";
                    decoded_instruction_DSP <= KSVMUL8_pattern;
                  when KDOTP16 =>
                    vec_width_ID <= "01";
                    decoded_instruction_DSP <= KSVMUL16_pattern;
                  when KDOTP32 =>
                    vec_width_ID <= "10";
                    decoded_instruction_DSP <= KSVMUL32_pattern;
                  when others =>
                    decoded_instruction_IE <= ILL_pattern;
                end case;
              when others =>            -- ILLEGAL_INSTRUCTION
                ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
             end case;
				 
          when others =>                -- ILLEGAL_INSTRUCTION
			ie_instr_req <= '1';
            decoded_instruction_IE <= ILL_pattern;

        end case;  -- OPCODE_wires cases                           
        -- Decode OF INSTRUCTION (END) --------------------------

      end if;  -- instr. conditions
    end if;  -- clk
  end process;

  fsm_ID_comb : process(all)
  variable OPCODE_wires  : std_logic_vector (6 downto 0);
  begin
	OPCODE_wires  := OPCODE(instr_word_ID_lat);
		
    -- parallelism enablers, halts the pipeline when it is zero. -------------------
    ls_parallel_exec  <= '0' when (OPCODE_wires = LOAD or OPCODE_wires = STORE or OPCODE_wires = AMO or OPCODE_wires = KMEM) and busy_LS = '1' else '1';     
    dsp_parallel_exec <= '0' when (OPCODE_wires = KDSP or OPCODE_wires = KMEM) and busy_DSP = '1' else '1';
    --------------------------------------------------------------------------------

    if core_busy_IE = '1' or core_busy_LS = '1' or ls_parallel_exec = '0' or dsp_parallel_exec = '0' then
      busy_ID <= '1';  -- wait for the stall to finish, block new instructions 
    elsif core_busy_IE = '0' and core_busy_LS = '0' and ls_parallel_exec = '1' and dsp_parallel_exec = '1' then
      busy_ID <= '0';  -- wait for a valid instruction or process the instruction       
    end if;  
  end process;

  data_addr_internal_ID <= std_logic_vector(signed(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))) + signed(S_immediate(instr_word_ID_lat)));

---------------------------------------------------------------------- end of ID stage -------------
----------------------------------------------------------------------------------------------------
end DECODE;
--------------------------------------------------------------------------------------------------
-- END of Processing-Pipeline architecture -------------------------------------------------------
--------------------------------------------------------------------------------------------------
