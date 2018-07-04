library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;
entity ID_STAGE is
  port (
	
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
    pc_ID_lat                  : in std_logic_vector(31 downto 0);  
	core_busy_IE               : in std_logic;
	core_busy_LS               : in std_logic;
    busy_LS                    : in std_logic;
    busy_DSP                   : in std_logic;
    busy_ID                    : out std_logic;
    pc_IE                      : out std_logic_vector(31 downto 0);  
    instr_rvalid_ID            : in  std_logic; 
    instr_rvalid_IE            : out std_logic;  
	instr_word_ID_lat          : in std_logic_vector(31 downto 0); 
    sw_mip                     : out std_logic;
    harc_EXEC                  : out harc_range;
    data_addr_internal_IE      : out std_logic_vector(31 downto 0);
    regfile                    : in regfile_replicated_array;
    
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic
    );
end entity;  
architecture DECODE of ID_STAGE is
  signal data_addr_internal_ID  : std_logic_vector(31 downto 0);
  signal ls_parallel_exec  : std_logic;
  signal dsp_parallel_exec : std_logic;
  
  signal S_Imm_IE           : std_logic_vector(11 downto 0);  
  signal I_Imm_IE           : std_logic_vector(11 downto 0);  
  signal SB_Imm_IE          : std_logic_vector(11 downto 0);  
  signal CSR_ADDR_IE        : std_logic_vector(11 downto 0);  
  signal RS1_Addr_IE        : std_logic_vector(4 downto 0);   
  signal RS2_Addr_IE        : std_logic_vector(4 downto 0);   
  signal RD_Addr_IE         : std_logic_vector(4 downto 0);   
begin
  fsm_ID_sync : process(clk_i, rst_ni)  
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
        null;  
      elsif instr_rvalid_ID = '0' then
        instr_rvalid_IE <= '0';         
      else                              
        instr_rvalid_IE  <= '1';
        instr_word_IE    <= instr_word_ID_lat;
        
        pc_IE            <= pc_ID_lat;
        
        harc_EXEC             <= harc_ID_lat;
        RS1_Addr_IE           <= std_logic_vector(to_unsigned(rs1(instr_word_ID_lat), 5));
        RS2_Addr_IE           <= std_logic_vector(to_unsigned(rs2(instr_word_ID_lat), 5));
        RD_Addr_IE            <= std_logic_vector(to_unsigned(rd(instr_word_ID_lat), 5));
        data_addr_internal_IE <= data_addr_internal_ID;
        
        
        
        
        RS1_Data_IE <= regfile  (harc_ID_lat)(rs1(instr_word_ID_lat));
        RS2_Data_IE <= regfile  (harc_ID_lat)(rs2(instr_word_ID_lat));
        RD_Data_IE  <= regfile  (harc_ID_lat)(rd(instr_word_ID_lat));
      end if;  
      if core_busy_IE = '0' and core_busy_LS = '0' and ls_parallel_exec = '1' and dsp_parallel_exec = '1' and instr_rvalid_ID = '1' then
        
        
        
        pass_BEQ_ID   <= '0';
        pass_BNE_ID   <= '0';
        pass_BLT_ID   <= '0';
        pass_BLTU_ID  <= '0';
        pass_BGE_ID   <= '0';
        pass_BGEU_ID  <= '0';
	    ie_instr_req  <= '0';
	    ls_instr_req  <= '0';
	    dsp_instr_req <= '0';
        amo_load_skip <= '0';
        amo_load      <= '0';
        sw_mip        <= '0';
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
        case OPCODE_wires is
			
          when OP_IMM =>
            ie_instr_req <= '1';
            if(rd(instr_word_ID_lat) /= 0) then
              case FUNCT3_wires is
                when ADDI =>            
                  decoded_instruction_IE <= ADDI_pattern;
                when SLTI =>            
                  decoded_instruction_IE <= SLTI_pattern;
                when SLTIU =>           
                  decoded_instruction_IE <= SLTIU_pattern;
                when ANDI =>            
                  decoded_instruction_IE <= ANDI_pattern;
                when ORI =>             
                  decoded_instruction_IE <= ORI_pattern;
                when XORI =>            
                  decoded_instruction_IE <= XORI_pattern;
                when SLLI =>            
                  decoded_instruction_IE <= SLLI_pattern;
                when SRLI_SRAI =>
                  case FUNCT7_wires is
                    when SRLI7 =>       
                      decoded_instruction_IE <= SRLI7_pattern;
                    when SRAI7 =>       
                      decoded_instruction_IE <= SRAI7_pattern;
                    when others =>  
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  
                when others =>  
                  decoded_instruction_IE <= ILL_pattern;
              end case;  
            else                
              decoded_instruction_IE <= NOP_pattern;
            end if;  
				
          when LUI =>                   
			ie_instr_req <= '1';
            if (rd(instr_word_ID_lat) /= 0) then
              decoded_instruction_IE <= LUI_pattern;
            else                        
              decoded_instruction_IE <= NOP_pattern;
            end if;
				
          when AUIPC =>                 
			ie_instr_req <= '1';
            if (rd(instr_word_ID_lat) /= 0) then
              decoded_instruction_IE <= AUIPC_pattern;
            else                        
              decoded_instruction_IE <= NOP_pattern;
            end if;
				
          when OP =>
			ie_instr_req <= '1';
            if (rd(instr_word_ID_lat) /= 0) then
              case FUNCT3_wires is
                when ADD_SUB =>
                  case FUNCT7_wires is
                    when ADD7 =>        
                      decoded_instruction_IE <= ADD7_pattern;
                    when SUB7 =>        
                      decoded_instruction_IE <= SUB7_pattern;
                    when others =>      
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  
                when SLT =>             
                  decoded_instruction_IE <= SLT_pattern;
                when SLTU =>            
                  decoded_instruction_IE <= SLTU_pattern;
                when ANDD =>            
                  decoded_instruction_IE <= ANDD_pattern;
                when ORR =>             
                  decoded_instruction_IE <= ORR_pattern;
                when XORR =>            
                  decoded_instruction_IE <= XORR_pattern;
                when SLLL =>            
                  decoded_instruction_IE <= SLLL_pattern;
                when SRLL_SRAA =>
                  case FUNCT7_wires is
                    when SRLL7 =>       
                      decoded_instruction_IE <= SRLL7_pattern;
                    when SRAA7 =>       
                      decoded_instruction_IE <= SRAA7_pattern;
                    when others =>  
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  
                when others =>  
                  decoded_instruction_IE <= ILL_pattern;
              end case;  
            else                        
              decoded_instruction_IE <= NOP_pattern;
            end if;
          when JAL =>                   
            ie_instr_req <= '1';
            decoded_instruction_IE <= JAL_pattern;
          when JALR =>                  
            ie_instr_req <= '1';
            decoded_instruction_IE <= JALR_pattern;
          when BRANCH =>      
			ie_instr_req <= '1';
            case FUNCT3_wires is
              when BEQ =>               
                decoded_instruction_IE <= BEQ_pattern;
              when BNE =>               
                decoded_instruction_IE <= BNE_pattern;
              when BLT =>               
                decoded_instruction_IE <= BLT_pattern;
              when BLTU =>              
                decoded_instruction_IE <= BLTU_pattern;
              when BGE =>               
                decoded_instruction_IE <= BGE_pattern;
              when BGEU =>              
                decoded_instruction_IE <= BGEU_pattern;
              when others =>  
                decoded_instruction_IE <= ILL_pattern;
            end case;  
          when LOAD =>                  
            if (rd(instr_word_ID_lat) /= 0) then  
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
                when others =>          
				  ie_instr_req <= '1';
                  decoded_instruction_IE <= ILL_pattern;
              end case;
            else                        
			  ie_instr_req <= '1';
              decoded_instruction_IE <= NOP_pattern;
            end if;
          when STORE =>                 
            case FUNCT3_wires is
              when SW =>                
				ls_instr_req <= '1';
				data_be_ID <= "1111";
                decoded_instruction_LS <= SW_pattern;
                decoded_instruction_IE <= SW_MIP_pattern;  
              when SH =>
				ls_instr_req <= '1';
				data_be_ID <= "0011";
                decoded_instruction_LS <= SH_pattern;
              when SB =>
				ls_instr_req <= '1';
				data_be_ID <= "0001";
                decoded_instruction_LS <= SB_pattern;
              when others =>  
				ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
            end case;
          when MISC_MEM =>
			ie_instr_req <= '1';
            case FUNCT3_wires is
              when FENCE =>             
                decoded_instruction_IE <= FENCE_pattern;
              when FENCEI =>            
                decoded_instruction_IE <= FENCEI_pattern;
              when others =>            
                decoded_instruction_IE <= ILL_pattern;
            end case;  
          when SYSTEM =>
            ie_instr_req <= '1';
            case FUNCT3_wires is
              when PRIV =>
                if (rs1(instr_word_ID_lat) = 0 and rd(instr_word_ID_lat) = 0) then
                  case FUNCT12_wires is
                    when ECALL =>       
                      decoded_instruction_IE <= ECALL_pattern;
                    when EBREAK =>      
                      decoded_instruction_IE <= EBREAK_pattern;
                    when mret =>        
                      decoded_instruction_IE <= MRET_pattern;
                    when WFI =>         
                      decoded_instruction_IE <= WFI_pattern;
                    when others =>  
                      decoded_instruction_IE <= ILL_pattern;
                  end case;  
                else  
                  decoded_instruction_IE <= ILL_pattern;
                end if;
              when CSRRW =>
                decoded_instruction_IE <= CSRRW_pattern;
              when CSRRS =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRS_pattern;
                else                    
                  decoded_instruction_IE <= NOP_pattern;
                end if;
              when CSRRC =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRC_pattern;
                else                    
                  decoded_instruction_IE <= NOP_pattern;
                end if;
              when CSRRWI =>
                decoded_instruction_IE <= CSRRWI_pattern;
              when CSRRSI =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRSI_pattern;
                else                    
                  decoded_instruction_IE <= NOP_pattern;
                end if;
              when CSRRCI =>
                if(rd(instr_word_ID_lat) /= 0) then
                  decoded_instruction_IE <= CSRRCI_pattern;
                else                    
                  decoded_instruction_IE <= NOP_pattern;
                end if;
              when others =>  
                decoded_instruction_IE <= ILL_pattern;
            end case;  
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
              when others =>            
                ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
            end case;
          when KMEM =>
            case FUNCT7_wires is
              when KMEMLD =>          
			    ls_instr_req <= '1';
                decoded_instruction_LS <= KMEMLD_pattern;
			  when KMEMSTR =>
			    ls_instr_req <= '1';
                decoded_instruction_LS <= KMEMSTR_pattern;
              when others =>            
                ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
            end case;
				
          when KDSP =>
            case FUNCT7_wires is			
              when KADDV =>           
                dsp_instr_req <= '1';
                decoded_instruction_DSP <= KADDV_pattern;
              when KDOTP =>           
                dsp_instr_req <= '1';
                decoded_instruction_DSP <= KDOTP_pattern;
              when others =>            
                ie_instr_req <= '1';
                decoded_instruction_IE <= ILL_pattern;
             end case;
				 
          when others =>                
			ie_instr_req <= '1';
            decoded_instruction_IE <= ILL_pattern;
        end case;  
        
      end if;  
    end if;  
  end process;
  fsm_ID_comb : process(all)
  variable OPCODE_wires  : std_logic_vector (6 downto 0);
  begin
	OPCODE_wires  := OPCODE(instr_word_ID_lat);
		
    
    ls_parallel_exec  <= '0' when (OPCODE_wires = LOAD or OPCODE_wires = STORE or OPCODE_wires = AMO or OPCODE_wires = KMEM) and busy_LS = '1' else '1';     
    dsp_parallel_exec <= '0' when (OPCODE_wires = KDSP) and busy_DSP = '1' else '1';
    
    if core_busy_IE = '1' or core_busy_LS = '1' or ls_parallel_exec = '0' or dsp_parallel_exec = '0' then
      busy_ID <= '1';  
    elsif core_busy_IE = '0' and core_busy_LS = '0' and ls_parallel_exec = '1' and dsp_parallel_exec = '1' then
      busy_ID <= '0';  
    end if;  
  end process;
  data_addr_internal_ID <= std_logic_vector(signed(regfile  (harc_ID_lat)(rs1(instr_word_ID_lat))) + signed(S_immediate(instr_word_ID_lat)));
end DECODE;
