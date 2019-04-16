-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

-- local packages ------------
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

-- LD-STR pinout --------------------
entity Load_Store_Unit is
  port (
    -- clock, and reset active low
    clk_i, rst_ni              : in std_logic;
	-- Program Counter Signals
	irq_pending                : in replicated_bit;
    -- ID_Stage Signals
    RS1_Data_IE                : in  std_logic_vector(31 downto 0);
    RS2_Data_IE                : in  std_logic_vector(31 downto 0);
    RD_Data_IE                 : in  std_logic_vector(31 downto 0);
    instr_word_IE              : in  std_logic_vector(31 downto 0);
    pc_IE                      : in  std_logic_vector(31 downto 0);
    decoded_instruction_LS     : in  std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0);
    data_be_ID                 : in  std_logic_vector(3 downto 0);  -- AAA Check if needed
    harc_EXEC                  : in  harc_range;
    LS_instr_req               : in  std_logic;
    sw_mip                     : in  std_logic;
    core_busy_LS               : out std_logic;
    busy_LS                    : out std_logic;
    -- Processing Pipeline Signals
    rs1_to_sc                  : in  std_logic_vector(SPM_ADDR_WID-1 downto 0);
    rs2_to_sc                  : in  std_logic_vector(SPM_ADDR_WID-1 downto 0);
    rd_to_sc                   : in  std_logic_vector(SPM_ADDR_WID-1 downto 0);
    data_addr_internal         : out std_logic_vector(31 downto 0);
    ls_except_data             : out std_logic_vector(31 downto 0);
    pc_LS_except_value         : out replicated_32b_reg;
    ls_except_condition        : out std_logic;
    ls_taken_branch            : out std_logic;
    amo_load                   : in  std_logic;
    amo_load_skip              : in  std_logic;
    amo_store                  : out std_logic;
    -- CSR Signals
    misaligned_err             : out std_logic;
    -- Scratchpad Interface Signals
    ls_data_gnt_i              : in  std_logic_vector(SPM_NUM-1 downto 0);
    ls_sci_wr_gnt              : in  std_logic;
    ls_sc_data_read_wire       : in  std_logic_vector(Data_Width-1 downto 0);
    state_LS                   : out fsm_LS_states;
    ls_sci_req                 : out std_logic_vector(SPM_NUM-1 downto 0);
    ls_sci_we                  : out std_logic_vector(SPM_NUM-1 downto 0);
    ls_sc_read_addr            : out std_logic_vector(Addr_Width-(SIMD_BITS+3) downto 0);
    ls_sc_write_addr           : out std_logic_vector(Addr_Width-(SIMD_BITS+3)downto 0);
    ls_sc_data_write_wire      : out std_logic_vector(Data_Width-1 downto 0);
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
end entity;  ------------------------------------------

architecture LSU of Load_Store_Unit is
  
  signal nextstate_LS : fsm_LS_states;
  -- Memory fault signals
  signal decoded_instruction_LS_lat : std_logic_vector(LS_UNIT_INSTR_SET_SIZE-1 downto 0);
  signal data_addr_internal_lat     : std_logic_vector(31 downto 0);
  signal load_err                   : std_logic;
  signal store_err                  : std_logic;
  signal halt_lsu                   : std_logic;
  signal halt_lsu_lat               : std_logic;
  signal amo_store_lat              : std_logic;
  signal overflow_rs1_sc            : std_logic_vector(Addr_Width downto 0);
  signal overflow_rd_sc             : std_logic_vector(Addr_Width downto 0);
  signal busy_LS_lat                : std_logic;
  signal address_increment_enable   : std_logic_vector(SIMD_BITS-1 downto 0);
  signal sc_word_count              : std_logic_vector(Addr_Width-(SIMD_BITS+3) downto 0);
  signal sc_word_count_wire         : std_logic_vector(Addr_Width-(SIMD_BITS+3) downto 0);
  signal ls_rs1_to_sc               : std_logic_vector(SPM_ADDR_WID-1 downto 0);
  signal ls_rd_to_sc                : std_logic_vector(SPM_ADDR_WID-1 downto 0);
  signal ls_sc_data_write           : std_logic_vector(Data_Width-1 downto 0);
  signal data_be_internal           : std_logic_vector(3 downto 0);
  signal RS1_Data_IE_wire_lat       : std_logic_vector(31 downto 0);  -- Wire to used to directly send the result of the address increment
  signal RS1_Data_IE_lat            : std_logic_vector(31 downto 0);  -- Used to preserve the old data in case we start executing in parallel
  signal RS2_Data_IE_lat            : std_logic_vector(31 downto 0);  -- Used to preserve the old data in case we start executing in parallel
  signal RD_Data_IE_lat             : std_logic_vector(31 downto 0);  -- Used to preserve the old data in case we start executing in parallel
  
begin

  -- Memory fault signals
  load_err  <= data_gnt_i and data_err_i and not(data_we_o);
  store_err <= data_gnt_i and data_err_i and data_we_o;

  -- Memory address signal
  data_addr_o <= data_addr_internal(31 downto 2) & "00";
  data_be_o <= to_stdlogicvector(to_bitvector(data_be_internal) sll
                                 to_integer(unsigned(data_addr_internal(1 downto 0))));

  Ld_Str_sync : process(clk_i, rst_ni)
  begin
	  
    if rst_ni = '0' then
	  amo_store  <= '0';
	  amo_store_lat  <= '0';
	  LS_WB_EN <= '0';
	  busy_LS_lat <= '0';
	  LS_WB    <= (others => '0');
      address_increment_enable   <= (others => '0');
      ls_rs1_to_sc               <= (others => '0');
      ls_rd_to_sc                <= (others => '0');
      decoded_instruction_LS_lat <= (others => '0');
      misaligned_err <= '0';
     
	elsif rising_edge(clk_i) then
	  amo_store  <= '0';
      misaligned_err <= '0';
	  LS_WB    <= (others => '0');
      if irq_pending(harc_EXEC) = '1' then
        null;
      elsif ls_instr_req = '0' and busy_LS = '0' and busy_LS_lat = '0' then
	    LS_WB_EN <= '0';
	  elsif LS_instr_req = '1' or busy_LS = '1' or busy_LS_lat = '1' then
		instr_word_LS_WB <= instr_word_IE;
		harc_LS_WB <= harc_EXEC;
        if data_rvalid_i = '1' then
          ls_sc_data_write <= data_rdata_i;
        end if;
	    LS_WB_EN <= '0';
        busy_LS_lat <= '0';
        case state_LS is	
          when normal =>
            decoded_instruction_LS_lat <= decoded_instruction_LS;
            if decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and amo_store = '0' and amo_load_skip = '0') or
			   decoded_instruction_LS(LH_bit_position) = '1' or decoded_instruction_LS(LHU_bit_position) = '1' or 
			   decoded_instruction_LS(LB_bit_position) = '1' or decoded_instruction_LS(LBU_bit_position) = '1' then  -- Load Instructions
		      if ((data_addr_internal(1 downto 0) = "00" and (decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1'))) or 
               (data_addr_internal(0) = '0' and (decoded_instruction_LS(LH_bit_position) = '1' or decoded_instruction_LS(LHU_bit_position) = '1')) or                
               (decoded_instruction_LS(LB_bit_position) = '1' or decoded_instruction_LS(LBU_bit_position) = '1')) then
                if load_err = '1' then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data <= LOAD_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data <= LOAD_MISALIGNED_EXCEPT_CODE;
                misaligned_err <= '1';
              end if;
            end if;

            if decoded_instruction_LS(SW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store = '1' or amo_load_skip = '1')) then	
              if data_addr_internal(1 downto 0) = "00" then
				RS2_Data_IE_lat <= RS2_Data_IE;	
                if (store_err = '1') then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data <= STORE_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data <= STORE_MISALIGNED_EXCEPT_CODE;
                misaligned_err <= '1';
              end if;
            end if;
	
            if decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store = '1' or amo_load_skip = '1') then
              amo_store_lat <= amo_store;
			  amo_store <= '0';
            end if;

            if decoded_instruction_LS(SH_bit_position) = '1' then					
              if data_addr_internal(0) = '0' then
				RS2_Data_IE_lat <= RS2_Data_IE;	
                if (store_err = '1') then
                  pc_LS_except_value(harc_EXEC) <= pc_IE;
                  ls_except_data <= STORE_ERROR_EXCEPT_CODE;
                end if;
              else
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data <= STORE_MISALIGNED_EXCEPT_CODE;
                misaligned_err <= '1';
              end if;
            end if;
				
            if decoded_instruction_LS(SB_bit_position) = '1'then		
              RS2_Data_IE_lat <= RS2_Data_IE;	
              if (store_err = '1') then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data <= STORE_ERROR_EXCEPT_CODE;
              end if;
            end if;

            if decoded_instruction_LS(KMEMLD_bit_position) = '1' then
			  -- Illegal byte transfer handler, and illegal writeback address handler
              if RS2_Data_IE(Addr_Width downto 0) = (0 to Addr_Width => '0') then
                null;
		      elsif rd_to_sc = "100" then                               --  Not a scratchpad destination address
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
		      elsif RS1_Data_IE(1 downto 0) /= "00" then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= LOAD_MISALIGNED_EXCEPT_CODE;
                misaligned_err              <= '1';
			  elsif load_err = '1' then  -- AAA move to data_valid_waiting stage
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data                <= LOAD_ERROR_EXCEPT_CODE;
              elsif overflow_rd_sc(Addr_Width) = '1' then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data                <= SCRATCHPAD_OVERFLOW_EXCEPT_CODE;
			  else
                  decoded_instruction_LS_lat <= decoded_instruction_LS;
                  RS1_Data_IE_lat <= RS1_Data_IE;
                  RS2_Data_IE_lat <= RS2_Data_IE;
				  RD_Data_IE_lat  <= RD_Data_IE;
                  sc_word_count   <= (others => '0');
				  address_increment_enable <= (others => '0');
				  ls_rd_to_sc <= rd_to_sc;
			  end if;
            end if;

            if decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
			  -- Illegal byte transfer handler, and illegal writeback address handler
              if RS2_Data_IE(Addr_Width downto 0) = (0 to Addr_Width => '0') then
                null;
		      elsif rs1_to_sc = "100" then                              --  Not a scratchpad source address
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
		      elsif RD_Data_IE(1 downto 0) /= "00" then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data              <= STORE_MISALIGNED_EXCEPT_CODE;
                misaligned_err              <= '1';  
              elsif store_err = '1' then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data                <= STORE_ERROR_EXCEPT_CODE;
              elsif overflow_rs1_sc(Addr_Width) = '1' then
                pc_LS_except_value(harc_EXEC) <= pc_IE;
                ls_except_data                <= SCRATCHPAD_OVERFLOW_EXCEPT_CODE;				
			  else
                decoded_instruction_LS_lat <= decoded_instruction_LS;
                RS1_Data_IE_lat <= RS1_Data_IE;
                RS2_Data_IE_lat <= RS2_Data_IE;
                RD_Data_IE_lat <= RD_Data_IE;
                sc_word_count <= (others => '0');
                address_increment_enable <= (others => '0');
                ls_rs1_to_sc <= rs1_to_sc;
              end if;
            end if;
			  
          when data_valid_waiting =>
		  
            if decoded_instruction_LS_lat(KMEMLD_bit_position) = '1' or decoded_instruction_LS_lat(KMEMSTR_bit_position) = '1' then
              if RS2_Data_IE_lat(Addr_Width downto 0) >= (0 to Addr_Width => '0') then
                busy_LS_lat <= busy_LS;
                if RS2_Data_IE_lat(Addr_Width downto 0) >= (4 to Addr_Width => '0') & x"4" then
                  if data_rvalid_i = '1' then
                    if decoded_instruction_LS_lat(KMEMLD_bit_position) = '1'  then
                      RS1_Data_IE_lat <= RS1_Data_IE_wire_lat; -- increment address of data_mem, for KMEMLD
                      RS2_Data_IE_lat <= std_logic_vector(unsigned(RS2_Data_IE_lat) - "100"); -- decrement the number of bytes left to load
                    elsif decoded_instruction_LS_lat(KMEMSTR_bit_position) = '1' then
                      RS2_Data_IE_lat <= std_logic_vector(unsigned(RS2_Data_IE_lat) - "100");   -- decrement the number of bytes left to load
                      RD_Data_IE_lat  <= std_logic_vector(unsigned(RD_Data_IE_lat)  + "100");   -- increment address of  data_mem, for KMEMSTR
                    end if;
                  end if;
                elsif RS2_Data_IE_lat(Addr_Width downto 0) < (4 to Addr_Width => '0') & x"4" then
                  if data_rvalid_i = '1' and decoded_instruction_LS_lat(KMEMLD_bit_position) = '1'  then -- AAA fix by doing combinational addition, it will make the latency less by one cycle
                    RS2_Data_IE_lat(2 downto 0) <= (others => '0');
                  elsif  data_rvalid_i = '1' and decoded_instruction_LS_lat(KMEMSTR_bit_position) = '1' then
                    RS2_Data_IE_lat(2 downto 0) <= (others => '0');
                  end if;
                end if;
                  -- Increments the address of the SC memory every four words for KMEMLD
                if data_rvalid_i = '1' and decoded_instruction_LS_lat(KMEMLD_bit_position) = '1'  then
                  if to_integer(unsigned(address_increment_enable)) < SIMD-1 then
                    address_increment_enable <= std_logic_vector(unsigned(address_increment_enable) + '1');
                  elsif to_integer(unsigned(address_increment_enable)) = SIMD-1 then
                    address_increment_enable <= (others => '0');
                    sc_word_count <= std_logic_vector(unsigned(sc_word_count) + "1"); -- when all the banks on the same line have been written, we increment the address
                  end if;
                end if;
                -- Increments the address of the SC memory every four words for KMEMSTR
                if ls_sci_req(to_integer(unsigned(ls_rs1_to_sc))) = '1' and decoded_instruction_LS_lat(KMEMSTR_bit_position) = '1' then
                  if to_integer(unsigned(address_increment_enable)) < SIMD-1 then
                    address_increment_enable <= std_logic_vector(unsigned(address_increment_enable) + '1');
                  elsif to_integer(unsigned(address_increment_enable)) = SIMD-1 then
                    address_increment_enable <= (others => '0');
                    sc_word_count <= sc_word_count_wire; -- when all the banks on the same line have been written, we increment the address
                  end if;
                end if;
              end if;
            end if;
				  
		    if decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store_lat = '1' or amo_load_skip = '1') then
			  if data_rvalid_i = '1' then
		        amo_store_lat <= '0';
              end if;
	        end if;		

            if decoded_instruction_LS(LW_bit_position) = '1'  or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and amo_store_lat = '0' and amo_load_skip = '0') then
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
                      LS_WB <= std_logic_vector(resize(unsigned(data_rdata_i(23 downto 16)), 32));
				    end if;
                  when "11" =>
				    if decoded_instruction_LS(LB_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(signed(data_rdata_i(31 downto 24)), 32));
				    elsif decoded_instruction_LS(LBU_bit_position) = '1' then
                      LS_WB <= std_logic_vector(resize(unsigned(data_rdata_i(31 downto 24)), 32));
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
    data_addr_internal_wires         := std_logic_vector(signed(RS1_Data_IE));  -- The reset value was non-zero in order to keep the switching activity minimal
    data_be_internal_wires           := (others => '0');
    ls_sc_data_write_wire            <= ls_sc_data_write;
    overflow_rs1_sc                  <= (others => '0');
    overflow_rd_sc                   <= (others => '0');
    ls_sc_write_addr                 <= (others => '0');
	ls_sc_read_addr                  <= (others => '0');
    sc_word_count_wire               <= sc_word_count;
    RS1_Data_IE_wire_lat             <= RS1_Data_IE_lat;
    data_wdata_o_wires               := (others => '0');
    nextstate_LS                     <= normal;
    data_we_o_wires                  := '0';
    data_req_o_wires                 := '0';
	ls_except_condition_wires        := '0';
	ls_taken_branch_wires            := '0';
    core_busy_LS_wires               := '0';
    busy_LS_wires                    := '0';
    halt_lsu                         <= '0';
    ls_sci_req <= (others => '0');
    ls_sci_we  <= (others => '0');
    if irq_pending(harc_EXEC) = '1' then
    elsif LS_instr_req = '1' or busy_LS = '1' or busy_LS_lat = '1' then
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
            if ((data_addr_internal_wires(1 downto 0) = "00" and (decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1'))) or 
               (data_addr_internal_wires(0) = '0' and (decoded_instruction_LS(LH_bit_position) = '1' or decoded_instruction_LS(LHU_bit_position) = '1')) or                
               (decoded_instruction_LS(LB_bit_position) = '1' or decoded_instruction_LS(LBU_bit_position) = '1')) then
              core_busy_LS_wires := '1';
              data_be_internal_wires := data_be_ID;
              data_req_o_wires       := '1';
              if load_err = '1' then
                ls_except_condition_wires := '1';
                ls_taken_branch_wires     := '1';
              else
                nextstate_LS <= data_valid_waiting;
              end if;
            else
              ls_except_condition_wires := '1';
              ls_taken_branch_wires     := '1';
            end if;
          end if;

          if (decoded_instruction_LS(SW_bit_position) = '1' and sw_mip = '0') or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store = '1' or amo_load_skip = '1')) then
            if amo_store = '0' and amo_load_skip = '0'  then
              busy_LS_wires          := '1';
              data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE) + signed(S_immediate(instr_word_IE)));
            elsif amo_store = '1' or amo_load_skip = '1' then
              core_busy_LS_wires := '1';
              data_addr_internal_wires := std_logic_vector(signed(RS1_Data_IE));
            end if;
            data_we_o_wires        := '1';  -- is a writing
            if data_addr_internal_wires(1 downto 0) = "00" then
              data_req_o_wires   := '1';
              data_be_internal_wires := data_be_ID;  --AAA change back to "1111"
              data_wdata_o_wires := RS2_Data_IE;		
              if store_err = '1' then
                ls_except_condition_wires  := '1';
                ls_taken_branch_wires      := '1';
              else
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
              else
                nextstate_LS <= data_valid_waiting;
              end if;
            else
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            end if;
            case data_addr_internal_wires(1 downto 0) is
              when "00" =>
                data_wdata_o_wires := RS2_Data_IE(31 downto 0);
                data_we_o_wires        := '1';  -- is a writing
                data_be_internal_wires := data_be_ID;
              when "10" =>
                data_wdata_o_wires := RS2_Data_IE(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                data_we_o_wires        := '1';  -- is a writing
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
            else
              nextstate_LS <= data_valid_waiting;
            end if;
            case data_addr_internal_wires(1 downto 0) is
              when "00" =>
                data_wdata_o_wires := RS2_Data_IE(31 downto 0);
                data_we_o_wires        := '1';  -- is a writing
                data_be_internal_wires := data_be_ID;
              when "01" =>
                data_wdata_o_wires := RS2_Data_IE(23 downto 0) & std_logic_vector(to_unsigned(0, 8));
                data_we_o_wires        := '1';  -- is a writing
                data_be_internal_wires := data_be_ID;
              when "10" =>
                data_wdata_o_wires := RS2_Data_IE(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                data_we_o_wires        := '1';  -- is a writing
                data_be_internal_wires := data_be_ID;
              when "11" =>
                data_wdata_o_wires := RS2_Data_IE(7 downto 0) & std_logic_vector(to_unsigned(0, 24));
                data_we_o_wires        := '1';  -- is a writing
                data_be_internal_wires := data_be_ID;
              when others =>
                null;
            end case;
          end if;

          if decoded_instruction_LS(KMEMLD_bit_position) = '1' then
            -- RS2_Data_IE(Addr_Width downto 0) instead of RS2_Data_IE(Addr_Width -1 downto 0) in order to allow reading sizes = MAX_SC_SIZE and not MAX_SC_SIZE - 1 
            overflow_rd_sc <= std_logic_vector('0' & unsigned(RD_Data_IE(Addr_Width -1 downto 0)) + unsigned(RS2_Data_IE(Addr_Width downto 0)) -1); -- If storing data to SC overflows it's address space
            if RS2_Data_IE(Addr_Width downto 0) = (0 to Addr_Width => '0') then
              null;
            elsif rd_to_sc = "100" then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            elsif(RS1_Data_IE(1 downto 0) /= "00") then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            elsif load_err = '1' then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            elsif overflow_rd_sc(Addr_Width) = '1' then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            else
              nextstate_LS    <= data_valid_waiting;
              busy_LS_wires   := '1';
              --core_busy_LS_wires := '1';
            end if;
          end if;

          if decoded_instruction_LS(KMEMSTR_bit_position) = '1' then
            -- RS2_Data_IE(Addr_Width downto 0) instead of RS2_Data_IE(Addr_Width -1 downto 0) in order to allow reading sizes = MAX_SC_SIZE and not MAX_SC_SIZE - 1 
            overflow_rs1_sc <= std_logic_vector('0' & unsigned(RS1_Data_IE(Addr_Width -1 downto 0)) + unsigned(RS2_Data_IE(Addr_Width downto 0)) -1); -- If loading data from SC overflows it's address space
            if RS2_Data_IE(Addr_Width downto 0) = (0 to Addr_Width => '0') then
              null;
            elsif rs1_to_sc = "100" then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            elsif(RD_Data_IE(1 downto 0) /= "00") then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
              busy_LS_wires              := '1'; -- AAA check why this is here
            elsif store_err = '1' then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            elsif overflow_rs1_sc(Addr_Width) = '1' then
              ls_except_condition_wires  := '1';
              ls_taken_branch_wires      := '1';
            else
              nextstate_LS    <= data_valid_waiting;
              busy_LS_wires   := '1';
              --core_busy_LS_wires := '1';
              ls_sci_req(to_integer(unsigned(rs1_to_sc))) <= '1';
              ls_sc_read_addr <= RS1_Data_IE(Addr_Width - 1 downto SIMD_BITS+2);
            end if;
          end if;

        when data_valid_waiting =>  

          data_addr_internal_wires := data_addr_internal_lat;

          if ls_sci_wr_gnt = '0' and ls_sci_we /=  (0 to SPM_NUM-1 => '0') then
            halt_lsu <= '1';
          end if;

          if decoded_instruction_LS_lat(KMEMLD_bit_position) = '1' then
            if data_rvalid_i = '1' then
               RS1_Data_IE_wire_lat <= std_logic_vector(unsigned(RS1_Data_IE_lat) + "100");
            end if;
            if RS2_Data_IE_lat(Addr_Width downto 0) /= (0 to Addr_Width => '0') then
              busy_LS_wires      := '1';
              --core_busy_LS_wires := '1';
              data_be_internal_wires     := "1111";
              data_req_o_wires           := '1';
              data_addr_internal_wires := RS1_Data_IE_wire_lat;
              nextstate_LS <= data_valid_waiting;
              ls_sci_we(to_integer(unsigned(ls_rd_to_sc))) <= '1';
              ls_sc_write_addr <= std_logic_vector(unsigned(RD_Data_IE_lat(Addr_Width - 1 downto SIMD_BITS+2)) + unsigned(sc_word_count));
              if data_rvalid_i = '1' then
                ls_sci_req(to_integer(unsigned(ls_rd_to_sc))) <= '1';
              end if;
              if data_rvalid_i = '1' then
                if RS2_Data_IE_lat(Addr_Width downto 0) >= (4 to Addr_Width => '0') & x"4" then
                  ls_sc_data_write_wire <= data_rdata_i;
                elsif RS2_Data_IE_lat(Addr_Width downto 0) < (4 to Addr_Width => '0') & x"4" then
                  ls_sc_data_write_wire(8*to_integer(unsigned(RS2_Data_IE_lat)) - 1 downto 0) <= data_rdata_i(8*to_integer(unsigned(RS2_Data_IE_lat)) - 1 downto 0);
                end if;
              end if;
            end if;

          elsif decoded_instruction_LS_lat(KMEMSTR_bit_position) = '1' then
            if to_integer(unsigned(address_increment_enable)) = SIMD-1 then
              sc_word_count_wire <= std_logic_vector(unsigned(sc_word_count) + '1');
            end if;
            if RS2_Data_IE_lat(Addr_Width downto 0) /= (0 to Addr_Width => '0') then
              busy_LS_wires      := '1';
              --core_busy_LS_wires := '1';
              nextstate_LS <= data_valid_waiting;
              if data_rvalid_i = '1' then
                ls_sci_req(to_integer(unsigned(ls_rs1_to_sc))) <= '1';
              end if;
              ls_sc_read_addr <= std_logic_vector(unsigned(RS1_Data_IE_lat(Addr_Width - 1 downto SIMD_BITS+2)) + unsigned(sc_word_count_wire));
              if to_integer(unsigned(ls_data_gnt_i)) /= 0 then
                data_be_internal_wires     := "1111";
                data_req_o_wires           := '1';
                data_we_o_wires            := '1';
                data_addr_internal_wires := RD_Data_IE_lat;
                data_wdata_o_wires := ls_sc_data_read_wire;
              end if;
            end if;
	  
          elsif data_rvalid_i = '1' then
            if decoded_instruction_LS(SW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and (amo_store_lat = '1' or amo_load_skip = '1')) then -- SW or AMOSWAP data writing
              data_wdata_o_wires     := RS2_Data_IE_lat(31 downto 0);
              data_we_o_wires        := '1';  -- is a writing
              data_be_internal_wires := data_be_ID;
            elsif decoded_instruction_LS(SH_bit_position) = '1' then  -- SH data writing
              case data_addr_internal_wires(1 downto 0) is
                when "00" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(31 downto 0);
                  data_we_o_wires        := '1';  -- is a writing
                  data_be_internal_wires := data_be_ID;
                when "10" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                  data_we_o_wires        := '1';  -- is a writing
                  data_be_internal_wires := data_be_ID;
                when others =>
                  null;
              end case;
            elsif decoded_instruction_LS(SB_bit_position) = '1' then  -- SB data writng
              case data_addr_internal_wires(1 downto 0) is
                when "00" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(31 downto 0);
                  data_we_o_wires        := '1';  -- is a writing
                  data_be_internal_wires := data_be_ID;
                when "01" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(23 downto 0) & std_logic_vector(to_unsigned(0, 8));
                  data_we_o_wires        := '1';  -- is a writing
                  data_be_internal_wires := data_be_ID;
                when "10" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
                  data_we_o_wires        := '1';  -- is a writing
                  data_be_internal_wires := data_be_ID;
                when "11" =>
                  data_wdata_o_wires := RS2_Data_IE_lat(7 downto 0) & std_logic_vector(to_unsigned(0, 24));
                  data_we_o_wires        := '1';  -- is a writing
                  data_be_internal_wires := data_be_ID;
                when others =>
                  null;
              end case;
            end if;
		
             if decoded_instruction_LS(LW_bit_position) = '1' or (decoded_instruction_LS(AMOSWAP_bit_position) = '1' and amo_store_lat = '0' and amo_load_skip = '0') or
                decoded_instruction_LS(LH_bit_position) = '1' or  decoded_instruction_LS(LHU_bit_position) = '1' or
		        decoded_instruction_LS(LB_bit_position) = '1' or  decoded_instruction_LS(LBU_bit_position) = '1' then
               data_be_internal_wires := data_be_ID;
             if decoded_instruction_LS(AMOSWAP_bit_position) = '1' then
                core_busy_LS_wires := '1';				  
		      end if;
	        end if;
          else
            nextstate_LS <= data_valid_waiting;
            core_busy_LS_wires := '1';
            busy_LS_wires := '1';
		  end if;

      end case;
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

  fsm_LS_state : process(clk_i, rst_ni) -- also implements some aux signals
  begin
    if rst_ni = '0' then
      state_LS <= normal;      
    elsif rising_edge(clk_i) then
      state_LS <= nextstate_LS;
	  data_addr_internal_lat  <= data_addr_internal;
	  halt_lsu_lat            <= halt_lsu;
    end if;
  end process;
end LSU;
--------------------------------------------------------------------------------------------------
-- END of DSP architecture -----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
