library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

entity Load_Store_Unit is
  port (
    clk_i, rst_ni              : in std_logic;
    RS1_Data_IE                : in std_logic_vector(31 downto 0);
    RS2_Data_IE                : in std_logic_vector(31 downto 0);
    RD_Data_IE                 : in std_logic_vector(31 downto 0);
    instr_word_IE              : in std_logic_vector(31 downto 0);
    pc_IE                      : in std_logic_vector(31 downto 0);
    decoded_instruction_LS     : in std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0);
    data_be_ID                 : in std_logic_vector(3 downto 0);
    harc_EXEC                  : in harc_range;
    LS_instr_req               : in std_logic;
    core_busy_LS               : out std_logic;
    busy_LS                    : out std_logic;
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
    misaligned_err             : out std_logic;
    sci_err                    : in std_logic;
    ls_data_gnt_i              : in std_logic_vector(Num_SCs-1 downto 0);
    ls_sc_data_read_wire       : in std_logic_vector(31 downto 0);
    ls_sci_req                 : out std_logic_vector(Num_SCs-1 downto 0);
    ls_sci_we                  : out std_logic_vector(Num_SCs-1 downto 0);
    ls_sc_read_addr            : out std_logic_vector(Addr_Width -1 downto 0);
    ls_sc_write_addr           : out std_logic_vector(Addr_Width -1 downto 0);
    ls_sc_data_write_wire      : out std_logic_vector(31 downto 0);
    LS_WB_EN                   : out std_logic;
    harc_LS_WB                 : out harc_range;
    instr_word_LS_WB           : out std_logic_vector(31 downto 0);
    LS_WB                      : out std_logic_vector(31 downto 0);
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
end entity;

architecture LSU of Load_Store_Unit is
  
  type fsm_LS_states is (normal , data_valid_waiting);
  signal state_LS : fsm_LS_states;
  signal nextstate_LS : fsm_LS_states;
  signal load_err                 : std_logic;
  signal store_err                : std_logic;
  signal data_rvalid_i_lat        : std_logic;
  signal busy_ls_lat              : std_logic;
  signal address_increment_enable : std_logic_vector(1 downto 0);
  signal sc_word_count            : std_logic_vector(8 downto 0);
  signal ls_rs1_to_sc             : std_logic_vector(2 downto 0);
  signal ls_rd_to_sc              : std_logic_vector(2 downto 0);
  signal data_be_internal         : std_logic_vector(3 downto 0);
  signal RS1_Data_IE_lat          : std_logic_vector(31 downto 0);
  signal RS2_Data_IE_lat          : std_logic_vector(31 downto 0);
  signal RD_Data_IE_lat           : std_logic_vector(31 downto 0);
  signal ls_data_gnt_i_lat        : std_logic_vector(Num_SCs-1 downto 0);
  
begin

  load_err  <= data_gnt_i and data_err_i and not(data_we_o);
  store_err <= data_gnt_i and data_err_i and data_we_o;

  data_addr_o <= data_addr_internal(31 downto 2) & "00";
  data_be_o <= to_stdlogicvector(to_bitvector(data_be_internal) sll
                                 to_integer(unsigned(data_addr_internal(1 downto 0))));

  Ld_Str_sync : process(clk_i, rst_ni)
  begin
	  
    if rst_ni = '0' then
	  amo_store  <= '0';
	  LS_WB_EN <= '0';
	  busy_LS_lat <= '0';
	  LS_WB    <= (others => '0');
	  RS1_Data_IE_lat           <= (others => '0');
	  RS2_Data_IE_lat           <= (others => '0');
	  RD_Data_IE_lat            <= (others => '0');
      address_increment_enable  <= (others => '0');
      ls_data_gnt_i_lat         <= (others => '0');
      ls_rs1_to_sc              <= (others => '0');
      ls_rd_to_sc               <= (others => '0');
      misaligned_err <= '0';
     
	elsif rising_edge(clk_i) then
	  amo_store  <= '0';
	  LS_WB    <= (others => '0');
      misaligned_err <= '0';
      if ls_instr_req = '0' and busy_LS = '0' and busy_LS_lat = '0' then
	    LS_WB_EN <= '0';
	  elsif LS_instr_req = '1' or busy_LS = '1' or busy_LS_lat = '1' then
		  
		ls_data_gnt_i_lat <= ls_data_gnt_i;
		instr_word_LS_WB <= instr_word_IE;
		harc_LS_WB <= harc_EXEC;
	    LS_WB_EN <= '0';
        busy_LS_lat <= '0';

        case state_LS is	
          when normal =>
            if decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and amo_store = '0' and amo_load_skip = '0') or
			   decoded_instruction_LS(LH_bit_position) = '1' or decoded_instruction_LS(LHU_bit_position) = '1' or 
			   decoded_instruction_LS(LB_bit_position) = '1' or decoded_instruction_LS(LBU_bit_position) = '1' then
		      if ((data_addr_internal(1 downto 0) = "00" and (decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1'))) or 
               (data_addr_internal(0) /= '0' and (decoded_instruction_LS(LH_bit_position) = '1' or decoded_instruction_LS(LHU_bit_position) = '1')) or                
               (decoded_instruction_LS(LB_bit_position) = '1' or decoded_instruction_LS(LBU_bit_position) = '1')) then
                if load_err = '1' then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data              <= LOAD_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data                   <= LOAD_MISALIGNED_EXCEPT_CODE;
                misaligned_err                   <= '1';
              end if;
            end if;

            if decoded_instruction_LS(SW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store = '1' or amo_load_skip = '1')) then					
              if data_addr_internal(1 downto 0) = "00" then
				RS2_Data_IE_lat <= RS2_Data_IE;	
                if (store_err = '1') then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data              <= STORE_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= STORE_MISALIGNED_EXCEPT_CODE;
                misaligned_err              <= '1';
              end if;
            end if;
	
            if decoded_instruction_LS(SH_bit_position) = '1' then					
              if data_addr_internal(0) = '0' then
				RS2_Data_IE_lat <= RS2_Data_IE;	
                if (store_err = '1') then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data              <= STORE_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= STORE_MISALIGNED_EXCEPT_CODE;
                misaligned_err              <= '1';
              end if;
            end if;
				
            if decoded_instruction_LS(SB_bit_position) = '1'then		
              RS2_Data_IE_lat <= RS2_Data_IE;	
              if (store_err = '1') then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= STORE_ERROR_EXCEPT_CODE;
              end if;
            end if;

            if decoded_instruction_LS(KMEMLD_bit_position) = '1' then
              if to_integer(unsigned(RS2_Data_IE)) mod 4 = 0 then
				if rd_to_sc /= "100" then
                  RS1_Data_IE_lat <= RS1_Data_IE;
                  RS2_Data_IE_lat <= RS2_Data_IE;
				  RD_Data_IE_lat <= RD_Data_IE;
                  sc_word_count  <= "000000000";
				  address_increment_enable <= "00";
				  ls_rd_to_sc <= rd_to_sc;
				else 
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
			    end if;
			  else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= ILLEGAL_OPERAND_EXCEPT_CODE;
              end if;
			  
		      if data_addr_internal(1 downto 0) = "00" then
                if load_err = '1' then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data              <= LOAD_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= LOAD_MISALIGNED_EXCEPT_CODE;
                misaligned_err              <= '1';
              end if;
            end if;

            if decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
              if to_integer(unsigned(RS2_Data_IE)) mod 4 = 0 then
                if rs1_to_sc /= "100" then
                  RS1_Data_IE_lat <= RS1_Data_IE;
				  RS2_Data_IE_lat <= RS2_Data_IE;
				  RD_Data_IE_lat <= RD_Data_IE;
                  sc_word_count <= "000000000";
				  address_increment_enable <= "00";
				  ls_rs1_to_sc <= rs1_to_sc;
				else 
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
			    end if;
			  else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= ILLEGAL_OPERAND_EXCEPT_CODE;
              end if;
			  
		      if data_addr_internal(1 downto 0) = "00" then
                if load_err = '1' then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data              <= STORE_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= STORE_MISALIGNED_EXCEPT_CODE;
                misaligned_err              <= '1';
              end if;  
            end if;
			  
          when data_valid_waiting =>
		  
            if decoded_instruction_LS(KMEMLD_bit_position) = '1' or decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
              if sci_err = '1' then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= WRITE_ACCESS_EXCEPT_CODE;
			  else
                if RS2_Data_IE_lat(8 downto 0) /= "000000000" then
				  busy_LS_lat <= '1';
				  if data_rvalid_i = '1' then
                    RS2_Data_IE_lat <= std_logic_vector(unsigned(RS2_Data_IE_lat) - "100");
					if decoded_instruction_LS(KMEMLD_bit_position) = '1' then
                      RS1_Data_IE_lat <= std_logic_vector(unsigned(RS1_Data_IE_lat) + "100");
					elsif decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
                      RD_Data_IE_lat <= std_logic_vector(unsigned(RD_Data_IE_lat) + "100");
					end if;
				  end if;
				  if data_rvalid_i_lat = '1' and decoded_instruction_LS(KMEMLD_bit_position) = '1' then
				    if address_increment_enable /= "11" then
				      address_increment_enable <= std_logic_vector(unsigned(address_increment_enable) + '1');
				    elsif address_increment_enable = "11" then
                      address_increment_enable <= "00";
                      sc_word_count <= std_logic_vector(unsigned(sc_word_count) + "1");
				    end if;
				  end if;
				  if ls_data_gnt_i(to_integer(unsigned(ls_rs1_to_sc))) = '1' and decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
				    if address_increment_enable /= "11" then
				      address_increment_enable <= std_logic_vector(unsigned(address_increment_enable) + '1');
				    elsif address_increment_enable = "11" then
                      address_increment_enable <= "00";
                      sc_word_count <= std_logic_vector(unsigned(sc_word_count) + "1");
				    end if;
				  end if;
                end if;
              end if;
            end if;
				  
		    if decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store = '1' or amo_load_skip = '1') then
			  if data_rvalid_i = '1' then
		        amo_store <= '0';
              end if;
	        end if;		
				
            if decoded_instruction_LS(LW_bit_position) = '1'  or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and amo_store = '0' and amo_load_skip = '0') then
		      if data_rvalid_i = '1' then
		        LS_WB <= data_rdata_i;
	            LS_WB_EN <= '1';
				if decoded_instruction_LS(AMOSWAP_bit_position) = '1' then
			      amo_store <= '1';
				end if;
		      end if;
		    end if;
		  
		    if decoded_instruction_LS(LH_bit_position) = '1' or decoded_instruction_LS(LHU_bit_position) = '1' then 
              if data_rvalid_i = '1' then
                case data_addr_internal(1 downto 0) is
                  when "00" =>
                    LS_WB_EN <= '1';
				    if decoded_instruction_LS(LH_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(15 downto 0)), 32));
				    elsif decoded_instruction_LS(LHU_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(unsigned(data_rdata_i(15 downto 0)), 32));
				    end if;
                  when "01" =>
                    LS_WB_EN <= '1';
                    if decoded_instruction_LS(LH_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(23 downto 8)), 32));
		   		    elsif decoded_instruction_LS(LHU_bit_position) = '1' then
				      LS_WB <= std_logic_vector(resize(unsigned(data_rdata_i(23 downto 8)), 32));
				    end if;
                  when "10" =>
                    LS_WB_EN <= '1';
				    if decoded_instruction_LS(LH_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(31 downto 16)), 32));
				    elsif decoded_instruction_LS(LHU_bit_position) = '1' then
				      LS_WB <= std_logic_vector(resize(unsigned(data_rdata_i(31 downto 16)), 32));
				    end if;
                  when others =>
                    null;
                end case;
		      end if;
            end if;
			  
		    if decoded_instruction_LS(LB_bit_position) = '1' or decoded_instruction_LS(LBU_bit_position) = '1' then 
              if data_rvalid_i = '1' then		
			    LS_WB_EN <= '1';
	            case data_addr_internal(1 downto 0) is
                  when "00" =>
				    if decoded_instruction_LS(LB_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(7 downto 0)), 32));
				    elsif decoded_instruction_LS(LBU_bit_position) = '1' then
					  LS_WB <= std_logic_vector(resize(unsigned(data_rdata_i(7 downto 0)), 32));
				    end if;
                  when "01" =>
				    if decoded_instruction_LS(LB_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(15 downto 8)), 32));
				    elsif decoded_instruction_LS(LBU_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(unsigned(data_rdata_i(15 downto 8)), 32));					  
				    end if;
                  when "10" =>
				    if decoded_instruction_LS(LB_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(23 downto 16)), 32));
				    elsif decoded_instruction_LS(LBU_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(23 downto 16)), 32));
				    end if;
                  when "11" =>
				    if decoded_instruction_LS(LB_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(31 downto 24)), 32));
				    elsif decoded_instruction_LS(LBU_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(31 downto 24)), 32));
				    end if;
                  when others =>
                    null;               
                end case;
			  end if;
		    end if;
	    end case;
      end if;
    end if;
  end process;

  Ld_Str_comb : process(all)

  variable data_addr_internal_wires         : std_logic_vector (31 downto 0);
  variable data_wdata_o_wires               : std_logic_vector (31 downto 0);
  variable data_be_internal_wires           : std_logic_vector (3 downto 0);
  variable data_we_o_wires                  : std_logic;
  variable data_req_o_wires                 : std_logic;
  variable ls_except_condition_wires        : std_logic;
  variable ls_taken_branch_wires            : std_logic;
  variable core_busy_LS_wires               : std_logic;
  variable busy_LS_wires                    : std_logic;

  begin
	  
    data_be_internal_wires           := (others => '0');
    ls_sc_data_write_wire            <= (others => '0');
    data_we_o_wires                  := '0';
    data_req_o_wires                 := '0';
	ls_except_condition_wires        := '0';
	ls_taken_branch_wires            := '0';
    core_busy_LS_wires               := '0';
	ls_sc_read_addr <= (others => '0');
    ls_sci_req <= (others => '0');
    ls_sci_we  <= (others => '0');

	if rst_ni = '0' then
      data_addr_internal_wires         := (others => '0');
      data_wdata_o_wires               := (others => '0');
      busy_LS_wires                    := '0';
    else
	  if LS_instr_req = '1' or busy_LS = '1' or busy_LS_lat = '1' then
	  	case state_LS is
		  when normal =>

            if decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and amo_store = '0' and amo_load_skip = '0') or
		       decoded_instruction_LS(LH_bit_position) = '1' or  decoded_instruction_LS(LHU_bit_position) = '1' or
		       decoded_instruction_LS(LB_bit_position) = '1' or  decoded_instruction_LS(LBU_bit_position) = '1' then
              if amo_load = '0' then
                data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE) + signed(I_immediate(instr_word_IE)));
              elsif amo_load = '1' then
                data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE));
              end if;
			  core_busy_LS_wires := '1';
              if ((data_addr_internal_wires(1 downto 0) = "00" and (decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1'))) or 
                 (data_addr_internal_wires(0) /= '0' and (decoded_instruction_LS(LH_bit_position) = '1' or decoded_instruction_LS(LHU_bit_position) = '1')) or                
                 (decoded_instruction_LS(LB_bit_position) = '1' or decoded_instruction_LS(LBU_bit_position) = '1')) then
                data_be_internal_wires := data_be_ID;
                data_req_o_wires       := '1';
                if load_err = '1' then
                  ls_except_condition_wires := '1';
                  ls_taken_branch_wires     := '1';
                elsif data_gnt_i = '1' then
				  nextstate_LS <= data_valid_waiting;
                end if;
              else
                ls_except_condition_wires := '1';
                ls_taken_branch_wires     := '1';
              end if;
            end if;

            if decoded_instruction_LS(SW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store = '1' or amo_load_skip = '1')) then
              if amo_store = '0' and amo_load_skip = '0'  then
                data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE) + signed(S_immediate(instr_word_IE)));
              elsif amo_store = '1' or amo_load_skip = '1' then
                data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE));
              end if;
              busy_LS_wires          := '1';
              data_we_o_wires        := '1';
              if data_addr_internal_wires(1 downto 0) = "00" then
                data_req_o_wires   := '1';
                data_be_internal_wires := data_be_ID;
                data_wdata_o_wires := RS2_Data_IE;		
                if store_err = '1' then
                  ls_except_condition_wires  := '1';
                  ls_taken_branch_wires      := '1';
                elsif data_gnt_i = '1' then
                  nextstate_LS <= data_valid_waiting;
                end if;
              else
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
              end if;
            end if;

            if decoded_instruction_LS(SH_bit_position) then
              data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE) + signed(S_immediate(instr_word_IE)));
              busy_LS_wires      := '1';
              if data_addr_internal_wires(0) = '0' then
                data_req_o_wires   := '1';
                if store_err = '1' then
                  ls_except_condition_wires  := '1';
                  ls_taken_branch_wires      := '1';
                elsif data_gnt_i = '1' then
                  nextstate_LS <= data_valid_waiting;
                end if;
              else
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
              end if;
              case data_addr_internal_wires(1 downto 0) is
                when "00" =>
                  data_wdata_o_wires := RS2_Data_IE(31 downto 0);
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when "10" =>
                  data_wdata_o_wires := RS2_Data_IE(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when others =>
                  null;
              end case;
            end if;

            if decoded_instruction_LS(SB_bit_position) = '1'then
              data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE) + signed(S_immediate(instr_word_IE)));
              busy_LS_wires      := '1';
              data_req_o_wires   := '1';
              if store_err = '1' then
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
              elsif data_gnt_i = '1' then
                nextstate_LS <= data_valid_waiting;
              end if;
              case data_addr_internal_wires(1 downto 0) is
                when "00" =>
                  data_wdata_o_wires := RS2_Data_IE(31 downto 0);
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when "01" =>
                  data_wdata_o_wires := RS2_Data_IE(23 downto 0) & std_logic_vector(to_unsigned(0, 8));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when "10" =>
                  data_wdata_o_wires := RS2_Data_IE(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when "11" =>
                  data_wdata_o_wires := RS2_Data_IE(7 downto 0) & std_logic_vector(to_unsigned(0, 24));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when others =>
                  null;
              end case;
            end if;

	        if decoded_instruction_LS(KMEMLD_bit_position) = '1' then
              if to_integer(unsigned(RS2_Data_IE)) mod 4 /= 0 then
                nextstate_LS               <= normal;
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
              end if;

	  		  if rd_to_sc = "100" then
                nextstate_LS               <= normal;
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
              end if;
              if(data_addr_internal_wires(1 downto 0) = "00") then
                if load_err = '1' then
                  nextstate_LS               <= normal;
                  ls_except_condition_wires  := '1';
                  ls_taken_branch_wires      := '1';
                else
                  nextstate_LS    <= data_valid_waiting;
                  busy_LS_wires   := '1';
                end if;
              else
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
                busy_LS_wires              := '1';
              end if;
          end if;

		  if decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
            if to_integer(unsigned(RS2_Data_IE)) mod 4 /= 0 then
              nextstate_LS               <= normal;
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            end if;
				   
			if rs1_to_sc = "100" then
              nextstate_LS               <= normal;
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            end if;
            if(data_addr_internal_wires(1 downto 0) = "00") then
              if store_err = '1' then
                nextstate_LS               <= normal;
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
              else
                nextstate_LS    <= data_valid_waiting;
                busy_LS_wires   := '1';
              end if;
            else
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
              busy_LS_wires              := '1';
            end if;
          end if;

        when data_valid_waiting =>  
	      if data_rvalid_i = '1' then
			busy_LS_wires := '0';			  
            if decoded_instruction_LS(SW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store = '1' or amo_load_skip = '1')) then
		      data_wdata_o_wires := RS2_Data_IE_lat(31 downto 0);
              data_we_o_wires        := '1';
		      data_be_internal_wires := data_be_ID;
			  nextstate_LS <= normal;
            elsif decoded_instruction_LS(SH_bit_position) = '1' then
              case data_addr_internal_wires(1 downto 0) is
                when "00" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(31 downto 0);
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
			      nextstate_LS <= normal;
                when "10" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
			      nextstate_LS <= normal;
                when others =>
                  null;
              end case;
            elsif decoded_instruction_LS(SB_bit_position) = '1' then
			  nextstate_LS <= normal;
              case data_addr_internal_wires(1 downto 0) is
                when "00" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(31 downto 0);
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when "01" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(23 downto 0) & std_logic_vector(to_unsigned(0, 8));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when "10" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when "11" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(7 downto 0) & std_logic_vector(to_unsigned(0, 24));
                  data_we_o_wires        := '1';
		          data_be_internal_wires := data_be_ID;
                when others =>
                  null;
              end case;
            end if;
				
		    if decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and amo_store = '0' and amo_load_skip = '0') or
		      decoded_instruction_LS(LH_bit_position) = '1' or  decoded_instruction_LS(LHU_bit_position) = '1' or
		      decoded_instruction_LS(LB_bit_position) = '1' or  decoded_instruction_LS(LBU_bit_position) = '1' then
		      nextstate_LS <= normal;
			  data_be_internal_wires := data_be_ID;
		      if decoded_instruction_LS(AMOSWAP_bit_position) = '0' then
		      end if;
	        end if;
		  else 
            core_busy_LS_wires := '1';
            busy_LS_wires := '1';
		  end if;
			  
	      if decoded_instruction_LS(KMEMLD_bit_position) = '1' then
            if sci_err = '1' then
              nextstate_LS <= normal;
              ls_except_condition_wires := '1';
              ls_taken_branch_wires     := '1';    
              ls_sci_req(to_integer(unsigned(ls_rd_to_sc))) <= '0';   
            else
              if RS2_Data_IE_lat(8 downto 0) /= "000000000" then
				busy_LS_wires      := '1';
                data_be_internal_wires     := "1111";
                data_req_o_wires           := '1';
                data_addr_internal_wires := RS1_Data_IE_lat;
                nextstate_LS <= data_valid_waiting;
			    if data_rvalid_i_lat = '1' then
				  ls_sci_req(to_integer(unsigned(ls_rd_to_sc))) <= '1';
	              ls_sci_we(to_integer(unsigned(ls_rd_to_sc))) <= '1';
                  ls_sc_data_write_wire <= data_rdata_i;
				  ls_sc_write_addr <= std_logic_vector(unsigned(RD_Data_IE_lat(8 downto 0)) + unsigned(sc_word_count));
                end if;
              elsif RS2_Data_IE_lat(8 downto 0) = "000000000" then
				busy_LS_wires      := '0';
                ls_sc_data_write_wire <= data_rdata_i;
		        ls_sci_req(to_integer(unsigned(ls_rd_to_sc))) <= '1';
			    ls_sci_we(to_integer(unsigned(ls_rd_to_sc))) <= '1';
				ls_sc_write_addr <= std_logic_vector(unsigned(RD_Data_IE_lat(8 downto 0)) + unsigned(sc_word_count));
				nextstate_LS <= normal;   
              end if;
            end if;
          end if;

	      if decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
            if sci_err = '1' then
              nextstate_LS <= normal;
              ls_except_condition_wires := '1';
              ls_taken_branch_wires     := '1';    
              ls_sci_req(to_integer(unsigned(ls_rs1_to_sc))) <= '0';   
            else
              if RS2_Data_IE_lat(8 downto 0) /= "000000000" then
				busy_LS_wires      := '1';
                nextstate_LS <= data_valid_waiting;
				ls_sci_req(to_integer(unsigned(ls_rs1_to_sc))) <= '1';
                ls_sc_read_addr <= std_logic_vector(unsigned(RS1_Data_IE_lat(8 downto 0)) + unsigned(sc_word_count));
                if ls_data_gnt_i(to_integer(unsigned(ls_rs1_to_sc))) = '1' then
                  data_be_internal_wires     := "1111";
                  data_req_o_wires           := '1';
				  data_we_o_wires := '1';
                  data_addr_internal_wires := RD_Data_IE_lat;
                  data_wdata_o_wires := ls_sc_data_read_wire;
                end if;
              elsif RS2_Data_IE_lat(8 downto 0) = "000000000" then
				busy_LS_wires      := '0';
				nextstate_LS <= normal;   
              end if;
            end if;
          end if;
			  
        end case;
      end if;
    end if; 
	
    data_addr_internal         <= data_addr_internal_wires;
    data_wdata_o               <= data_wdata_o_wires;
    data_be_internal           <= data_be_internal_wires;
    data_we_o                  <= data_we_o_wires;
    data_req_o                 <= data_req_o_wires;
    ls_except_condition        <= ls_except_condition_wires;
    ls_taken_branch   	       <= ls_taken_branch_wires;
    core_busy_LS               <= core_busy_LS_wires;
    busy_LS                    <= busy_LS_wires;
  
  end process;

  fsm_LS_state : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      state_LS <= normal;      
	  data_rvalid_i_lat <= '0';
    elsif rising_edge(clk_i) then
      state_LS <= nextstate_LS;
	  data_rvalid_i_lat <= data_rvalid_i;
    end if;
  end process;
end LSU;
--------------------------------------------------------------------------------------------------
