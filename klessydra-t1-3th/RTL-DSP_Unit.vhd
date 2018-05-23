library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

entity DSP_Unit is
  port (
    clk_i, rst_ni              : in std_logic;
    rs1_to_sc                  : in  std_logic_vector(2 downto 0);
    rs2_to_sc                  : in  std_logic_vector(2 downto 0);
    rd_to_sc                   : in  std_logic_vector(2 downto 0);
    MVSIZE                     : in  replicated_32b_reg;
    dsp_except_data            : out std_logic_vector(31 downto 0);
	pc_DSP_except_value        : out replicated_32b_reg;
	dsp_taken_branch           : out std_logic;
	dsp_except_condition       : out std_logic;
    harc_DSP                   : out harc_range;
	decoded_instruction_DSP    : in  std_logic_vector(DSP_UNIT_INSTR_SET_SIZE-1 downto 0);
	harc_EXEC                  : in  harc_range;
	pc_IE                      : in  std_logic_vector(31 downto 0);
	RS1_Data_IE                : in  std_logic_vector(31 downto 0);
	RS2_Data_IE                : in  std_logic_vector(31 downto 0);
	RD_Data_IE                 : in  std_logic_vector(31 downto 0);
    dsp_instr_req              : in  std_logic;
    dsp_instr_done             : out std_logic;
    busy_dsp                   : out std_logic;
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
end entity;


architecture DSP of DSP_Unit is

  type dsp_states is (dsp_init, dsp_exec);

  signal state_DSP     : dsp_states;
  signal nextstate_DSP : dsp_states;

  signal pc_DSP                         : std_logic_vector(31 downto 0);
  signal EN_OUT                         : std_logic;
  signal EN_NXT_STAGE                   : std_logic;
  signal dsp_parallel_read_internal_lat : std_logic_vector(1 downto 0);
  signal dsp_parallel_read_internal     : std_logic_vector(1 downto 0);
  signal dsp_parallel_write_internal    : std_logic_vector(1 downto 0);
  signal dsp_rs1_to_sc                  : std_logic_vector(2 downto 0);
  signal dsp_rs2_to_sc                  : std_logic_vector(2 downto 0);
  signal dsp_rd_to_sc                   : std_logic_vector(2 downto 0);
  signal ONE_MASK                       : std_logic_vector(255 downto 0);
  signal ZERO_MASK                      : std_logic_vector(255 downto 0);
  signal MULT_ACCUM                     : std_logic_vector(255 downto 0);
  signal MULT_ACCUM_MASK                : std_logic_vector(255 downto 0);
  signal ADD_MASK                       : std_logic_vector(127 downto 0);
  signal DOTP_ACCUM                     : std_logic_vector(Data_Width -1 downto 0);
  signal RS1_Data_IE_lat                : std_logic_vector(31 downto 0);
  signal RS2_Data_IE_lat                : std_logic_vector(31 downto 0);
  signal RD_Data_IE_lat                 : std_logic_vector(31 downto 0);
  signal MVSIZE_READ                    : std_logic_vector(8 downto 0);
  signal MVSIZE_WRITE                   : std_logic_vector(8 downto 0);
  signal busy_dsp_internal              : std_logic;
  signal busy_DSP_internal_lat          : std_logic;
  signal DOTP_CYCLE                     : std_logic;

begin
	
  busy_dsp           <= busy_dsp_internal;
  dsp_parallel_read  <= dsp_parallel_read_internal;
  dsp_parallel_write <= dsp_parallel_write_internal;

  DSP_Exec_Unit : process(clk_i, rst_ni)

  begin
    if rst_ni = '0' then
	  EN_NXT_STAGE <= '0';
      ONE_MASK        <= (others => '1');
      ZERO_MASK       <= (others => '0');
      ADD_MASK        <= (others => '0');
      MULT_ACCUM_MASK <= (others => '0');
	  MVSIZE_READ     <= (others =>'0');
	  MVSIZE_WRITE    <= (others =>'0');
	  MULT_ACCUM      <= (others =>'0');
      dsp_except_data <= (others =>'0');
      RS1_Data_IE_lat <= (others =>'0');
      RS2_Data_IE_lat <= (others =>'0');
      RD_Data_IE_lat  <= (others =>'0');
	  dsp_rs1_to_sc   <= (others =>'0');
	  dsp_rs2_to_sc   <= (others =>'0');
	  dsp_rd_to_sc    <= (others =>'0');
    elsif rising_edge(clk_i) then
	  if dsp_instr_req = '1' then
        harc_DSP <= harc_EXEC;
	  end if;
      if dsp_instr_req = '1' or busy_DSP_internal = '1' or busy_DSP_internal_lat = '1' then
			
        case state_DSP is
			
		  when dsp_init =>
			
	        if decoded_instruction_DSP(KADDV_bit_position) = '1' or decoded_instruction_DSP(KDOTP_bit_position) = '1' then
              MVSIZE_READ <= MVSIZE(harc_EXEC)(8 downto 0);
              MVSIZE_WRITE <= MVSIZE(harc_EXEC)(8 downto 0);
              dsp_rs1_to_sc <= rs1_to_sc;
              dsp_rs2_to_sc <= rs2_to_sc;
	          dsp_rd_to_sc  <= rd_to_sc;
              RS1_Data_IE_lat <= RS1_Data_IE;
              RS2_Data_IE_lat <= RS2_Data_IE;
              RD_Data_IE_lat <= RD_Data_IE;
              pc_DSP <= pc_IE;
              EN_NXT_STAGE <= '0';
            end if;
	
		  when dsp_exec =>
			
	        if decoded_instruction_DSP(KADDV_bit_position) = '1' or decoded_instruction_DSP(KDOTP_bit_position) = '1' then
			
              if MVSIZE_READ >= '0' & "00" then
                if to_integer(unsigned(MVSIZE_READ)) mod 4 /= 0 then
                    pc_DSP_except_value(harc_DSP) <= pc_DSP;
                    dsp_except_data              <= ILLEGAL_BYTE_TRANSFER_EXCEPT_CODE;
			    elsif dsp_rs1_to_sc = "100" or dsp_rs2_to_sc = "100" or dsp_rd_to_sc = "100" then
                    pc_DSP_except_value(harc_DSP) <= pc_DSP;
                    dsp_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
                elsif dsp_rs1_to_sc = dsp_rs2_to_sc then
                    pc_DSP_except_value(harc_DSP) <= pc_IE;
                    dsp_except_data              <= READ_SAME_SCARTCHPAD_EXCEPT_CODE;
				elsif std_logic_vector(unsigned(RS1_Data_IE_lat)  + "1") > x"1FF" or std_logic_vector(unsigned(RS2_Data_IE_lat)  + "1") > x"1FF" then
                    pc_DSP_except_value(harc_DSP) <= pc_IE;
                    dsp_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
				else
			      RS1_Data_IE_lat <= std_logic_vector(unsigned(RS1_Data_IE_lat) + "1");
			      RS2_Data_IE_lat <= std_logic_vector(unsigned(RS2_Data_IE_lat) + "1");
                  if dsp_data_gnt_i(to_integer(unsigned(dsp_rs1_to_sc))) = '1' and dsp_data_gnt_i(to_integer(unsigned(dsp_rs2_to_sc))) = '1' then
				    MVSIZE_WRITE <= MVSIZE_READ;
				    if std_logic_vector(unsigned(RD_Data_IE_lat)  + "1") > x"1FF" then
                        pc_DSP_except_value(harc_DSP) <= pc_IE;
                        dsp_except_data              <= SCRATCHPAD_OVERFLOW_EXCEPT_CODE;
                    else
			        RD_Data_IE_lat  <= std_logic_vector(unsigned(RD_Data_IE_lat)  + "1");
				    end if;
				  end if;
			    end if;
              end if;

              if dsp_except_condition = '0' then
                if MVSIZE_READ >= '0' & x"10" then
  	              MVSIZE_READ <= std_logic_vector(unsigned(MVSIZE_READ) - "10000");
                  ADD_MASK <= ONE_MASK(127 downto 0);
                  MULT_ACCUM_MASK <= ONE_MASK;
		        elsif MVSIZE_READ = '0' & x"0c" then
                  MVSIZE_READ <= std_logic_vector(unsigned(MVSIZE_READ) - "1100");
                  ADD_MASK(95 downto 0) <= ONE_MASK(95 downto 0);
                  ADD_MASK(127 downto 96) <= ZERO_MASK(127 downto 96);
                  MULT_ACCUM_MASK(191 downto 0) <= ONE_MASK(191 downto 0);
                  MULT_ACCUM_MASK(255 downto 192) <= ZERO_MASK(255 downto 192);
		        elsif MVSIZE_READ = '0' & x"08" then
                  MVSIZE_READ <= std_logic_vector(unsigned(MVSIZE_READ) - "1000");
                  ADD_MASK(63 downto 0) <= ONE_MASK(63 downto 0);
                  ADD_MASK(127 downto 64) <= ZERO_MASK(127 downto 64);
                  MULT_ACCUM_MASK(127 downto 0) <= ONE_MASK(127 downto 0);
                  MULT_ACCUM_MASK(255 downto 128) <= ZERO_MASK(255 downto 128);
		        elsif MVSIZE_READ = '0' & x"04" then
                  MVSIZE_READ <= std_logic_vector(unsigned(MVSIZE_READ) - "100");
                  ADD_MASK(31 downto 0) <= ONE_MASK(31 downto 0);
                  ADD_MASK(127 downto 32) <= ZERO_MASK(127 downto 32);
                  MULT_ACCUM_MASK(63 downto 0) <= ONE_MASK(63 downto 0);
                  MULT_ACCUM_MASK(255 downto 64) <= ZERO_MASK(255 downto 64);
                end if;
			  end if;
			 end if;
			
            if decoded_instruction_DSP(KDOTP_bit_position) = '1' then
			  if dsp_data_gnt_i(to_integer(unsigned(dsp_rs1_to_sc))) = '1' and dsp_data_gnt_i(to_integer(unsigned(dsp_rs2_to_sc))) = '1' then
	            for i in 0 to 3 loop
                  MULT_ACCUM(63+64*i downto 64*i) <= std_logic_vector( (unsigned(dsp_sc_data_read_wire(to_integer(unsigned(dsp_rs1_to_sc)))(31+32*i downto 32*i)) 
                                                                      * unsigned(dsp_sc_data_read_wire(to_integer(unsigned(dsp_rs2_to_sc)))(31+32*i downto 32*i))) 
                                                                    and unsigned(MULT_ACCUM_MASK(63+64*i downto 64*i)));
                end loop;
				if MVSIZE_WRITE > '0' & x"00" then
				  EN_NXT_STAGE <= '1';
				end if;
              end if;
              if MVSIZE_WRITE = '0' & x"00" then
			    EN_NXT_STAGE <= '0';
              end if;
		    end if;
				
		end case;
      end if;
    end if;	
  end process;

  DSP_Exec_Unit_comb : process(all)
  
  variable busy_DSP_internal_wires : std_logic;
  variable dsp_except_condition_wires : std_logic;
  variable dsp_taken_branch_wires : std_logic;  
		  
  begin

  busy_DSP_internal_wires     := '0';
  dsp_except_condition_wires  := '0';
  dsp_taken_branch_wires      := '0';
  dsp_sci_req                 <= (others => '0');
  dsp_sci_we                  <= (others => '0');
  dsp_sc_read_addr            <= (others => '0');
  dsp_sc_write_addr           <= (others => '0');
  dsp_parallel_read_internal  <= (others => '0');
  dsp_parallel_write_internal <= (others => '0');

    if rst_ni = '0' then
      dsp_instr_done <= '0';
      nextstate_DSP <= dsp_init;
    else
      dsp_instr_done <= '0';
      if dsp_instr_req = '1' or busy_DSP_internal = '1' or busy_DSP_internal_lat = '1' then
		  
        case state_DSP is
			
		  when dsp_init => 
			
            if decoded_instruction_DSP(KADDV_bit_position) = '1'  or decoded_instruction_DSP(KDOTP_bit_position) = '1' then
              if dsp_except_condition_wires = '0' then
                nextstate_DSP <= dsp_exec;
                busy_DSP_internal_wires := '1';
              end if;
			end if;

          when dsp_exec => 

            if decoded_instruction_DSP(KADDV_bit_position) = '1' or decoded_instruction_DSP(KDOTP_bit_position) = '1' then
              if to_integer(unsigned(MVSIZE_READ)) mod 4 /= 0 then
 		          busy_DSP_internal_wires    := '0';
                  dsp_except_condition_wires := '1';
                  dsp_taken_branch_wires     := '1';    
                  nextstate_DSP <= dsp_init;
			  elsif dsp_rs1_to_sc = "100" or dsp_rs2_to_sc = "100" or dsp_rd_to_sc = "100" then
 		          busy_DSP_internal_wires    := '0';
                  dsp_except_condition_wires := '1';
                  dsp_taken_branch_wires     := '1';    
                  nextstate_DSP <= dsp_init;
              elsif dsp_rs1_to_sc = dsp_rs2_to_sc then
 		          busy_DSP_internal_wires    := '0';
                  dsp_except_condition_wires := '1';
                  dsp_taken_branch_wires     := '1';    
                  nextstate_DSP <= dsp_init;			  
              elsif std_logic_vector(unsigned(RD_Data_IE_lat)   + unsigned(MVSIZE_READ)) > x"1FF" or 
				    std_logic_vector(unsigned(RS1_Data_IE_lat)  + unsigned(MVSIZE_READ)) > x"1FF" or 
				    std_logic_vector(unsigned(RS2_Data_IE_lat)  + unsigned(MVSIZE_WRITE)) > x"1FF" then
 		          busy_DSP_internal_wires    := '0';
                  dsp_except_condition_wires := '1';
                  dsp_taken_branch_wires     := '1';    
                  nextstate_DSP <= dsp_init;
              end if;
              if MVSIZE_READ >= '0' & x"10" then
                dsp_parallel_read_internal <= "11";
              elsif MVSIZE_READ = '0' & x"0C" then
                dsp_parallel_read_internal <= "10";
		      elsif MVSIZE_READ = '0' & x"08" then
                dsp_parallel_read_internal <= "01";
              elsif MVSIZE_READ = '0' & x"04" then
                dsp_parallel_read_internal <= "00";
              end if;
            end if;
				
	        if decoded_instruction_DSP(KADDV_bit_position) = '1' then		
              if dsp_data_gnt_i(to_integer(unsigned(dsp_rs1_to_sc))) = '1' and dsp_data_gnt_i(to_integer(unsigned(dsp_rs2_to_sc))) = '1' then
                if MVSIZE_WRITE >= '0' & x"10" then
                  dsp_parallel_write_internal <= "11";
                elsif MVSIZE_WRITE = '0' & x"0C" then
                  dsp_parallel_write_internal <= "10";
		        elsif MVSIZE_WRITE = '0' & x"08" then
                  dsp_parallel_write_internal <= "01";
                elsif MVSIZE_WRITE = '0' & x"04" then
                  dsp_parallel_write_internal <= "00";
                end if;
	            for i in 0 to 3 loop
                  if to_integer(unsigned(dsp_parallel_write_internal)) >= i then
                    dsp_sc_data_write_wire(31+32*(i) downto 32*(i))   <= std_logic_vector((unsigned(dsp_sc_data_read_wire(to_integer(unsigned(dsp_rs1_to_sc)))(31+32*(i) downto 32*(i))) 
                                                                                         + unsigned(dsp_sc_data_read_wire(to_integer(unsigned(dsp_rs2_to_sc)))(31+32*(i) downto 32*(i))))
                                                                                       and unsigned(ADD_MASK(31+32*(i) downto 32*(i))));
                  end if;
                end loop;
			  end if;
              if MVSIZE_READ > '0' & x"00" then
				if dsp_except_condition_wires = '0' then
                  nextstate_DSP <= dsp_exec;
 		          busy_DSP_internal_wires := '1';
                  dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc))) <= '1';
                  dsp_sci_req(to_integer(unsigned(dsp_rs2_to_sc))) <= '1';
                  dsp_sc_read_addr  <= RS1_Data_IE_lat(8 downto 0);
                  dsp_sc_read_addr  <= RS2_Data_IE_lat(8 downto 0);
                  if dsp_data_gnt_i(to_integer(unsigned(dsp_rs1_to_sc))) = '1' and dsp_data_gnt_i(to_integer(unsigned(dsp_rs2_to_sc))) = '1' then	  
                    dsp_sci_req(to_integer(unsigned(dsp_rd_to_sc)))  <= '1';
                    dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc)))   <= '1';
                    dsp_sc_write_addr <= RD_Data_IE_lat(8 downto 0);
                  end if;
                end if;
              else 
                nextstate_DSP <= dsp_init;
                if dsp_data_gnt_i(to_integer(unsigned(dsp_rs1_to_sc))) = '1' and dsp_data_gnt_i(to_integer(unsigned(dsp_rs2_to_sc))) = '1' then	  
                  dsp_sci_req(to_integer(unsigned(dsp_rd_to_sc)))  <= '1';
                  dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc)))   <= '1';
                  dsp_sc_write_addr <= RD_Data_IE_lat(8 downto 0);
                end if;
              end if;
            end if;

            if decoded_instruction_DSP(KDOTP_bit_position) = '1' then
              if dsp_except_condition_wires = '0' then
                if MVSIZE_READ > '0' & x"00" then
                  dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc))) <= '1';
                  dsp_sci_req(to_integer(unsigned(dsp_rs2_to_sc))) <= '1';
                  dsp_sc_read_addr  <= RS1_Data_IE_lat(8 downto 0);
                  dsp_sc_read_addr  <= RS2_Data_IE_lat(8 downto 0);
                  nextstate_DSP <= dsp_exec;
                  busy_DSP_internal_wires := '1';
                elsif MVSIZE_WRITE >'0' & x"00" or EN_NXT_STAGE = '1' then
                  nextstate_DSP <= dsp_exec;
 		          busy_DSP_internal_wires := '1';
                elsif  EN_NXT_STAGE = '0' then
                  nextstate_DSP <= dsp_init;
 		          busy_DSP_internal_wires := '0';
                  dsp_parallel_write_internal <= "11";
                  dsp_sci_req(to_integer(unsigned(dsp_rd_to_sc))) <= '1'; 
                  dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) <= '1';
                  dsp_sc_write_addr <= RD_Data_IE_lat(8 downto 0);
                  dsp_sc_data_write_wire <= DOTP_ACCUM;
                end if;
              end if;
            end if;

        end case;			
      end if;	  
    end if;
		
  busy_DSP_internal    <= busy_DSP_internal_wires;
  dsp_except_condition <= dsp_except_condition_wires;
  dsp_taken_branch     <= dsp_taken_branch_wires;
		  
  end process;
  
  fsm_DSP_state : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      state_DSP <= dsp_init;
	  dsp_parallel_read_internal_lat <= "00";
	  busy_DSP_internal_lat <= '0';
    elsif rising_edge(clk_i) then
      state_DSP <= nextstate_DSP;
      dsp_parallel_read_internal_lat <= dsp_parallel_read_internal;
      busy_DSP_internal_lat <= busy_DSP_internal;
    end if;
  end process;

  fsm_DSP_NXT_STAGE : process(clk_i, rst_ni)
  begin
	if rst_ni = '0' then
      DOTP_ACCUM <= (others => '0');
    elsif rising_edge(clk_i) then
      case state_DSP is
			
	    when dsp_init =>
		  
          DOTP_ACCUM <= (others => '0');
		
		when dsp_exec =>
		
	      if EN_NXT_STAGE = '1' then
            if decoded_instruction_DSP(KDOTP_bit_position) = '1' then
              DOTP_ACCUM(63 downto 0) <= std_logic_vector(unsigned(MULT_ACCUM(63 downto 0))    + unsigned(MULT_ACCUM(127 downto 64))  + 
														  unsigned(MULT_ACCUM(191 downto 128)) + unsigned(MULT_ACCUM(255 downto 192)) + 
														  unsigned(DOTP_ACCUM(63 downto 0)));	  
            end if;            
          end if;
			  
      end case;
    end if;
  end process;
end DSP;
