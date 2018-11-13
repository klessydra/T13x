-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

-- local packages ------------
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

-- DSP  pinout --------------------
entity DSP_Unit is
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
	irq_pending                : in replicated_bit;
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
    vec_read_rs2_ID            : in  std_logic;
    vec_write_rd_ID            : in  std_logic;
    vec_width_ID               : in  std_logic_vector(1 downto 0);
    busy_dsp                   : out std_logic;
	-- Scratchpad Interface Signals
    dsp_data_gnt_i             : in  std_logic;
	dsp_sc_data_read_wire      : in  array_2d(1 downto 0)(Data_Width -1 downto 0);
    dsp_sc_read_addr           : out array_2d(1 downto 0)(Addr_Width -1 downto 0);
	dsp_to_sc                  : out array_2d(Num_Scs-1 downto 0)(1 downto 0);
	dsp_sc_data_write_wire     : out std_logic_vector(Data_Width -1 downto 0);
    dsp_sc_write_addr          : out std_logic_vector(Addr_Width -1 downto 0);
	dsp_sci_we                 : out std_logic_vector(Num_SCs-1 downto 0);
	dsp_sci_req                : out std_logic_vector(Num_SCs-1 downto 0)
	);
end entity;  ------------------------------------------


architecture DSP of DSP_Unit is

  type dsp_states is (dsp_init, dsp_exec);

  signal state_DSP     : dsp_states;
  signal nextstate_DSP : dsp_states;

  -- Virtual Parallelism Signals
  signal dsp_sci_req_lat                : std_logic_vector(Num_SCs-1 downto 0);  -- AAA was introduced because dsp_data_gnt_i was not a replicated bit, which made matters complicated
  signal vec_write_rd_DSP               : std_logic;  -- Indicates whether the result being written is a vector or a scalar
  signal vec_read_rs2_DSP               : std_logic;  -- Indicates whether the operand being read is a vector or a scalar
  signal add_en                         : std_logic;  -- enables the use of the adders
  signal add_en_lat                     : std_logic;  -- enables the use of the adders
  signal mul_en                         : std_logic;  -- enables the use of the multipliers
  signal mul_en_lat                     : std_logic;  -- enables the use of the multipliers
  signal sci_req_en                     : std_logic;  -- when this is zero, the lower 64 bits of "dsp_sc_data_read" are  mapped to "dsp_operand"
  signal sci_wr_en                      : std_logic;
  signal sci_wr_en_lat                  : std_logic;
  signal carry_pass                     : std_logic_vector(2 downto 0);  -- carry enable signal, depending on it's configuration, we can do KADDV8, KADDV16, KADDV32
  signal carry_8						: std_logic_vector(3 downto 0);  -- carry-out bit of the "dsp_add_8_0" signal
  signal carry_16						: std_logic_vector(3 downto 0);  -- carry-out bit of the "dsp_add_16_8" signal
  signal carry_24						: std_logic_vector(3 downto 0);  -- carry-out bit of the "dsp_add_24_16" signal
  signal FUNCT_SELCET_MASK              : std_logic_vector(31 downto 0); -- when the mask is set to "FFFFFFFF" we enable KDOTP32 execution using the 16-bit muls
  signal dsp_add_8_0                    : array_2d(3 downto 0)(8 downto 0); -- 9-bits, contains the results of 8-bit adders
  signal dsp_add_16_8                   : array_2d(3 downto 0)(8 downto 0); -- 9-bits  contains the results of 8-bit adders
  signal dsp_add_24_16                  : array_2d(3 downto 0)(8 downto 0); -- 9-bits  contains the results of 8-bit adders
  signal dsp_add_32_24                  : array_2d(3 downto 0)(8 downto 0); -- 9-bits, this should be 8 if we choose to discard the overflow of the addition of the upper byte
  signal mul_tmp_a                      : array_2d(3 downto 0)(63 downto 0);
  signal mul_tmp_b                      : array_2d(3 downto 0)(63 downto 0);
  signal mul_tmp_c                      : array_2d(3 downto 0)(63 downto 0);
  signal mul_tmp_d                      : array_2d(3 downto 0)(63 downto 0);
  signal dsp_mul_a                      : std_logic_vector(127 downto 0); --  Contains the results of the 16-bit multipliers
  signal dsp_mul_b                      : std_logic_vector(127 downto 0); --  Contains the results of the 16-bit multipliers
  signal dsp_mul_c                      : std_logic_vector(127 downto 0); --  Contains the results of the 16-bit multipliers
  signal dsp_mul_d                      : std_logic_vector(127 downto 0); --  Contains the results of the 16-bit multipliers
  signal dsp_mul_operand                : array_2d(1 downto 0)(Data_Width -1 downto 0);
  signal dsp_in_adder_operands          : array_2d(1 downto 0)(Data_Width -1 downto 0);
  signal dsp_out_adder_operands         : std_logic_vector(Data_Width -1 downto 0);

  signal EN_WB                          : std_logic;
  signal dsp_data_gnt_i_lat             : std_logic;
  signal overflow_rs1_sc                : std_logic_vector(9 downto 0);
  signal overflow_rs2_sc                : std_logic_vector(9 downto 0);
  signal overflow_rd_sc                 : std_logic_vector(9 downto 0);
  signal dsp_rs1_to_sc                  : std_logic_vector(2 downto 0);
  signal dsp_rs2_to_sc                  : std_logic_vector(2 downto 0);
  signal dsp_rd_to_sc                   : std_logic_vector(2 downto 0);
  signal ONE_MASK                       : std_logic_vector(127 downto 0);
  signal ZERO_MASK                      : std_logic_vector(127 downto 0);
  signal MUL_ACCUM                      : std_logic_vector(255 downto 0);
  signal dsp_sc_data_read_mask          : std_logic_vector(127 downto 0);
  signal ADD_MASK                       : std_logic_vector(127 downto 0);
  signal DOTP_ACCUM                     : std_logic_vector(Data_Width -1 downto 0);
  signal RS1_Data_IE_lat                : std_logic_vector(31 downto 0);
  signal RS2_Data_IE_lat                : std_logic_vector(31 downto 0);
  signal RD_Data_IE_lat                 : std_logic_vector(31 downto 0);
  signal MVSIZE_READ                    : std_logic_vector(8 downto 0);  -- Bytes remaining to read
  signal MVSIZE_READ_MASK               : std_logic_vector(8 downto 0);  -- Bytes remaining to read
  signal MVSIZE_WRITE                   : std_logic_vector(8 downto 0);  -- Bytes remaining to write
  signal busy_dsp_internal              : std_logic;
  signal busy_DSP_internal_lat          : std_logic;

--------------------------------------------------------------------------------------------------
-------------------------------- DSP BEGIN -------------------------------------------------------
begin
	
  busy_dsp           <= busy_dsp_internal;

  ------------ Sequential Stage of DSP Unit -------------------------------------------------------------------------
  DSP_Exec_Unit : process(clk_i, rst_ni)  -- single cycle unit, fully synchronous 

  variable SIMD_BYTES : integer;  
  begin
    if rst_ni = '0' then
      SIMD_BYTES         := 0;
	  sci_req_en         <= '0';
      sci_wr_en          <= '0';
      vec_write_rd_DSP   <= '0';
      vec_read_rs2_DSP   <= '0';
      ONE_MASK           <= (others => '1');
      ZERO_MASK          <= (others => '0');
      ADD_MASK           <= (others => '0');
      FUNCT_SELCET_MASK  <= (others => '0');
	  MVSIZE_READ        <= (others => '0');
	  MVSIZE_READ_MASK   <= (others => '0');
	  MVSIZE_WRITE       <= (others => '0');
      dsp_except_data    <= (others => '0');
      RS1_Data_IE_lat    <= (others => '0');
      RS2_Data_IE_lat    <= (others => '0');
      RD_Data_IE_lat     <= (others => '0');
	  dsp_rs1_to_sc      <= (others => '0');
	  dsp_rs2_to_sc      <= (others => '0');
	  dsp_rd_to_sc       <= (others => '0');
      dsp_mul_a          <= (others => '0');
      dsp_mul_b          <= (others => '0');
      dsp_mul_c          <= (others => '0');
      dsp_mul_d          <= (others => '0');
      carry_pass         <= (others => '0');
      dsp_sc_data_read_mask  <= (others => '0');
      dsp_out_adder_operands <= (others => '0');
    elsif rising_edge(clk_i) then
      sci_wr_en <= '0';
      if irq_pending(harc_EXEC) = '1' then
        null;
      elsif dsp_instr_req = '1' or busy_DSP_internal = '1' or busy_DSP_internal_lat = '1' then  
        sci_req_en <= '1'; 

        case state_DSP is

          when dsp_init =>

            ------------------------------------------------------------------------
			-- #####  ###    ##  #####  ########      ######    ######  #######   --
			--   #    ## #   ##    #       ##         ##    #  ##       ##     #  --
			--   #    ##  #  ##    #       ##         ##    #   #####   #######   --
			--   #    ##   # ##    #       ##         ##    #       ##  ##        --
			-- #####  ##    ###  #####     ##         ######   ######   ##        --
            ------------------------------------------------------------------------


            -- Set signals to enable correct virtual parallelism operation
            if    decoded_instruction_DSP(KADDV32_bit_position) = '1' then
              carry_pass <= "111";  -- pass all carry_outs
              SIMD_BYTES := 16;
            elsif decoded_instruction_DSP(KADDV16_bit_position) = '1' then
              carry_pass <= "101";  -- pass carrries 9, and 25
              SIMD_BYTES := 16;
            elsif decoded_instruction_DSP(KADDV8_bit_position)  = '1' then
              carry_pass <= "000";  -- don't pass carry_outs and keep addition 8-bit
              SIMD_BYTES := 16;
            elsif decoded_instruction_DSP(KDOTP32_bit_position) = '1' then 
              -- KDOTP32 does not use the adders of KADDV instructions but rather adds the mul_acc results using it's own 64-bit adders
              FUNCT_SELCET_MASK <= (others => '1');  -- This enables 32-bit multiplication with the 16-bit multipliers
              SIMD_BYTES := 16;
            elsif decoded_instruction_DSP(KDOTP16_bit_position) = '1' then
              FUNCT_SELCET_MASK <= (others => '0');
              SIMD_BYTES := 16;
            elsif decoded_instruction_DSP(KDOTP8_bit_position)  = '1' then
              FUNCT_SELCET_MASK <= (others => '0');
              SIMD_BYTES := 8;
            elsif decoded_instruction_DSP(KSVMUL32_bit_position) = '1' then
              FUNCT_SELCET_MASK <= (others => '1');
              SIMD_BYTES := 8;
            elsif decoded_instruction_DSP(KSVMUL16_bit_position)  = '1' then
              FUNCT_SELCET_MASK <= (others => '0');
              SIMD_BYTES := 8;
            elsif decoded_instruction_DSP(KSVMUL8_bit_position)   = '1' then
              FUNCT_SELCET_MASK <= (others => '0');
              SIMD_BYTES := 8;
            end if;

            -------------------------------------------------------------------------------------------------------------------------
			-- #######   ##   ##    ######    #######   ########      ##     ##  ###    ##  ######   ##       ###    ##   ######   --
			-- ##         ## ##    ##         ##    ##     ##         ##     ##  ## #   ##  ##    #  ##       ## #   ##  ##        --
			-- #####       ###     ##         #######      ##         #########  ##  #  ##  ##    #  ##       ##  #  ##  ##  ####  --
			-- ##         ## ##    ##         ##           ##         ##     ##  ##   # ##  ##    #  ##       ##   # ##  ##    ##  -- 
			-- #######   ##   ##    ######    ##           ##         ##     ##  ##    ###  ######   #######  ##    ###   ######   --
            -------------------------------------------------------------------------------------------------------------------------
			
            --Check for exceptions, if there aren't any, we latch the values arriving fron the ID stage because they get updated with superscalar execution ---
            if( MVSIZE(harc_EXEC)(1 downto 0) /= "00") and  vec_width_ID = "10" then  -- Set exception if the number of bytes are not divisble by four
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data              <= ILLEGAL_VECTOR_SIZE_EXCEPT_CODE;
            elsif (MVSIZE(harc_EXEC)(0) /= '0') and vec_width_ID = "01" then          -- Set exception if the number of bytes are not divisible by two
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data              <= ILLEGAL_VECTOR_SIZE_EXCEPT_CODE;
            elsif rs1_to_sc = "100" or
				  (rs2_to_sc = "100" and vec_read_rs2_ID = '1') or
				  rd_to_sc  = "100" then                                              -- Set exception for non scratchpad access
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
            elsif rs1_to_sc = rs2_to_sc and vec_read_rs2_ID = '1' then                -- Set exception for same read access 
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data              <= READ_SAME_SCARTCHPAD_EXCEPT_CODE;
            elsif overflow_rs1_sc(9) = '1' or overflow_rs2_sc(9) = '1' then           -- Set exception if reading overflows the scratchpad's address
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data               <= SCRATCHPAD_OVERFLOW_EXCEPT_CODE;
            elsif overflow_rd_sc(9) = '1'  and vec_write_rd_ID = '1' then                -- Set exception if reading overflows the scratchpad's address, scalar writes are excluded
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data                <= SCRATCHPAD_OVERFLOW_EXCEPT_CODE;
            else                                                                      -- else we backup operands from decode stage before they get updated if superscaler execution is allowed
              MVSIZE_READ <= MVSIZE(harc_EXEC)(8 downto 0);
              MVSIZE_READ_MASK <= MVSIZE(harc_EXEC)(8 downto 0);
              MVSIZE_WRITE <= MVSIZE(harc_EXEC)(8 downto 0);
              vec_write_rd_DSP <= vec_write_rd_ID;
              vec_read_rs2_DSP <= vec_read_rs2_ID;
              dsp_rs1_to_sc <= rs1_to_sc;
              dsp_rs2_to_sc <= rs2_to_sc;
	          dsp_rd_to_sc  <= rd_to_sc;
              RS1_Data_IE_lat <= RS1_Data_IE;
              RS2_Data_IE_lat <= RS2_Data_IE;
              RD_Data_IE_lat <= RD_Data_IE;
            end if;
            -------------------------------------------------------------------------------

          when dsp_exec =>

            if decoded_instruction_DSP(KDOTP8_bit_position)   = '1' or
               decoded_instruction_DSP(KSVMUL8_bit_position)  = '1' or
               decoded_instruction_DSP(KSVMUL16_bit_position)  = '1' or 
               decoded_instruction_DSP(KSVMUL32_bit_position) = '1' then
              if dsp_data_gnt_i = '1' then
                sci_req_en <= not sci_req_en;
              end if;
            end if;

            if dsp_data_gnt_i_lat = '1' and dsp_sci_req_lat(to_integer(unsigned(dsp_rs1_to_sc))) = '1' then
              sci_wr_en <= '1';
            end if;
				
            ---------------------------------------------------------------------------------------
            --  ##     ##    ##       ##          ##        #####    #####   #######    ######
            --  ##     ##    ##       ##           ##       #     #  #     #  ##    ##  ##
            --  #########    ##   #   ##   ####     ##       #     #  #     #  #######    #####
            --  ##     ##    ##  # #  ##             ##       #     #  #     #  ##             ##
            --  ##     ##     ###   ###               #######   #####    #####   ##        ######
            ---------------------------------------------------------------------------------------

            -- Increment the read addresses
            if MVSIZE_READ >= '0' & "00" and dsp_data_gnt_i = '1' and sci_req_en = '1' then -- Increment the addresses untill all the vector elements are operated fetched
              RS1_Data_IE_lat <= std_logic_vector(unsigned(RS1_Data_IE_lat) + "1");   -- source 1 address increment
              if vec_read_rs2_DSP = '1' then
                RS2_Data_IE_lat <= std_logic_vector(unsigned(RS2_Data_IE_lat) + "1"); -- source 2 address increment
              end if;
            end if;
            if vec_read_rs2_DSP = '1' and vec_width_ID /= "00" then
              if vec_write_rd_DSP = '1' and sci_wr_en = '1' then
                RD_Data_IE_lat  <= std_logic_vector(unsigned(RD_Data_IE_lat)  + "1"); -- destination address increment
              end if;
            else
              if vec_write_rd_DSP = '1' and (sci_wr_en = '1' or sci_wr_en_lat = '1') then
                RD_Data_IE_lat  <= std_logic_vector(unsigned(RD_Data_IE_lat)  + "1"); -- destination address increment
              end if;
            end if;
            -- Increment the write address when we have a result is a vector
            if( sci_wr_en = '1' and sci_req_en = '1') then
              if to_integer(unsigned(MVSIZE_WRITE)) >= SIMD_RD_BYTES then
                MVSIZE_WRITE <= std_logic_vector(unsigned(MVSIZE_WRITE) - SIMD_RD_BYTES);     -- decrement by SIMD_BYTE Execution Capability 
              elsif to_integer(unsigned(MVSIZE_WRITE)) < SIMD_RD_BYTES then
                MVSIZE_WRITE <= (others => '0');                                              -- decrement the remaining bytes
              end if;
            end if;
            -- Decrement the vector elements that have already been operated on
            if dsp_data_gnt_i = '1' and sci_req_en = '1' then
              if to_integer(unsigned(MVSIZE_READ)) >= SIMD_RD_BYTES then
                MVSIZE_READ <= std_logic_vector(unsigned(MVSIZE_READ) - SIMD_RD_BYTES);       -- decrement by SIMD_BYTE Execution Capability 
              --  dsp_sc_data_read_mask <= ONE_MASK;
                ADD_MASK <= ONE_MASK;
              elsif to_integer(unsigned(MVSIZE_READ)) < SIMD_RD_BYTES then
                MVSIZE_READ <= (others => '0');                                            -- decrement the remaining bytes
                ADD_MASK(to_integer(unsigned(MVSIZE_READ))*8-1 downto 0) <= ONE_MASK(to_integer(unsigned(MVSIZE_READ))*8-1 downto 0);
                ADD_MASK(127 downto to_integer(unsigned(MVSIZE_READ))*8) <= ZERO_MASK(127 downto to_integer(unsigned(MVSIZE_READ))*8);
            --   	dsp_sc_data_read_mask(to_integer(unsigned(MVSIZE_READ))*8 - 1 downto 0) <= ONE_MASK(to_integer(unsigned(MVSIZE_READ))*8 - 1 downto 0);
              --  dsp_sc_data_read_mask(127 downto to_integer(unsigned(MVSIZE_READ))*8)   <= ZERO_MASK(127 downto to_integer(unsigned(MVSIZE_READ))*8);
              end if;
            end if;
            if dsp_data_gnt_i = '1' or (dsp_data_gnt_i_lat = '1' and decoded_instruction_DSP(KDOTP8_bit_position)   = '1') then
            if to_integer(unsigned(MVSIZE_READ_MASK)) >= SIMD_BYTES then
              dsp_sc_data_read_mask <= ONE_MASK;
              MVSIZE_READ_MASK <= std_logic_vector(unsigned(MVSIZE_READ_MASK) - SIMD_BYTES);       -- decrement by SIMD_BYTE Execution Capability 
            elsif to_integer(unsigned(MVSIZE_READ_MASK)) < SIMD_BYTES then
              MVSIZE_READ_MASK <= (others => '0');
              dsp_sc_data_read_mask(to_integer(unsigned(MVSIZE_READ_MASK))*8 - 1 downto 0) <= ONE_MASK(to_integer(unsigned(MVSIZE_READ_MASK))*8 - 1 downto 0);
              dsp_sc_data_read_mask(127 downto to_integer(unsigned(MVSIZE_READ_MASK))*8)   <= ZERO_MASK(127 downto to_integer(unsigned(MVSIZE_READ_MASK))*8);
            end if;
            end if;

            -------------------------------------------------------------------
            --      ###      #######   #######   #######  #######    ######  --
            --     #   #     ##     #  ##     #  ##       ##    ##  ##       --
            --    #######    ##     #  ##     #  ######   #######    #####   --
            --   ##     ##   ##     #  ##     #  ##       ## ##          ##  --
            --  ##       ##  #######   #######   #######  ##   ##   ######   --
            -------------------------------------------------------------------

            -- Addition is here
	        if add_en_lat = '1' then
              --  Addition in SIMD Virtual Parallelism is executed here, if the carries are blocked, we will have a chain of 8-bit or 16-bit adders, else we have normal 32-bit adders
	          for i in 0 to 3 loop
                if dsp_data_gnt_i_lat = '1' then
                    -- All the 8-bit adders are lumped into one output signal that will write to the scratchpads
                    dsp_out_adder_operands(31+32*(i) downto 32*(i)) <= std_logic_vector(dsp_add_32_24(i)(7 downto 0) & dsp_add_24_16(i)(7 downto 0) & dsp_add_16_8(i)(7 downto 0) & dsp_add_8_0(i)(7 downto 0)
                                                                                    and ADD_MASK(31+32*(i) downto 32*(i)));
                end if;
              end loop;
            end if;

            ----------------------------------------------------------------------------------------------------------
            --  ###   ###  ##    ##  ##     ########   #####  #######   ##       #####  #######  #######    ######  --
            --  ## # # ##  ##    ##  ##        ##        #    ##    ##  ##         #    ##       ##    ##  ##       --
            --  ##  #  ##  ##    ##  ##        ##        #    #######   ##         #    ######   #######    #####   --
            --  ##     ##  ##    ##  ##        ##        #    ##        ##         #    ##       ## ##          ##  --
            --  ##     ##   ######   ######    ##      #####  ##        #######  #####  #######  ##   ##   ######   --
            ----------------------------------------------------------------------------------------------------------

            if mul_en_lat = '1' and (dsp_data_gnt_i_lat = '1' or sci_wr_en = '1' or sci_req_en = '0') then
	          for i in 0 to 3 loop
                -- Unwinding the loop: 
                -- (1) The impelemtation in the loop does multiplication for KDOTP32, and KDOTP16 using only 16-bit multipliers. "A*B" = [Ahigh*(2^16) + Alow]*[Bhigh*(2^16) + Blow]
                -- (2) Expanding this equation "[Ahigh*(2^16) + Alow]*[Bhigh*(2^16) + Blow]"  gives: "Ahigh*Bhigh*(2^32) + Ahigh*Blow*(2^16) + Alow*Bhigh*(2^16) + Alow*Blow" which are the terms being stored in MUL_ACCUM
                -- (3) Partial Multiplication 
                    -- (a) "dsp_mul_a" <= Ahigh*Bhigh 
                    -- (b) "dsp_mul_b" <= Ahigh*Blow
                   -- (c) "dsp_mul_c" <= Alow*Bhigh
                    -- (d) "dsp_mul_d" <= Alow*Blow
                -- (4) "dsp_mul_a" is shifted by 32 bits to the left, "dsp_mul_b" and "dsp_mul_c" are shifted by 16-bits to the left, "dsp_mul_d" is not shifted
                -- (5) For 16-bit and 8-bit muls, the FUNCT_SELCET_MASK is set to x"00000000" blocking the terms in "dsp_mul_b" and "dsp_mul_c". For executing 32-bit muls , we set the mask to x"FFFFFFFF"
                dsp_mul_a(31+32*(i)  downto 32*(i)) <= std_logic_vector(unsigned(dsp_mul_operand(0)(15+16*(2*i+1)    downto 16*(2*i+1))) * unsigned(dsp_mul_operand(1)(15+16*(2*i+1)  downto 16*(2*i+1))));
                dsp_mul_b(31+32*(i)  downto 32*(i)) <= std_logic_vector((unsigned(dsp_mul_operand(0)(16*(2*i+1) - 1  downto 16*(2*i)))   * unsigned(dsp_mul_operand(1)(15+16*(2*i+1)  downto 16*(2*i+1)))) and unsigned(FUNCT_SELCET_MASK));
                dsp_mul_c(31+32*(i)  downto 32*(i)) <= std_logic_vector((unsigned(dsp_mul_operand(0)(15+16*(2*i+1)   downto 16*(2*i+1))) * unsigned(dsp_mul_operand(1)(16*(2*i+1) - 1 downto 16*(2*i))))   and unsigned(FUNCT_SELCET_MASK));
                dsp_mul_d(31+32*(i)  downto 32*(i)) <= std_logic_vector(unsigned(dsp_mul_operand(0)(16*(2*i+1)  - 1  downto 16*(2*i)))   * unsigned(dsp_mul_operand(1)(16*(2*i+1) - 1 downto 16*(2*i))));
              end loop;
            else
             dsp_mul_a <= (others => '0');
             dsp_mul_b <= (others => '0');
             dsp_mul_c <= (others => '0');
             dsp_mul_d <= (others => '0');
            end if;
        end case;
      end if;
    end if;	
  end process;

  ------------ Combinational Stage of DSP Unit ----------------------------------------------------------------------
  DSP_Exec_Unit_comb : process(all)
  
  variable busy_DSP_internal_wires : std_logic;
  variable dsp_except_condition_wires : std_logic;
  variable dsp_taken_branch_wires : std_logic;  
		  
  begin

  busy_DSP_internal_wires     := '0';
  dsp_except_condition_wires  := '0';
  dsp_taken_branch_wires      := '0';
  mul_en                      <= '0';
  add_en                      <= '0';
  carry_8                     <= (others => '0');
  carry_16                    <= (others => '0');
  carry_24                    <= (others => '0');
  MUL_ACCUM                   <= (others => '0');
  mul_tmp_a                   <= (others => (others => '0'));
  mul_tmp_b                   <= (others => (others => '0'));
  mul_tmp_c                   <= (others => (others => '0'));
  mul_tmp_d                   <= (others => (others => '0'));
  dsp_add_8_0                 <= (others => (others => '0'));
  dsp_add_16_8                <= (others => (others => '0'));
  dsp_add_24_16               <= (others => (others => '0'));
  dsp_add_32_24               <= (others => (others => '0'));
  overflow_rs1_sc             <= (others => '0');
  overflow_rs2_sc             <= (others => '0');
  overflow_rd_sc              <= (others => '0');
  dsp_sci_req                 <= (others => '0');
  dsp_sci_we                  <= (others => '0');
  dsp_mul_operand             <= (others => (others => '0'));
  dsp_sc_read_addr            <= (others => (others => '0'));
  dsp_to_sc                   <= (others => (others => '0'));
  dsp_in_adder_operands       <= (others => (others => '0'));
  dsp_sc_write_addr           <= (others => '0');
  dsp_sc_data_write_wire      <= (others => '0');

    if rst_ni = '0' then
      nextstate_DSP <= dsp_init;
    else
      if irq_pending(harc_EXEC)= '1' then
        nextstate_DSP <= dsp_init;
      elsif dsp_instr_req = '1' or busy_DSP_internal = '1' or busy_DSP_internal_lat = '1' then
        nextstate_DSP <= dsp_init;
        case state_DSP is
			
		  when dsp_init => 			

            -------------------------------------------------------------------------------------------------------------------------
			-- #######   ##   ##    ######    #######   ########      ##     ##  ###    ##  ######   ##       ###    ##   ######   --
			-- ##         ## ##    ##         ##    ##     ##         ##     ##  ## #   ##  ##    #  ##       ## #   ##  ##        --
			-- #####       ###     ##         #######      ##         #########  ##  #  ##  ##    #  ##       ##  #  ##  ##  ####  --
			-- ##         ## ##    ##         ##           ##         ##     ##  ##   # ##  ##    #  ##       ##   # ##  ##    ##  -- 
			-- #######   ##   ##    ######    ##           ##         ##     ##  ##    ###  ######   #######  ##    ###   ######   --
            -------------------------------------------------------------------------------------------------------------------------

            overflow_rs1_sc  <= std_logic_vector('0' & unsigned(RS1_Data_IE(8 downto 0)) + unsigned(MVSIZE(harc_EXEC)(8 downto 0)));
            overflow_rs2_sc  <= std_logic_vector('0' & unsigned(RS2_Data_IE(8 downto 0)) + unsigned(MVSIZE(harc_EXEC)(8 downto 0)));
            overflow_rd_sc   <= std_logic_vector('0' & unsigned(RD_Data_IE(8 downto 0))  + unsigned(MVSIZE(harc_EXEC)(8 downto 0)));
            if MVSIZE(harc_EXEC)(1 downto 0) /= "00" and vec_width_ID = "10" then  -- Set exception if the number of bytes are not divisible by four
              dsp_except_condition_wires := '1';
              dsp_taken_branch_wires     := '1';    
              nextstate_DSP <= dsp_init;
            elsif MVSIZE(harc_EXEC)(0) /= '0' and vec_width_ID = "01" then         -- Set exception if the number of bytes are not divisible by two
              dsp_except_condition_wires := '1';
              dsp_taken_branch_wires     := '1';
              nextstate_DSP <= dsp_init;
            elsif rs1_to_sc = "100" or
				  (rs2_to_sc = "100" and vec_read_rs2_ID = '1') or
				  rd_to_sc  = "100" then                                            -- Set exception for non scratchpad access
              dsp_taken_branch_wires     := '1';    
              nextstate_DSP <= dsp_init;
            elsif rs1_to_sc = rs2_to_sc and vec_read_rs2_ID = '1' then              -- Set exception for same read access
              dsp_except_condition_wires := '1';
              dsp_taken_branch_wires     := '1';    
              nextstate_DSP <= dsp_init;			  
            elsif overflow_rs1_sc(9) = '1' or overflow_rs2_sc(9) = '1' then         -- Set exception if reading overflows the scratchpad's address
              dsp_except_condition_wires := '1';
              dsp_taken_branch_wires     := '1';    
              nextstate_DSP <= dsp_init;
            elsif overflow_rd_sc(9) = '1'  and vec_write_rd_ID = '1' then           -- Set exception if reading overflows the scratchpad's address, scalar writes are excluded
              dsp_except_condition_wires := '1';
              dsp_taken_branch_wires     := '1';    
              nextstate_DSP <= dsp_init;
            else
              nextstate_DSP <= dsp_exec;
              busy_DSP_internal_wires := '1';
            end if;

          when dsp_exec =>

            -------------------------------------------------------------------
            --      ###      #######   #######   #######  #######    ######  --
            --     #   #     ##     #  ##     #  ##       ##    ##  ##       --
            --    #######    ##     #  ##     #  ######   #######    #####   --
            --   ##     ##   ##     #  ##     #  ##       ## ##          ##  --
            --  ##       ##  #######   #######   #######  ##   ##   ######   --
            -------------------------------------------------------------------

            -- Addition is here
	        if add_en_lat = '1' then
            --  Addition in SIMD Virtual Parallelism is executed here, if the carries are blocked, we will have a chain of 8-bit or 16-bit adders, else we have normal 32-bit adders
	          for i in 0 to 3 loop
                if dsp_data_gnt_i_lat = '1' then
                  -- Unwinding the loop: 
                  -- (1) the term "8*(4*i)" is used to jump between the 32-bit words, inside the 128-bit values read by the DSP
                  -- (2) Each addition results in an 8-bit value, and the 9th bit being the carry, depending on the instruction (KADDV32, KADDV16, KADDV8) we either pass the or block the carries.
                  -- (3) CARRIES:
                     -- (a) If we pass all the carries in the 32-bit word, we will have executed KADDV32 (4*32-bit parallel additions)
                     -- (b) If we pass the 9th and 25th carries we would have executed KADDV16 (8*16-bit parallel additions)
                     -- (c) If we pass none of the carries then we would have executed KADDV8 (16*8-bit parallel additions)
                  dsp_add_8_0(i)   <= std_logic_vector('0' & unsigned(dsp_in_adder_operands(0)(7+8*(4*i)  downto 8*(4*i)))    + unsigned(dsp_in_adder_operands(1)(7+8*(4*i)  downto 8*(4*i))));
                  dsp_add_16_8(i)  <= std_logic_vector('0' & unsigned(dsp_in_adder_operands(0)(15+8*(4*i) downto 8+8*(4*i)))  + unsigned(dsp_in_adder_operands(1)(15+8*(4*i) downto 8+8*(4*i)))  + carry_8(i));
                  dsp_add_24_16(i) <= std_logic_vector('0' & unsigned(dsp_in_adder_operands(0)(23+8*(4*i) downto 16+8*(4*i))) + unsigned(dsp_in_adder_operands(1)(23+8*(4*i) downto 16+8*(4*i))) + carry_16(i));
                  dsp_add_32_24(i) <= std_logic_vector('0' & unsigned(dsp_in_adder_operands(0)(31+8*(4*i) downto 24+8*(4*i))) + unsigned(dsp_in_adder_operands(1)(31+8*(4*i) downto 24+8*(4*i))) + carry_24(i));
                  -- All the 8-bit adders are lumped into one output write signal that will write to the scratchpads
                end if;
                -- Carries are either passed or blocked for the 9-th, 17-th, and 25-th bits
                carry_8(i)  <= dsp_add_8_0(i)(8)   and carry_pass(0);
                carry_16(i) <= dsp_add_16_8(i)(8)  and carry_pass(1);
                carry_24(i) <= dsp_add_24_16(i)(8) and carry_pass(2);
              end loop;
            end if;

            ----------------------------------------------------------------------------------------------------------
            --  ###   ###  ##    ##  ##     #########  #####  #######   ##       #####  #######  #######    ######  --
            --  ## # # ##  ##    ##  ##        ##        #    ##    ##  ##         #    ##       ##    ##  ##       --
            --  ##  #  ##  ##    ##  ##        ##        #    #######   ##         #    ######   #######    #####   --
            --  ##     ##  ##    ##  ##        ##        #    ##        ##         #    ##       ## ##          ##  --
            --  ##     ##   ######   ######    ##      #####  ##        #######  #####  #######  ##   ##   ######   --
            ----------------------------------------------------------------------------------------------------------
				
            -- KDOTP and KSVMUL instructions are handeled here
            -- this part right here shifts the intermidiate resutls appropriatley, and then accumelates them in order to get the full results
			if mul_en_lat = '1' and (sci_wr_en = '1'  or sci_wr_en_lat = '1' or sci_req_en = '0') then
              for i in 0 to 3 loop
                ------------------------------------------------------------------------------------
                mul_tmp_a(i) <=       (dsp_mul_a(31+32*(i)  downto 32*(i)) & x"00000000");
                mul_tmp_b(i) <=       (x"0000"     & dsp_mul_b(31+32*(i)  downto 32*(i)) & x"0000");
                mul_tmp_c(i) <=       (x"0000"     & dsp_mul_c(31+32*(i)  downto 32*(i)) & x"0000");
                mul_tmp_d(i) <=       (x"00000000" & dsp_mul_d(31+32*(i)  downto 32*(i)));
                ------------------------------------------------------------------------------------
                MUL_ACCUM(63+64*(i) downto 64*(i))  <= (std_logic_vector(unsigned(mul_tmp_a(i)) + unsigned(mul_tmp_b(i)) + unsigned(mul_tmp_c(i)) + unsigned(mul_tmp_d(i))));
              end loop;
            end if;

            ------------------------------------------------------------------------------
            --  ###   ###      ###      #######   #######   #####  ###    ##   ######   --
            --  ## # # ##     #   #     ##    ##  ##    ##    #    ## #   ##  ##        --
            --  ##  #  ##    #######    #######   #######     #    ##  #  ##  ##  ####  --
            --  ##     ##   ##     ##   ##        ##          #    ##   # ##  ##    ##  --
            --  ##     ##  ##       ##  ##        ##        #####  ##    ###   ######   --
            ------------------------------------------------------------------------------
            
            if decoded_instruction_DSP(KDOTP8_bit_position) = '1' then
              for i in 0 to 7 loop
                if sci_req_en = '0' then
                  dsp_mul_operand(0)(15+16*(i) downto 16*(i)) <= x"00" & (dsp_sc_data_read_wire(0)(7+8*(i) downto 8*(i)) and dsp_sc_data_read_mask(7+8*(i) downto 8*(i)));
                  dsp_mul_operand(1)(15+16*(i) downto 16*(i)) <= x"00" & (dsp_sc_data_read_wire(1)(7+8*(i) downto 8*(i)) and dsp_sc_data_read_mask(7+8*(i) downto 8*(i)));
                elsif sci_req_en = '1' then
                  dsp_mul_operand(0)(15+16*(i) downto 16*(i)) <= x"00" & (dsp_sc_data_read_wire(0)(71+8*(i) downto 64+8*(i)) and dsp_sc_data_read_mask(7+8*(i) downto 8*(i)));
                  dsp_mul_operand(1)(15+16*(i) downto 16*(i)) <= x"00" & (dsp_sc_data_read_wire(1)(71+8*(i) downto 64+8*(i)) and dsp_sc_data_read_mask(7+8*(i) downto 8*(i)));
                end if;
              end loop;
              dsp_sc_data_write_wire <= DOTP_ACCUM;
            end if;
            if decoded_instruction_DSP(KDOTP16_bit_position) = '1' or
               decoded_instruction_DSP(KDOTP32_bit_position) = '1' then
              dsp_mul_operand(0) <= dsp_sc_data_read_wire(0) and dsp_sc_data_read_mask;
              dsp_mul_operand(1) <= dsp_sc_data_read_wire(1) and dsp_sc_data_read_mask;
              dsp_sc_data_write_wire <= DOTP_ACCUM;
            end if;
            if decoded_instruction_DSP(KSVMUL8_bit_position) = '1' then
              for i in 0 to 7 loop
                dsp_mul_operand(1)(15+16*(i) downto 16*(i)) <= x"00" & RS2_Data_IE_lat(7 downto 0); -- map the scalar value
                if sci_req_en = '0' then
                  dsp_mul_operand(0)(15+16*(i) downto 16*(i)) <= x"00" & dsp_sc_data_read_wire(0)(7+8*(i) downto 8*(i));
                elsif sci_req_en = '1' then
                  dsp_mul_operand(0)(15+16*(i) downto 16*(i)) <= x"00" & dsp_sc_data_read_wire(0)(71+8*(i) downto 64+8*(i));
                end if;
                if sci_wr_en = '1' or sci_wr_en_lat = '1' then
                  dsp_sc_data_write_wire(15+16*(i) downto 16*(i)) <= MUL_ACCUM(15+32*(i) downto 32*(i));
                end if;
              end loop;
            end if;
            if decoded_instruction_DSP(KSVMUL16_bit_position) = '1' then
              for i in 0 to 7 loop
                dsp_mul_operand(1)(15+16*(i) downto 16*(i)) <= RS2_Data_IE_lat(15 downto 0); -- map the scalar value
              end loop;
              if sci_wr_en = '1' then
                dsp_sc_data_write_wire <= MUL_ACCUM(127 downto 0);
              elsif  sci_wr_en_lat = '1' then
                dsp_sc_data_write_wire <= MUL_ACCUM(255 downto 128);
              end if;
              dsp_mul_operand(0) <= dsp_sc_data_read_wire(0);
            end if;
            if decoded_instruction_DSP(KSVMUL32_bit_position) = '1' then
              for i in 0 to 3 loop
                dsp_mul_operand(1)(31+32*(i) downto 32*(i)) <= RS2_Data_IE_lat(31 downto 0); -- map the scalar value
              end loop;
              if sci_wr_en = '1' then
                dsp_sc_data_write_wire <= MUL_ACCUM(127 downto 0);
              elsif sci_wr_en_lat = '1' then
                dsp_sc_data_write_wire <= MUL_ACCUM(255 downto 128);
              end if;
              dsp_mul_operand(0) <= dsp_sc_data_read_wire(0);
            end if;
            if decoded_instruction_DSP(KADDV8_bit_position)  = '1' or
               decoded_instruction_DSP(KADDV16_bit_position) = '1' or
               decoded_instruction_DSP(KADDV32_bit_position) = '1' then
              dsp_sc_data_write_wire <= dsp_out_adder_operands;
              dsp_in_adder_operands(0) <= dsp_sc_data_read_wire(0) and dsp_sc_data_read_mask;
              dsp_in_adder_operands(1) <= dsp_sc_data_read_wire(1) and dsp_sc_data_read_mask;
            end if;

            -------------------------------------------------------------------------------------------------------------------------
            --   ######   ###    ##  ########  #######   ##           ##     ##  ###    ##  ######   ##       ###    ##   ######   --
            --  ##        ## #   ##     ##     ##     #  ##           ##     ##  ## #   ##  ##    #  ##       ## #   ##  ##        --
            --  ##        ##  #  ##     ##     #######   ##           #########  ##  #  ##  ##    #  ##       ##  #  ##  ##  ####  --
            --  ##        ##   # ##     ##     ## ##     ##           ##     ##  ##   # ##  ##    #  ##       ##   # ##  ##    ##  --
            --   ######   ##    ###     ##     ##   ##   #######      ##     ##  ##    ###  ######   #######  ##    ###   ######   --
            -------------------------------------------------------------------------------------------------------------------------

	        if decoded_instruction_DSP(KADDV8_bit_position) = '1' or decoded_instruction_DSP(KADDV16_bit_position) = '1' or decoded_instruction_DSP(KADDV32_bit_position) = '1'  then
              -- KADDV signals are handeled here
              add_en <= '1';
              if MVSIZE_READ > '0' & x"00" then
                dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
                dsp_to_sc(to_integer(unsigned(dsp_rs2_to_sc)))(1) <= '1';
                dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc))) <= '1';
                dsp_sci_req(to_integer(unsigned(dsp_rs2_to_sc))) <= '1';
                dsp_sc_read_addr(0)  <= RS1_Data_IE_lat(8 downto 0);
                dsp_sc_read_addr(1)  <= RS2_Data_IE_lat(8 downto 0);
              end if;
              if MVSIZE_WRITE > '0' & x"00" then
                nextstate_DSP <= dsp_exec;
 		        busy_DSP_internal_wires := '1';
                if  sci_wr_en = '1' then	  
                  dsp_sci_req(to_integer(unsigned(dsp_rd_to_sc)))  <= '1';
                  dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc)))   <= '1';
                  dsp_sc_write_addr <= RD_Data_IE_lat(8 downto 0);
                end if;
              else
                nextstate_DSP <= dsp_init;
              end if;
            end if;
				
            if decoded_instruction_DSP(KDOTP32_bit_position) = '1' or decoded_instruction_DSP(KDOTP16_bit_position) = '1'  or decoded_instruction_DSP(KDOTP8_bit_position) = '1' then
              -- KDOTP signals signals are handeled here
              mul_en <= '1';
              if MVSIZE_READ > '0' & x"00" then
                if sci_req_en = '1' then  -- requests every two cycles when doing KDOTP8
                  dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc))) <= '1';
                  dsp_sci_req(to_integer(unsigned(dsp_rs2_to_sc))) <= '1';
                end if;
                dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
                dsp_to_sc(to_integer(unsigned(dsp_rs2_to_sc)))(1) <= '1';
                dsp_sc_read_addr(0)  <= RS1_Data_IE_lat(8 downto 0);
                dsp_sc_read_addr(1)  <= RS2_Data_IE_lat(8 downto 0);
                nextstate_DSP <= dsp_exec;
                busy_DSP_internal_wires := '1';
              elsif EN_WB = '1'  then
                nextstate_DSP <= dsp_init;
                dsp_sci_req(to_integer(unsigned(dsp_rd_to_sc))) <= '1'; 
                dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) <= '1';
                dsp_sc_write_addr <= RD_Data_IE_lat(8 downto 0);
              else
                nextstate_DSP <= dsp_exec;
                busy_DSP_internal_wires := '1';
              end if;
            end if;

            if decoded_instruction_DSP(KSVMUL32_bit_position) = '1' or decoded_instruction_DSP(KSVMUL16_bit_position) = '1'  or decoded_instruction_DSP(KSVMUL8_bit_position) = '1' then
              -- KSVMUL signals signals are handeled here
              mul_en <= '1';
              if MVSIZE_READ > '0' & x"00" then
                if sci_req_en = '1' then  -- requests every two cycles when doing KDOTP8
                  dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc))) <= '1';
                end if;
                dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
                dsp_sc_read_addr(0)  <= RS1_Data_IE_lat(8 downto 0);
                nextstate_DSP <= dsp_exec;
                busy_DSP_internal_wires := '1';
              elsif MVSIZE_WRITE = '0' & x"00"  then
                nextstate_DSP <= dsp_init;
              else
                nextstate_DSP <= dsp_exec;
                busy_DSP_internal_wires := '1';
              end if;
              if sci_wr_en = '1' or sci_wr_en_lat = '1' then
                dsp_sci_req(to_integer(unsigned(dsp_rd_to_sc)))  <= '1';
                dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc)))   <= '1';
                dsp_sc_write_addr <= RD_Data_IE_lat(8 downto 0);
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
      sci_wr_en_lat <= '0';
      mul_en_lat    <= '0';
      add_en_lat    <= '0';
      state_DSP     <= dsp_init;
	  busy_DSP_internal_lat <= '0';
      dsp_data_gnt_i_lat <= '0';
	  dsp_sci_req_lat <= (others => '0');
    elsif rising_edge(clk_i) then
	  dsp_sci_req_lat <= dsp_sci_req;
      sci_wr_en_lat <= sci_wr_en;
      state_DSP <= nextstate_DSP;
      busy_DSP_internal_lat <= busy_DSP_internal;
      dsp_data_gnt_i_lat <= dsp_data_gnt_i;
      mul_en_lat <= mul_en;
      add_en_lat <= add_en;
    end if;
  end process;

  fsm_DSP_NXT_STAGE : process(clk_i, rst_ni)
  begin
	if rst_ni = '0' then
      EN_WB <= '0';
      DOTP_ACCUM <= (others => '0');
    elsif rising_edge(clk_i) then
      case state_DSP is
			
        when dsp_init =>

          EN_WB <= '0';
          DOTP_ACCUM <= (others => '0');

        when dsp_exec =>

          ----------------------------------------------------------
          --      ###       ######   ######  ##    ##  ###   ###  --
          --     #   #     ##       ##       ##    ##  ## # # ##  --
          --    #######    ##       ##       ##    ##  ##  #  ##  --
          --   ##     ##   ##       ##       ##    ##  ##     ##  --
          --  ##       ##   ######   ######   ######   ##     ##  --
          ----------------------------------------------------------
          if sci_wr_en = '1' or ( sci_wr_en_lat = '1' and decoded_instruction_DSP(KDOTP8_bit_position)  = '1') then 
            if decoded_instruction_DSP(KDOTP32_bit_position) = '1' then
              DOTP_ACCUM(127 downto 0) <= std_logic_vector(x"000000000000000" & "00" & (
                                                           ("00" & unsigned(MUL_ACCUM(63 downto 0)))    + ("00" & unsigned(MUL_ACCUM(127 downto 64)))  +
                                                           ("00" & unsigned(MUL_ACCUM(191 downto 128))) + ("00" & unsigned(MUL_ACCUM(255 downto 192))) +
                                                           unsigned(DOTP_ACCUM(65 downto 0))));
            elsif decoded_instruction_DSP(KDOTP16_bit_position) = '1' or decoded_instruction_DSP(KDOTP8_bit_position)  = '1' then
              DOTP_ACCUM(127 downto 0) <=  std_logic_vector(x"00000000000000000000000" & "00" & (
                                                           ("00" & unsigned(MUL_ACCUM(31 downto 0)))    + ("00" & unsigned(MUL_ACCUM(63 downto 32)))   +
                                                           ("00" & unsigned(MUL_ACCUM(95 downto 64)))   + ("00" & unsigned(MUL_ACCUM(127 downto 96)))  +
                                                           ("00" & unsigned(MUL_ACCUM(159 downto 128))) + ("00" & unsigned(MUL_ACCUM(191 downto 160))) +
                                                           ("00" & unsigned(MUL_ACCUM(223 downto 192))) + ("00" & unsigned(MUL_ACCUM(255 downto 224))) +
                                                           unsigned(DOTP_ACCUM(33 downto 0))));
            end if;
          elsif MVSIZE_WRITE = '0' & x"00" then
            EN_WB <= '1';
          end if;
      end case;
    end if;
  end process;
end DSP;
--------------------------------------------------------------------------------------------------
-- END of DSP architecture -----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
