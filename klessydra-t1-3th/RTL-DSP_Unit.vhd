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
    rs1_to_sc                  : in  std_logic_vector(SPM_ADDR_WID-1 downto 0);
    rs2_to_sc                  : in  std_logic_vector(SPM_ADDR_WID-1 downto 0);
    rd_to_sc                   : in  std_logic_vector(SPM_ADDR_WID-1 downto 0);
	-- CSR Signals
    MVSIZE                     : in  array_2d(THREAD_POOL_SIZE-1 downto 0)(Addr_Width downto 0);
    MPSCLFAC                   : in  array_2d(THREAD_POOL_SIZE-1 downto 0)(4 downto 0);
    dsp_except_data            : out std_logic_vector(31 downto 0);
	-- Program Counter Signals
	irq_pending                : in  replicated_bit;
	pc_DSP_except_value        : out replicated_32b_reg;
	dsp_taken_branch           : out std_logic;
	dsp_except_condition       : out std_logic;
    -- ID_Stage Signals
	decoded_instruction_DSP    : in  std_logic_vector(DSP_UNIT_INSTR_SET_SIZE-1 downto 0);
	harc_EXEC                  : in  harc_range;
	pc_IE                      : in  std_logic_vector(31 downto 0);
	RS1_Data_IE                : in  std_logic_vector(31 downto 0);
	RS2_Data_IE                : in  std_logic_vector(31 downto 0);
	RD_Data_IE                 : in  std_logic_vector(Addr_Width -1 downto 0);
    dsp_instr_req              : in  std_logic;
    vec_read_rs1_ID            : in  std_logic;
    vec_read_rs2_ID            : in  std_logic;
    vec_write_rd_ID            : in  std_logic;
    vec_width_ID               : in  std_logic_vector(1 downto 0);
    busy_dsp                   : out std_logic;
	-- Scratchpad Interface Signals
    dsp_data_gnt_i             : in  std_logic;
    dsp_sci_wr_gnt             : in  std_logic;
	dsp_sc_data_read           : in  array_2d(1 downto 0)(SIMD_Width-1 downto 0);
    dsp_we_word                : out std_logic_vector(SIMD-1 downto 0);
    dsp_sc_read_addr           : out array_2d(1 downto 0)(Addr_Width-1 downto 0);
	dsp_to_sc                  : out array_2d(SPM_NUM-1 downto 0)(1 downto 0);
	dsp_sc_data_write_wire     : out std_logic_vector(SIMD_Width-1 downto 0);
    dsp_sc_write_addr          : out std_logic_vector(Addr_Width-1 downto 0);
	dsp_sci_we                 : out std_logic_vector(SPM_NUM-1 downto 0);
	dsp_sci_req                : out std_logic_vector(SPM_NUM-1 downto 0)
	);
end entity;  ------------------------------------------


architecture DSP of DSP_Unit is

  signal state_DSP     : dsp_states;
  signal nextstate_DSP : dsp_states;

  -- Virtual Parallelism Signals
  signal dsp_sc_data_write_wire_int     : std_logic_vector(SIMD_Width-1 downto 0);
  signal dsp_sc_data_write_int          : std_logic_vector(SIMD_Width-1 downto 0);
  signal vec_width_DSP                  : std_logic_vector(1 downto 0);
  signal vec_write_rd_DSP               : std_logic;  -- Indicates whether the result being written is a vector or a scalar
  signal vec_read_rs2_DSP               : std_logic;  -- Indicates whether the operand being read is a vector or a scalar
  signal relu_en                        : std_logic;  -- enables the use of the shifters
  signal shift_en                       : std_logic;  -- enables the use of the shifters
  signal add_en                         : std_logic;  -- enables the use of the adders
  signal mul_en                         : std_logic;  -- enables the use of the multipliers
  signal accum_en                       : std_logic;  -- enables the use of the accumulators
  signal dotp                           : std_logic;  -- indicator used in the pipeline handler to switch functional units
  signal dotpps                         : std_logic;  -- indicator used in the pipeline handler to switch functional units
  signal wb_ready                       : std_logic;
  signal halt_dsp                       : std_logic;
  signal halt_dsp_lat                   : std_logic;
  signal recover_state                  : std_logic;
  signal recover_state_wires            : std_logic;
  signal dsp_data_gnt_i_lat             : std_logic;
  signal shifter_stage_1_en             : std_logic;
  signal shifter_stage_2_en             : std_logic;
  signal shifter_stage_3_en             : std_logic;
  signal adder_stage_1_en               : std_logic;
  signal adder_stage_2_en               : std_logic;
  signal adder_stage_3_en               : std_logic;
  signal mul_stage_1_en                 : std_logic;
  signal mul_stage_2_en                 : std_logic;
  signal mul_stage_3_en                 : std_logic;
  signal relu_stage_1_en                : std_logic;
  signal relu_stage_2_en                : std_logic;
  signal accum_stage_1_en               : std_logic;
  signal accum_stage_2_en               : std_logic;
  signal twos_complement	            : std_logic_vector(31 downto 0);
  signal dsp_shift_enabler              : std_logic_vector(15 downto 0);
  signal dsp_in_shift_amount            : std_logic_vector(4 downto 0);
  signal carry_pass                     : std_logic_vector(2 downto 0);  -- carry enable signal, depending on it's configuration, we can do KADDV8, KADDV16, KADDV32
  signal carry_8_wire                   : std_logic_vector(SIMD-1 downto 0);  -- carry-out bit of the "dsp_add_8_0" signal
  signal carry_16_wire                  : std_logic_vector(SIMD-1 downto 0);  -- carry-out bit of the "dsp_add_16_8" signal
  signal carry_16                       : std_logic_vector(SIMD-1 downto 0);  -- carry-out bit of the "dsp_add_16_8" signal
  signal carry_24_wire                  : std_logic_vector(SIMD-1 downto 0);  -- carry-out bit of the "dsp_add_24_16" signal
  signal FUNCT_SELECT_MASK              : std_logic_vector(31 downto 0); -- when the mask is set to "FFFFFFFF" we enable KDOTP32 execution using the 16-bit muls
  signal dsp_add_8_0                    : array_2d(SIMD-1 downto 0)(8 downto 0); -- 9-bits, contains the results of 8-bit adders
  signal dsp_add_16_8                   : array_2d(SIMD-1 downto 0)(8 downto 0); -- 9-bits  contains the results of 8-bit adders
  signal dsp_add_8_0_wire               : array_2d(SIMD-1 downto 0)(8 downto 0); -- 9-bits, contains the results of 8-bit adders
  signal dsp_add_16_8_wire              : array_2d(SIMD-1 downto 0)(8 downto 0); -- 9-bits  contains the results of 8-bit adders
  signal dsp_add_24_16_wire             : array_2d(SIMD-1 downto 0)(8 downto 0); -- 9-bits  contains the results of 8-bit adders
  signal dsp_add_32_24_wire             : array_2d(SIMD-1 downto 0)(8 downto 0); -- 9-bits, this should be 8 if we choose to discard the overflow of the addition of the upper byte
  signal mul_tmp_a                      : array_2d(SIMD-1 downto 0)(Data_Width-1 downto 0);
  signal mul_tmp_b                      : array_2d(SIMD-1 downto 0)(Data_Width-1 downto 0);
  signal mul_tmp_c                      : array_2d(SIMD-1 downto 0)(Data_Width-1 downto 0);
  signal mul_tmp_d                      : array_2d(SIMD-1 downto 0)(Data_Width-1 downto 0);
  signal dsp_mul_a                      : std_logic_vector(SIMD_Width -1 downto 0); --  Contains the results of the 16-bit multipliers
  signal dsp_mul_b                      : std_logic_vector(SIMD_Width -1 downto 0); --  Contains the results of the 16-bit multipliers
  signal dsp_mul_c                      : std_logic_vector(SIMD_Width -1 downto 0); --  Contains the results of the 16-bit multipliers
  signal dsp_mul_d                      : std_logic_vector(SIMD_Width -1 downto 0); --  Contains the results of the 16-bit multipliers
  -- Functional Unit Ports ---
  signal dsp_in_sign_bits               : std_logic_vector(4*SIMD-1 downto 0);
  signal dsp_in_shifter_operand         : std_logic_vector(SIMD_Width -1 downto 0);
  signal dsp_in_shifter_operand_lat     : std_logic_vector(SIMD_Width -1 downto 0);            -- 15 bits because i only want to latch the signed bits
  signal dsp_int_shifter_operand        : std_logic_vector(SIMD_Width -1 downto 0);
  signal dsp_out_shifter_results        : std_logic_vector(SIMD_Width -1 downto 0);
  signal dsp_in_relu_operands           : std_logic_vector(SIMD_Width-1 downto 0);
  signal dsp_in_mul_operands            : array_2d(1 downto 0)(SIMD_Width-1 downto 0);
  signal dsp_out_mul_results            : std_logic_vector(SIMD_Width-1 downto 0);
  signal dsp_out_relu_results           : std_logic_vector(SIMD_Width-1 downto 0);
  signal dsp_in_accum_operands          : std_logic_vector(SIMD_Width-1 downto 0);
  signal dsp_out_accum_results          : std_logic_vector(31 downto 0);
  signal dsp_in_adder_operands          : array_2d(1 downto 0)(SIMD_Width-1 downto 0);
  signal dsp_in_adder_operands_lat      : array_2d(1 downto 0)(SIMD_Width/2 -1 downto 0); -- data_Width devided by the number of pipeline stages
  signal dsp_out_adder_results          : std_logic_vector(SIMD_Width-1 downto 0);

  signal decoded_instruction_DSP_lat    : std_logic_vector(DSP_UNIT_INSTR_SET_SIZE -1 downto 0);
  signal overflow_rs1_sc                : std_logic_vector(Addr_Width downto 0);
  signal overflow_rs2_sc                : std_logic_vector(Addr_Width downto 0);
  signal overflow_rd_sc                 : std_logic_vector(Addr_Width downto 0);
  signal dsp_rs1_to_sc                  : std_logic_vector(SPM_ADDR_WID-1 downto 0);
  signal dsp_rs2_to_sc                  : std_logic_vector(SPM_ADDR_WID-1 downto 0);
  signal dsp_rd_to_sc                   : std_logic_vector(SPM_ADDR_WID-1 downto 0);
  signal dsp_sc_data_read_mask          : std_logic_vector(SIMD_Width-1 downto 0);
  signal RS1_Data_IE_lat                : std_logic_vector(31 downto 0);
  signal RS2_Data_IE_lat                : std_logic_vector(31 downto 0);
  signal RD_Data_IE_lat                 : std_logic_vector(Addr_Width -1 downto 0);
  signal MVSIZE_READ                    : std_logic_vector(Addr_Width downto 0);  -- Bytes remaining to read
  signal MVSIZE_READ_MASK               : std_logic_vector(Addr_Width downto 0);  -- Bytes remaining to read
  signal MVSIZE_WRITE                   : std_logic_vector(Addr_Width downto 0);  -- Bytes remaining to write
  signal MPSCLFAC_DSP                   : std_logic_vector(4 downto 0);
  signal busy_dsp_internal              : std_logic;
  signal busy_DSP_internal_lat          : std_logic;
  signal RF_RD                          : std_logic;
  signal SIMD_RD_BYTES                  : integer;

  component ACCUMULATOR
	port(
      clk_i                             : in  std_logic;
      rst_ni                            : in  std_logic;
      accum_stage_1_en                  : in  std_logic;
      recover_state_wires               : in  std_logic;
      halt_dsp_lat                      : in  std_logic;
      state_DSP                         : in  dsp_states;
      decoded_instruction_DSP_lat       : in  std_logic_vector(DSP_UNIT_INSTR_SET_SIZE -1 downto 0);
      dsp_in_accum_operands             : in  std_logic_vector(SIMD_Width-1 downto 0);
      dsp_out_accum_results             : out std_logic_vector(31 downto 0)
	);
  end component;

--------------------------------------------------------------------------------------------------
-------------------------------- DSP BEGIN -------------------------------------------------------
begin
	
  busy_dsp           <= busy_dsp_internal;

  ------------ Sequential Stage of DSP Unit -------------------------------------------------------------------------
  DSP_Exec_Unit : process(clk_i, rst_ni)  -- single cycle unit, fully synchronous 

  begin
    if rst_ni = '0' then
    elsif rising_edge(clk_i) then
      if irq_pending(harc_EXEC) = '1' then
        null;
      elsif dsp_instr_req = '1' or busy_DSP_internal_lat = '1' then  

        case state_DSP is

          when dsp_init =>

            ------------------------------------------------------------------------
			-- #####  ###    ##  #####  ########      ######    ######  #######   --
			--   #    ## #   ##    #       ##         ##    #  ##       ##     #  --
			--   #    ##  #  ##    #       ##         ##    #   #####   #######   --
			--   #    ##   # ##    #       ##         ##    #       ##  ##        --
			-- #####  ##    ###  #####     ##         ######   ######   ##        --
            ------------------------------------------------------------------------
            FUNCT_SELECT_MASK <= (others => '0');
            twos_complement <= (others => '0');
            shift_en <= '0';
            add_en   <= '0';
            relu_en  <= '0';
            RF_RD    <= '0';
            dotpps   <= '0';
            dotp     <= '0';
            accum_en <= '0';
            mul_en   <= '0';
            SIMD_RD_BYTES <= SIMD*(Data_Width/8);

            -- Set signals to enable correct virtual parallelism operation
            if decoded_instruction_DSP(KADDV32_bit_position)    = '1' or
               decoded_instruction_DSP(KSVADDSC32_bit_position) = '1' then
              carry_pass <= "111";  -- pass all carry_outs
              add_en <= '1';
            elsif decoded_instruction_DSP(KSVADDRF32_bit_position) = '1' then
              carry_pass <= "111";  -- pass all carry_outs
              add_en <= '1';
              RF_RD <= '1';
            elsif decoded_instruction_DSP(KADDV16_bit_position)    = '1' or
                  decoded_instruction_DSP(KSVADDSC16_bit_position) = '1' then
              carry_pass <= "101";  -- pass carrries 9, and 25
              add_en <= '1';
            elsif decoded_instruction_DSP(KSVADDRF16_bit_position) = '1' then
              carry_pass <= "101";  -- pass carrries 9, and 25
              add_en <= '1';
              RF_RD <= '1';
            elsif decoded_instruction_DSP(KADDV8_bit_position)     = '1' or
                  decoded_instruction_DSP(KSVADDSC8_bit_position)  = '1' then
              carry_pass <= "000";  -- don't pass carry_outs and keep addition 8-bit
              add_en <= '1';
            elsif decoded_instruction_DSP(KSVADDRF8_bit_position)  = '1' then
              carry_pass <= "000";  -- don't pass carry_outs and keep addition 8-bit
              add_en <= '1';
              RF_RD <= '1';
            elsif decoded_instruction_DSP(KSUBV32_bit_position) = '1' then
              carry_pass <= "111";  -- pass all carry_outs
              add_en <= '1';
              twos_complement <= "00010001000100010001000100010001"; -- AAA change into a for loop
            elsif decoded_instruction_DSP(KSUBV16_bit_position) = '1' then
              carry_pass <= "101";  -- pass carrries 9, and 25
              add_en <= '1';
              twos_complement <= "01010101010101010101010101010101";
            elsif decoded_instruction_DSP(KSUBV8_bit_position)  = '1' then
              carry_pass <= "000";  -- don't pass carry_outs and keep addition 8-bit
              add_en <= '1';
              twos_complement <= "11111111111111111111111111111111";
            elsif decoded_instruction_DSP(KDOTP32_bit_position) = '1' then
              -- KDOTP32 does not use the adders of KADDV instructions but rather adds the mul_acc results using it's own 64-bit adders
              FUNCT_SELECT_MASK <= (others => '1');  -- This enables 32-bit multiplication with the 16-bit multipliers
              mul_en <= '1';
              accum_en <= '1';
              dotp <= '1';
            elsif decoded_instruction_DSP(KDOTP16_bit_position) = '1' then
              mul_en <= '1';
              accum_en <= '1';
              dotp <= '1';
            elsif decoded_instruction_DSP(KDOTP8_bit_position)  = '1' then
              SIMD_RD_BYTES <= SIMD*(Data_Width/8)/2;
              mul_en <= '1';
              accum_en <= '1';
              dotp <= '1';
            elsif decoded_instruction_DSP(KDOTPPS32_bit_position) = '1' then
              FUNCT_SELECT_MASK <= (others => '1');  -- This enables 32-bit multiplication with the 16-bit multipliers
              mul_en <= '1';
              accum_en <= '1';
              shift_en <= '1';
              dotpps <= '1';
            elsif decoded_instruction_DSP(KDOTPPS16_bit_position) = '1' then
              mul_en <= '1';
              accum_en <= '1';
              shift_en <= '1';
              dotpps <= '1';
            elsif decoded_instruction_DSP(KDOTPPS8_bit_position)  = '1' then
              SIMD_RD_BYTES <= SIMD*(Data_Width/8)/2;
              mul_en <= '1';
              accum_en <= '1';
              shift_en <= '1';
              dotpps <= '1';
            elsif decoded_instruction_DSP(KVRED32_bit_position) = '1' then
              accum_en <= '1';
            elsif decoded_instruction_DSP(KVRED16_bit_position) = '1' then
              accum_en <= '1';
            elsif decoded_instruction_DSP(KVRED8_bit_position)  = '1' then
              SIMD_RD_BYTES <= SIMD*(Data_Width/8)/2;
              accum_en <= '1';
            elsif decoded_instruction_DSP(KSVMULRF32_bit_position) = '1' then
              FUNCT_SELECT_MASK <= (others => '1');
              RF_RD <= '1';
              mul_en <= '1';
            elsif decoded_instruction_DSP(KSVMULRF16_bit_position) = '1' then
              RF_RD <= '1';
              mul_en <= '1';
            elsif decoded_instruction_DSP(KSVMULRF8_bit_position)  = '1' then
              SIMD_RD_BYTES <= SIMD*(Data_Width/8)/2;
              RF_RD  <= '1';
              mul_en <= '1';
            elsif decoded_instruction_DSP(KVMUL32_bit_position)    = '1' or
				  decoded_instruction_DSP(KSVMULSC32_bit_position) = '1' then
              FUNCT_SELECT_MASK <= (others => '1');
              mul_en <= '1';
            elsif decoded_instruction_DSP(KVMUL16_bit_position)    = '1' or
				  decoded_instruction_DSP(KSVMULSC16_bit_position) = '1' then
              mul_en <= '1';
            elsif decoded_instruction_DSP(KVMUL8_bit_position)     = '1' or
				  decoded_instruction_DSP(KSVMULSC8_bit_position)  = '1' then
              SIMD_RD_BYTES <= SIMD*(Data_Width/8)/2;
              mul_en <= '1';
            elsif decoded_instruction_DSP(KSRAV32_bit_position) = '1' then
              shift_en <= '1';
            elsif decoded_instruction_DSP(KSRAV16_bit_position) = '1' then
              shift_en <= '1';
            elsif decoded_instruction_DSP(KSRAV8_bit_position)  = '1' then
              shift_en <= '1';
            elsif decoded_instruction_DSP(KSRLV32_bit_position) = '1' then
              shift_en <= '1';
            elsif decoded_instruction_DSP(KSRLV16_bit_position) = '1' then
              shift_en <= '1';
            elsif decoded_instruction_DSP(KSRLV8_bit_position)  = '1' then
              shift_en <= '1';
            elsif decoded_instruction_DSP(KRELU32_bit_position) = '1' then
              relu_en <= '1';
            elsif decoded_instruction_DSP(KRELU16_bit_position) = '1' then
              relu_en <= '1';
            elsif decoded_instruction_DSP(KRELU8_bit_position)  = '1' then
              relu_en <= '1';
            elsif decoded_instruction_DSP(KVCP_bit_position)  = '1' then
              add_en <= '1';
            end if;

            -------------------------------------------------------------------------------------------------------------------------
			-- #######   ##   ##    ######    #######   ########      ##     ##  ###    ##  ######   ##       ###    ##   ######   --
			-- ##         ## ##    ##         ##    ##     ##         ##     ##  ## #   ##  ##    #  ##       ## #   ##  ##        --
			-- #####       ###     ##         #######      ##         #########  ##  #  ##  ##    #  ##       ##  #  ##  ##  ####  --
			-- ##         ## ##    ##         ##           ##         ##     ##  ##   # ##  ##    #  ##       ##   # ##  ##    ##  -- 
			-- #######   ##   ##    ######    ##           ##         ##     ##  ##    ###  ######   #######  ##    ###   ######   --
            -------------------------------------------------------------------------------------------------------------------------
			
            --Check for exceptions, if there aren't any, we latch the values arriving fron the ID stage because they get updated with superscalar execution ---
            if MVSIZE(harc_EXEC) = (0 to Addr_Width => '0') then
              null;
            elsif( MVSIZE(harc_EXEC)(1 downto 0) /= "00") and  vec_width_ID = "10" then  -- Set exception if the number of bytes are not divisble by four
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data                <= ILLEGAL_VECTOR_SIZE_EXCEPT_CODE;
            elsif (MVSIZE(harc_EXEC)(0) /= '0') and vec_width_ID = "01" then             -- Set exception if the number of bytes are not divisible by two
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data                <= ILLEGAL_VECTOR_SIZE_EXCEPT_CODE;
            elsif (rs1_to_sc = "100" and vec_read_rs1_ID = '1') or
				  (rs2_to_sc = "100" and vec_read_rs2_ID = '1') or
				   rd_to_sc  = "100" then                                                 -- Set exception for non scratchpad access
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data              <= ILLEGAL_ADDRESS_EXCEPT_CODE;
            elsif rs1_to_sc = rs2_to_sc and vec_read_rs1_ID = '1' and vec_read_rs2_ID = '1' then                   -- Set exception for same read access 
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data              <= READ_SAME_SCARTCHPAD_EXCEPT_CODE;
            elsif (overflow_rs1_sc(Addr_Width) = '1' and vec_read_rs1_ID = '1') or (overflow_rs2_sc(Addr_Width) = '1'  and  vec_read_rs2_ID = '1') then           -- Set exception if reading overflows the scratchpad's address
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data               <= SCRATCHPAD_OVERFLOW_EXCEPT_CODE;
            elsif overflow_rd_sc(Addr_Width) = '1'  and vec_write_rd_ID = '1' then             -- Set exception if reading overflows the scratchpad's address, scalar writes are excluded
              pc_DSP_except_value(harc_EXEC) <= pc_IE;
              dsp_except_data                <= SCRATCHPAD_OVERFLOW_EXCEPT_CODE;
            else                                                                      -- else we backup operands from decode stage before they get updated if superscaler execution is allowed
              MVSIZE_READ <= MVSIZE(harc_EXEC);
              MVSIZE_READ_MASK <= MVSIZE(harc_EXEC);
              MVSIZE_WRITE <= MVSIZE(harc_EXEC);
              MPSCLFAC_DSP <= MPSCLFAC(harc_EXEC);
              decoded_instruction_DSP_lat  <= decoded_instruction_DSP;
              vec_write_rd_DSP <= vec_write_rd_ID;
              vec_read_rs2_DSP <= vec_read_rs2_ID;
              vec_width_DSP <= vec_width_ID;
              dsp_rs1_to_sc <= rs1_to_sc;
              dsp_rs2_to_sc <= rs2_to_sc;
	          dsp_rd_to_sc  <= rd_to_sc;
              RS1_Data_IE_lat <= RS1_Data_IE;
              RS2_Data_IE_lat <= RS2_Data_IE;
              RD_Data_IE_lat <= RD_Data_IE;
            end if;
            -------------------------------------------------------------------------------

          when dsp_exec =>
            recover_state <= recover_state_wires;
            if halt_dsp = '1' and halt_dsp_lat = '0' then
				dsp_sc_data_write_int <= dsp_sc_data_write_wire_int;
            end if;
            ---------------------------------------------------------------------------------------
            --  ##     ##    ##       ##          ##        #####    #####   #######    ######
            --  ##     ##    ##       ##           ##       #     #  #     #  ##    ##  ##
            --  #########    ##   #   ##   ####     ##       #     #  #     #  #######    #####
            --  ##     ##    ##  # #  ##             ##       #     #  #     #  ##             ##
            --  ##     ##     ###   ###               #######   #####    #####   ##        ######
            ---------------------------------------------------------------------------------------

            if halt_dsp = '0' then
              -- Increment the write address when we have a result as a vector
			  if vec_write_rd_DSP = '1' and wb_ready = '1' then
                  RD_Data_IE_lat  <= std_logic_vector(unsigned(RD_Data_IE_lat)  + SIMD_RD_BYTES); -- destination address increment
			  end if;
              if wb_ready = '1' then
                if to_integer(unsigned(MVSIZE_WRITE)) >= SIMD_RD_BYTES then
                  MVSIZE_WRITE <= std_logic_vector(unsigned(MVSIZE_WRITE) - SIMD_RD_BYTES);       -- decrement by SIMD_BYTE Execution Capability 
                elsif to_integer(unsigned(MVSIZE_WRITE)) < SIMD_RD_BYTES then
                  MVSIZE_WRITE <= (others => '0');                                                -- decrement the remaining bytes
                end if;
              end if;
              -- Increment the read addresses
              if to_integer(unsigned(MVSIZE_READ)) >= SIMD_RD_BYTES and dsp_data_gnt_i = '1' then -- Increment the addresses untill all the vector elements are operated fetched
                RS1_Data_IE_lat <= std_logic_vector(unsigned(RS1_Data_IE_lat) + SIMD_RD_BYTES);   -- source 1 address increment
                if vec_read_rs2_DSP = '1' then
                  RS2_Data_IE_lat <= std_logic_vector(unsigned(RS2_Data_IE_lat) + SIMD_RD_BYTES); -- source 2 address increment
                end if;
              end if;
              -- Decrement the vector elements that have already been operated on
              if dsp_data_gnt_i = '1' then
                if to_integer(unsigned(MVSIZE_READ)) >= SIMD_RD_BYTES then
                  MVSIZE_READ <= std_logic_vector(unsigned(MVSIZE_READ) - SIMD_RD_BYTES);         -- decrement by SIMD_BYTE Execution Capability
                elsif to_integer(unsigned(MVSIZE_READ)) < SIMD_RD_BYTES then
                  MVSIZE_READ <= (others => '0');                                                 -- decrement the remaining bytes
                end if;
              end if;
              if dsp_data_gnt_i_lat = '1' then
                if to_integer(unsigned(MVSIZE_READ_MASK)) >= SIMD_RD_BYTES then
                  dsp_sc_data_read_mask <= (others => '1');
                  MVSIZE_READ_MASK <= std_logic_vector(unsigned(MVSIZE_READ_MASK) - SIMD_RD_BYTES);       -- decrement by SIMD_BYTE Execution Capability 
                elsif to_integer(unsigned(MVSIZE_READ_MASK)) < SIMD_RD_BYTES then
                  MVSIZE_READ_MASK <= (others => '0');
                  dsp_sc_data_read_mask(to_integer(unsigned(MVSIZE_READ_MASK))*8 - 1 downto 0) <= (others => '1');
                  dsp_sc_data_read_mask(SIMD_Width-1 downto to_integer(unsigned(MVSIZE_READ_MASK))*8)   <= (others => '0');
                end if;
              end if;
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
    wb_ready                    <= '0';
    halt_dsp                    <= '0'; 
    recover_state_wires         <= recover_state; 
    dsp_in_shift_amount         <= (others => '0');
    dsp_in_shifter_operand      <= (others => '0');
    dsp_in_relu_operands        <= (others => '0');
    dsp_we_word                 <= (others => '0');
    overflow_rs1_sc             <= (others => '0');
    overflow_rs2_sc             <= (others => '0');
    overflow_rd_sc              <= (others => '0');
    dsp_sci_req                 <= (others => '0');
    dsp_sci_we                  <= (others => '0');
    dsp_sc_write_addr           <= (others => '0');
    dsp_sc_data_write_wire_int  <= (others => '0');
    dsp_sc_data_write_wire      <= dsp_sc_data_write_wire_int;
    nextstate_DSP               <= dsp_init;
    dsp_in_accum_operands       <= (others => '0');
    dsp_in_mul_operands         <= (others => (others => '0'));
    dsp_sc_read_addr            <= (others => (others => '0'));
    dsp_to_sc                   <= (others => (others => '0'));
    dsp_in_adder_operands       <= (others => (others => '0'));

    if irq_pending(harc_EXEC)= '1' then
      nextstate_DSP <= dsp_init;
    elsif dsp_instr_req = '1' or busy_DSP_internal_lat = '1' then
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
          overflow_rs1_sc <= std_logic_vector('0' & unsigned(RS1_Data_IE(Addr_Width -1 downto 0)) + unsigned(MVSIZE(harc_EXEC)) -1);
          overflow_rs2_sc <= std_logic_vector('0' & unsigned(RS2_Data_IE(Addr_Width -1 downto 0)) + unsigned(MVSIZE(harc_EXEC)) -1);
          overflow_rd_sc  <= std_logic_vector('0' & unsigned(RD_Data_IE(Addr_Width  -1 downto 0)) + unsigned(MVSIZE(harc_EXEC)) -1);
          if MVSIZE(harc_EXEC) = (0 to Addr_Width => '0') then
            null;
          elsif MVSIZE(harc_EXEC)(1 downto 0) /= "00" and vec_width_ID = "10" then  -- Set exception if the number of bytes are not divisible by four
            dsp_except_condition_wires := '1';
            dsp_taken_branch_wires     := '1';    
            nextstate_DSP <= dsp_init;
          elsif MVSIZE(harc_EXEC)(0) /= '0' and vec_width_ID = "01" then            -- Set exception if the number of bytes are not divisible by two
            dsp_except_condition_wires := '1';
            dsp_taken_branch_wires     := '1';
            nextstate_DSP <= dsp_init;
          elsif (rs1_to_sc  = "100" and vec_read_rs1_ID = '1') or
		        (rs2_to_sc  = "100" and vec_read_rs2_ID = '1') or
		         rd_to_sc   = "100" then     -- Set exception for non scratchpad access
            dsp_except_condition_wires := '1';
            dsp_taken_branch_wires     := '1';    
            nextstate_DSP <= dsp_init;
          elsif rs1_to_sc = rs2_to_sc and vec_read_rs1_ID = '1' and vec_read_rs2_ID = '1'then               -- Set exception for same read access
            dsp_except_condition_wires := '1';
            dsp_taken_branch_wires     := '1';    
            nextstate_DSP <= dsp_init;			  
          elsif (overflow_rs1_sc(Addr_Width) = '1' and vec_read_rs1_ID = '1') or (overflow_rs2_sc(Addr_Width) = '1' and  vec_read_rs2_ID = '1') then -- Set exception if reading overflows the scratchpad's address
            dsp_except_condition_wires := '1';
            dsp_taken_branch_wires     := '1';    
            nextstate_DSP <= dsp_init;
          elsif overflow_rd_sc(Addr_Width) = '1'  and vec_write_rd_ID = '1' then           -- Set exception if reading overflows the scratchpad's address, scalar writes are excluded
            dsp_except_condition_wires := '1';
            dsp_taken_branch_wires     := '1';    
            nextstate_DSP <= dsp_init;
          else
            nextstate_DSP <= dsp_exec;
            busy_DSP_internal_wires := '1';
          end if;
          when dsp_exec =>
           ------------------------------------------------------------------------------
           --  ###   ###      ###      #######   #######   #####  ###    ##   ######   --
           --  ## # # ##     #   #     ##    ##  ##    ##    #    ## #   ##  ##        --
           --  ##  #  ##    #######    #######   #######     #    ##  #  ##  ##  ####  --
           --  ##     ##   ##     ##   ##        ##          #    ##   # ##  ##    ##  --
           --  ##     ##  ##       ##  ##        ##        #####  ##    ###   ######   --
           ------------------------------------------------------------------------------
           
           if decoded_instruction_DSP_lat(KDOTP8_bit_position)   = '1' or 
			  decoded_instruction_DSP_lat(KDOTPPS8_bit_position) = '1' then
             for i in 0 to 2*SIMD-1 loop
               dsp_in_mul_operands(0)(15+16*(i) downto 16*(i)) <= x"00" & (dsp_sc_data_read(0)(7+8*(i) downto 8*(i)) and dsp_sc_data_read_mask(7+8*(i) downto 8*(i)));
               dsp_in_mul_operands(1)(15+16*(i) downto 16*(i)) <= x"00" & (dsp_sc_data_read(1)(7+8*(i) downto 8*(i)) and dsp_sc_data_read_mask(7+8*(i) downto 8*(i)));
               if dotp = '1' then
                 dsp_in_accum_operands <= dsp_out_mul_results;
               elsif dotpps = '1' then
                 dsp_in_shift_amount    <= MPSCLFAC_DSP;
                 dsp_in_shifter_operand <= dsp_out_mul_results;
                 dsp_in_accum_operands  <= dsp_out_shifter_results;
               end if;
             end loop;
             dsp_sc_data_write_wire_int(31 downto 0) <= dsp_out_accum_results; -- AAA add a mask in order to store the lower byte ONLY
           end if;

           if decoded_instruction_DSP_lat(KDOTP16_bit_position)   = '1' or decoded_instruction_DSP_lat(KDOTP32_bit_position)   = '1' or
              decoded_instruction_DSP_lat(KDOTPPS16_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS32_bit_position) = '1' then
             dsp_in_mul_operands(0) <= dsp_sc_data_read(0) and dsp_sc_data_read_mask;
             dsp_in_mul_operands(1) <= dsp_sc_data_read(1) and dsp_sc_data_read_mask;
             dsp_sc_data_write_wire_int(31 downto 0) <= dsp_out_accum_results;  -- AAA add a mask in order to store the lower half word when 16-bit or entire word when 32-bit
             if dotp = '1' then
               dsp_in_accum_operands <= dsp_out_mul_results;
             elsif dotpps = '1' then
               dsp_in_shift_amount    <= MPSCLFAC_DSP;
               dsp_in_shifter_operand <= dsp_out_mul_results;
               dsp_in_accum_operands  <= dsp_out_shifter_results;
             end if;
           end if;

           if decoded_instruction_DSP_lat(KVMUL8_bit_position)    = '1'  or  
              decoded_instruction_DSP_lat(KSVMULRF8_bit_position) = '1'  or  
              decoded_instruction_DSP_lat(KSVMULSC8_bit_position) = '1' then
             for i in 0 to 2*SIMD-1 loop
               if vec_read_rs2_DSP = '0' then
                 if RF_RD = '1' then
                   dsp_in_mul_operands(1)(15+16*(i) downto 16*(i)) <= x"00" & RS2_Data_IE_lat(7 downto 0); -- map the scalar value
                 elsif RF_RD = '0' then
                   dsp_in_mul_operands(1)(15+16*(i) downto 16*(i)) <= x"00" & dsp_sc_data_read(1)(7 downto 0); -- map the scalar value
                 end if;
               else
                 dsp_in_mul_operands(1)(15+16*(i) downto 16*(i)) <= x"00" & dsp_sc_data_read(1)(7+8*(i) downto 8*(i));
               end if;
               dsp_in_mul_operands(0)(15+16*(i) downto 16*(i))   <= x"00" & dsp_sc_data_read(0)(7+8*(i) downto 8*(i));
               dsp_sc_data_write_wire_int(7+8*(i) downto 8*(i)) <= dsp_out_mul_results(7+8*(2*i) downto 8*(2*i));
             end loop;
           end if;

           if decoded_instruction_DSP_lat(KVMUL16_bit_position)    = '1'  or  
              decoded_instruction_DSP_lat(KSVMULRF16_bit_position) = '1'  or  
              decoded_instruction_DSP_lat(KSVMULSC16_bit_position) = '1' then
             if vec_read_rs2_DSP = '0' then
               if RF_RD = '1' then
                 for i in 0 to 2*SIMD-1 loop
                   dsp_in_mul_operands(1)(15+16*(i) downto 16*(i)) <= RS2_Data_IE_lat(15 downto 0); -- map the scalar value
                 end loop;
               elsif RF_RD = '0' then
                 for i in 0 to 2*SIMD-1 loop
                   dsp_in_mul_operands(1)(15+16*(i) downto 16*(i)) <= dsp_sc_data_read(1)(15 downto 0); -- map the scalar value
                 end loop;				  
               end if;
             else
               dsp_in_mul_operands(1) <= dsp_sc_data_read(1);
             end if;
             dsp_sc_data_write_wire_int <= dsp_out_mul_results;
             dsp_in_mul_operands(0)         <= dsp_sc_data_read(0);
           end if;

           if decoded_instruction_DSP_lat(KVMUL32_bit_position)    = '1'  or  
              decoded_instruction_DSP_lat(KSVMULRF32_bit_position) = '1'  or  
              decoded_instruction_DSP_lat(KSVMULSC32_bit_position) = '1' then
             if vec_read_rs2_DSP = '0' then
               if RF_RD = '1' then
                 for i in 0 to SIMD-1 loop
                   dsp_in_mul_operands(1)(31+32*(i) downto 32*(i)) <= RS2_Data_IE_lat(31 downto 0); -- map the scalar value
                 end loop;
               elsif RF_RD = '0' then
                 for i in 0 to SIMD-1 loop
                   dsp_in_mul_operands(1)(31+32*(i) downto 32*(i)) <= dsp_sc_data_read(1)(31 downto 0); -- map the scalar value
                 end loop;
               end if;
             else
               dsp_in_mul_operands(1) <= dsp_sc_data_read(1);
             end if;
             dsp_sc_data_write_wire_int <= dsp_out_mul_results(SIMD_Width-1 downto 0);
             dsp_in_mul_operands(0)         <= dsp_sc_data_read(0);
           end if;

           if decoded_instruction_DSP_lat(KADDV8_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KADDV16_bit_position) = '1' or
              decoded_instruction_DSP_lat(KADDV32_bit_position) = '1' then 
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
             dsp_in_adder_operands(1)   <= dsp_sc_data_read(1);
           end if;

           if decoded_instruction_DSP_lat(KSRAV8_bit_position)   = '1' or
              decoded_instruction_DSP_lat(KSRAV16_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KSRAV32_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KSRLV8_bit_position)   = '1' or
              decoded_instruction_DSP_lat(KSRLV16_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KSRLV32_bit_position)  = '1' then 
             dsp_sc_data_write_wire_int  <= dsp_out_shifter_results;
             dsp_in_shifter_operand      <= dsp_sc_data_read(0);
             dsp_in_shift_amount         <= RS2_Data_IE_lat(4 downto 0); -- map the scalar value (shift amount)
           end if;

           if decoded_instruction_DSP(KSVADDSC32_bit_position)  = '1' then
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
             for i in 0 to SIMD-1 loop
               dsp_in_adder_operands(1)(31+32*(i) downto 32*(i))   <= dsp_sc_data_read(1)(31 downto 0);
             end loop;
           end if;

           if decoded_instruction_DSP(KSVADDSC16_bit_position)  = '1' then
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
             for i in 0 to 2*SIMD-1 loop
               dsp_in_adder_operands(1)(15+16*(i) downto 16*(i))   <= dsp_sc_data_read(1)(15 downto 0);
             end loop;
           end if;

           if decoded_instruction_DSP(KSVADDSC8_bit_position)  = '1' then
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
             for i in 0 to 4*SIMD-1 loop
               dsp_in_adder_operands(1)(7+8*(i) downto 8*(i))   <= dsp_sc_data_read(1)(7 downto 0);
             end loop;
           end if;

           if decoded_instruction_DSP(KSVADDRF32_bit_position) = '1' then
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
             for i in 0 to SIMD-1 loop
               dsp_in_adder_operands(1)(31+32*(i) downto 32*(i))   <= RS2_Data_IE_lat(31 downto 0);
             end loop;
           end if;

           if decoded_instruction_DSP(KSVADDRF16_bit_position) = '1' then
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
             for i in 0 to 2*SIMD-1 loop
               dsp_in_adder_operands(1)(15+16*(i) downto 16*(i))   <= RS2_Data_IE_lat(15 downto 0);
             end loop;
           end if;

           if decoded_instruction_DSP(KSVADDRF8_bit_position) = '1' then
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
             for i in 0 to 4*SIMD-1 loop
               dsp_in_adder_operands(1)(7+8*(i) downto 8*(i))   <= RS2_Data_IE_lat(7 downto 0);
             end loop;
           end if;

           if decoded_instruction_DSP_lat(KSUBV8_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KSUBV16_bit_position) = '1' or
              decoded_instruction_DSP_lat(KSUBV32_bit_position) = '1' then
             dsp_sc_data_write_wire_int   <= dsp_out_adder_results;
             dsp_in_adder_operands(0)     <= dsp_sc_data_read(0);
             dsp_in_adder_operands(1)     <= (not dsp_sc_data_read(1));
           end if;

           if decoded_instruction_DSP_lat(KVRED8_bit_position)  = '1' then
             for i in 0 to 2*SIMD-1 loop
               dsp_in_accum_operands(15+16*(i) downto 16*(i)) <= x"00" & (dsp_sc_data_read(0)(7+8*(i) downto 8*(i)) and dsp_sc_data_read_mask(7+8*(i) downto 8*(i)));
             end loop;
             dsp_sc_data_write_wire_int(31 downto 0) <= dsp_out_accum_results;  -- AAA add a mask in order to store the lower part only when 16-bit or 8-bit.
           end if;
           if decoded_instruction_DSP_lat(KVRED16_bit_position) = '1' or
              decoded_instruction_DSP_lat(KVRED32_bit_position) = '1' then
             dsp_sc_data_write_wire_int(31 downto 0) <= dsp_out_accum_results;  -- AAA add a mask in order to store the lower part only when 16-bit or 8-bit.
             dsp_in_accum_operands                   <= dsp_sc_data_read(0) and dsp_sc_data_read_mask;
           end if;

           if decoded_instruction_DSP_lat(KRELU8_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KRELU16_bit_position) = '1' or
              decoded_instruction_DSP_lat(KRELU32_bit_position) = '1' then
             dsp_sc_data_write_wire_int   <= dsp_out_relu_results;
             dsp_in_relu_operands         <= dsp_sc_data_read(0);
           end if;

           if    decoded_instruction_DSP(KBCAST32_bit_position) = '1' then
             for i in 0 to SIMD-1 loop
               dsp_sc_data_write_wire_int(31+32*(i) downto 32*(i)) <= RS1_Data_IE_lat;
             end loop;
           elsif decoded_instruction_DSP(KBCAST16_bit_position) = '1' then
             for i in 0 to 2*SIMD-1 loop
               dsp_sc_data_write_wire_int(15+16*(i) downto 16*(i)) <= RS1_Data_IE_lat(15 downto 0);
             end loop;
           elsif decoded_instruction_DSP(KBCAST8_bit_position)  = '1' then
             for i in 0 to 4*SIMD-1 loop
               dsp_sc_data_write_wire_int(7+8*(i)   downto 8*(i))  <= RS1_Data_IE_lat(7 downto 0);
             end loop;
           end if;

           if    decoded_instruction_DSP(KVCP_bit_position) = '1' then
             dsp_sc_data_write_wire_int <= dsp_out_adder_results;
             dsp_in_adder_operands(0)   <= dsp_sc_data_read(0);
           end if;
			   
           if halt_dsp = '0' and halt_dsp_lat = '1' then
             dsp_sc_data_write_wire <= dsp_sc_data_write_int;
           end if;
           -------------------------------------------------------------------------------------------------------------------------
           --   ######   ###    ##  ########  #######   ##           ##     ##  ###    ##  ######   ##       ###    ##   ######   --
           --  ##        ## #   ##     ##     ##     #  ##           ##     ##  ## #   ##  ##    #  ##       ## #   ##  ##        --
           --  ##        ##  #  ##     ##     #######   ##           #########  ##  #  ##  ##    #  ##       ##  #  ##  ##  ####  --
           --  ##        ##   # ##     ##     ## ##     ##           ##     ##  ##   # ##  ##    #  ##       ##   # ##  ##    ##  --
           --   ######   ##    ###     ##     ##   ##   #######      ##     ##  ##    ###  ######   #######  ##    ###   ######   --
           -------------------------------------------------------------------------------------------------------------------------
           if (dsp_sci_wr_gnt = '0' and wb_ready = '1') then
             halt_dsp <= '1';
             recover_state_wires <= '1';
           elsif unsigned(MVSIZE_WRITE) <= SIMD_RD_BYTES then
             recover_state_wires <= '0';
           end if;

           if vec_write_rd_DSP = '1' and  dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) = '1' then
             if to_integer(unsigned(MVSIZE_WRITE)) >= (SIMD)*4+1 then  -- 
               dsp_we_word <= (others => '1');
             elsif  to_integer(unsigned(MVSIZE_WRITE)) >= 1 then
               for i in 0 to SIMD-1 loop
                 if i <= to_integer(unsigned(MVSIZE_WRITE)-1)/4 then -- Four because of the number of bytes per word
                   if to_integer(unsigned(dsp_sc_write_addr(SIMD_BITS+1 downto 0))/4 + i) < SIMD then
                     dsp_we_word(to_integer(unsigned(dsp_sc_write_addr(SIMD_BITS+1 downto 0))/4 + i)) <= '1';
                   elsif to_integer(unsigned(dsp_sc_write_addr(SIMD_BITS+1 downto 0))/4 + i) >= SIMD then
                     dsp_we_word(to_integer(unsigned(dsp_sc_write_addr(SIMD_BITS+1 downto 0))/4 + i - SIMD)) <= '1';
                   end if;
                 end if;
               end loop;
             end if;
           elsif vec_write_rd_DSP = '0' and  dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) = '1' then
             dsp_we_word(to_integer(unsigned(dsp_sc_write_addr(SIMD_BITS+1 downto 0))/4)) <= '1';
           end if;

           if decoded_instruction_DSP_lat(KBCAST8_bit_position)  = '1' or decoded_instruction_DSP_lat(KBCAST16_bit_position) = '1'  or decoded_instruction_DSP_lat(KBCAST32_bit_position)  = '1' then
             -- KBCAST signals are handeled here
             if MVSIZE_WRITE > (0 to Addr_Width => '0') then
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             else
               nextstate_DSP <= dsp_init;
             end if;
             wb_ready <= '1';
             dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) <= '1';
             dsp_sc_write_addr <= RD_Data_IE_lat;
           end if;

           if decoded_instruction_DSP_lat(KVCP_bit_position)  = '1' then
             -- KVCP signals are handeled here
             if adder_stage_3_en = '1' then
               wb_ready <= '1';
             elsif recover_state = '1' then
               wb_ready <= '1';	
             end if;
             if MVSIZE_READ > (0 to Addr_Width => '0') then
               dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
               dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc)))  <= '1';
               dsp_sc_read_addr(0) <= RS1_Data_IE_lat(Addr_Width - 1 downto 0);
             end if;
             if MVSIZE_WRITE > (0 to Addr_Width => '0') then
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             else
               nextstate_DSP <= dsp_init;
             end if;
             if wb_ready = '1' then
               dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) <= '1';
               dsp_sc_write_addr <= RD_Data_IE_lat;
             end if;
           end if;

           if decoded_instruction_DSP_lat(KRELU8_bit_position) = '1' or decoded_instruction_DSP_lat(KRELU16_bit_position) = '1' or decoded_instruction_DSP_lat(KRELU32_bit_position) = '1' then
             -- KRELU signals are handeled here
             if relu_stage_2_en = '1' then
               wb_ready <= '1';
             elsif recover_state = '1' then
               wb_ready <= '1';	
             end if;
             if MVSIZE_READ > (0 to Addr_Width => '0') then
               dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
               dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc)))  <= '1';
               dsp_sc_read_addr(0) <= RS1_Data_IE_lat(Addr_Width - 1 downto 0);
             end if;
             if MVSIZE_WRITE > (0 to Addr_Width => '0') then
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             else
               nextstate_DSP <= dsp_init;
             end if;
             if wb_ready = '1' then
               dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) <= '1';
               dsp_sc_write_addr <= RD_Data_IE_lat;
             end if;
           end if;

           if decoded_instruction_DSP_lat(KSRAV8_bit_position)  = '1' or decoded_instruction_DSP_lat(KSRAV16_bit_position) = '1'  or decoded_instruction_DSP_lat(KSRAV32_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KSRLV8_bit_position)  = '1' or decoded_instruction_DSP_lat(KSRLV16_bit_position) = '1'  or decoded_instruction_DSP_lat(KSRLV32_bit_position)  = '1' then
             -- KSRAV signals are handeled here
             if shifter_stage_3_en = '1' then
               wb_ready <= '1';
             elsif recover_state = '1' then
               wb_ready <= '1';	
             end if;
             if MVSIZE_READ > (0 to Addr_Width => '0') then
               dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
               dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc)))  <= '1';
               dsp_sc_read_addr(0)  <= RS1_Data_IE_lat(Addr_Width - 1 downto 0);
             end if;
             if MVSIZE_WRITE > (0 to Addr_Width => '0') then
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             else
               nextstate_DSP <= dsp_init;
             end if;
             if wb_ready = '1' then
               dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) <= '1';
               dsp_sc_write_addr <= RD_Data_IE_lat;
             end if;
           end if;

           if decoded_instruction_DSP_lat(KADDV8_bit_position)  = '1' or decoded_instruction_DSP_lat(KADDV16_bit_position) = '1'  or decoded_instruction_DSP_lat(KADDV32_bit_position)  = '1' or
              decoded_instruction_DSP_lat(KSUBV8_bit_position)  = '1' or decoded_instruction_DSP_lat(KSUBV16_bit_position) = '1'  or decoded_instruction_DSP_lat(KSUBV32_bit_position)  = '1' then
             -- KADDV and KSUBV signals are handeled here
             if adder_stage_3_en = '1' then
               wb_ready <= '1';
             elsif recover_state = '1' then
               wb_ready <= '1';	
             end if;
             if MVSIZE_READ > (0 to Addr_Width => '0') then
               dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
               dsp_to_sc(to_integer(unsigned(dsp_rs2_to_sc)))(1) <= '1';
               dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc)))  <= '1';
               dsp_sci_req(to_integer(unsigned(dsp_rs2_to_sc)))  <= '1';
               dsp_sc_read_addr(0)  <= RS1_Data_IE_lat(Addr_Width - 1 downto 0);
               dsp_sc_read_addr(1)  <= RS2_Data_IE_lat(Addr_Width - 1 downto 0);
             end if;
             if MVSIZE_WRITE > (0 to Addr_Width => '0') then
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             else
               nextstate_DSP <= dsp_init;
             end if;
             if wb_ready = '1' then
               dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc)))    <= '1';
               dsp_sc_write_addr <= RD_Data_IE_lat;
             end if;
           end if;
  	
           if decoded_instruction_DSP_lat(KVRED32_bit_position)   = '1' or decoded_instruction_DSP_lat(KVRED16_bit_position)   = '1' or decoded_instruction_DSP_lat(KVRED8_bit_position)   = '1' or
              decoded_instruction_DSP_lat(KDOTP32_bit_position)   = '1' or decoded_instruction_DSP_lat(KDOTP16_bit_position)   = '1' or decoded_instruction_DSP_lat(KDOTP8_bit_position)   = '1' or 
              decoded_instruction_DSP_lat(KDOTPPS32_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS16_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS8_bit_position) = '1' then
             -- KDOTP signals are handeled here
             if accum_stage_2_en = '1' then
               wb_ready <= '1';
             elsif recover_state = '1' then
               wb_ready <= '1';	
             end if;
             if MVSIZE_READ > (0 to Addr_Width => '0') then
               if vec_read_rs2_DSP = '1' then
                 dsp_sci_req(to_integer(unsigned(dsp_rs2_to_sc))) <= '1';
                 dsp_to_sc(to_integer(unsigned(dsp_rs2_to_sc)))(1) <= '1';
                 dsp_sc_read_addr(1)  <= RS2_Data_IE_lat(Addr_Width - 1 downto 0);
               end if;
               dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc))) <= '1';
               dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
               dsp_sc_read_addr(0)  <= RS1_Data_IE_lat(Addr_Width - 1 downto 0);
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             elsif MVSIZE_WRITE = (0 to Addr_Width => '0') then
               nextstate_DSP <= dsp_init;
             else
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             end if;
             if wb_ready = '1' then
               dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc)))    <= '1';
               dsp_sc_write_addr <= RD_Data_IE_lat;
             end if;
           end if;

           if decoded_instruction_DSP_lat(KVMUL32_bit_position)    = '1' or decoded_instruction_DSP_lat(KVMUL16_bit_position)    = '1' or decoded_instruction_DSP_lat(KVMUL8_bit_position)    = '1' or
              decoded_instruction_DSP_lat(KSVMULSC32_bit_position) = '1' or decoded_instruction_DSP_lat(KSVMULSC16_bit_position) = '1' or decoded_instruction_DSP_lat(KSVMULSC8_bit_position) = '1' or
              decoded_instruction_DSP_lat(KSVMULRF32_bit_position) = '1' or decoded_instruction_DSP_lat(KSVMULRF16_bit_position) = '1' or decoded_instruction_DSP_lat(KSVMULRF8_bit_position) = '1' or
              decoded_instruction_DSP_lat(KSVADDSC32_bit_position) = '1' or decoded_instruction_DSP_lat(KSVADDSC16_bit_position) = '1' or decoded_instruction_DSP_lat(KSVADDSC8_bit_position) = '1' or
              decoded_instruction_DSP_lat(KSVADDRF32_bit_position) = '1' or decoded_instruction_DSP_lat(KSVADDRF16_bit_position) = '1' or decoded_instruction_DSP_lat(KSVADDRF8_bit_position) = '1' then
             -- KMUL signals are handeled here
             if mul_stage_3_en = '1' or  adder_stage_3_en = '1' then 
               wb_ready <= '1';
             elsif recover_state = '1' then
               wb_ready <= '1';				 
             end if;
             if MVSIZE_READ > (0 to Addr_Width => '0') then
               dsp_sci_req(to_integer(unsigned(dsp_rs1_to_sc))) <= '1';
               if RF_RD = '0' then -- if the scalar does not come from the regfile
                 dsp_sci_req(to_integer(unsigned(dsp_rs2_to_sc))) <= '1';
                 dsp_to_sc(to_integer(unsigned(dsp_rs2_to_sc)))(1) <= '1';
                 dsp_sc_read_addr(1)  <= RS2_Data_IE_lat(Addr_Width - 1 downto 0);
               end if;
               dsp_to_sc(to_integer(unsigned(dsp_rs1_to_sc)))(0) <= '1';
               dsp_sc_read_addr(0)  <= RS1_Data_IE_lat(Addr_Width - 1 downto 0);
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             elsif MVSIZE_WRITE = (0 to Addr_Width => '0') then
               nextstate_DSP <= dsp_init;
             else
               nextstate_DSP <= dsp_exec;
               busy_DSP_internal_wires := '1';
             end if;
             if wb_ready = '1' then
               dsp_sci_we(to_integer(unsigned(dsp_rd_to_sc))) <= '1';
               dsp_sc_write_addr <= RD_Data_IE_lat;
             end if;
           end if;
       end case;
     end if;
  		
    busy_DSP_internal    <= busy_DSP_internal_wires;
    dsp_except_condition <= dsp_except_condition_wires;
    dsp_taken_branch     <= dsp_taken_branch_wires;
		  
  end process;

  ------------------------------------------------------------------------------------------------------------------------------------------
  --  #######   #####  #######  #######  ##       #####  ###    ##  #######       ######   ###    ##  ########  #######   ##       #######   --
  --  ##    ##    #    ##    ## ##       ##         #    ## #   ##  ##           ##        ## #   ##     ##     ##     #  ##       ##     #  --
  --  #######     #    #######  ######   ##         #    ##  #  ##  ######       ##        ##  #  ##     ##     #######   ##       #######   --
  --  ##          #    ##       ##       ##         #    ##   # ##  ##           ##        ##   # ##     ##     ## ##     ##       ## ##     --
  --  ##        #####  ##       #######  #######  #####  ##    ###  #######       ######   ##    ###     ##     ##   ##   #######  ##   ##   --
  ------------------------------------------------------------------------------------------------------------------------------------------

  fsm_DSP_pipeline_controller : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      dsp_data_gnt_i_lat  <= '0';
      adder_stage_1_en    <= '0';
      adder_stage_2_en    <= '0';
      adder_stage_3_en    <= '0';
      shifter_stage_1_en  <= '0';
      shifter_stage_2_en  <= '0';
      mul_stage_1_en      <= '0';
      mul_stage_2_en      <= '0';
      mul_stage_3_en      <= '0';
      accum_stage_1_en    <= '0';
      accum_stage_2_en    <= '0';
      relu_stage_1_en     <= '0';
      relu_stage_2_en     <= '0';
      state_DSP           <= dsp_init;
	  busy_DSP_internal_lat <= '0';
    elsif rising_edge(clk_i) then
	  case state_DSP is
        when  dsp_init =>
          dsp_data_gnt_i_lat  <= '0';
          adder_stage_1_en    <= '0';
          adder_stage_2_en    <= '0';
          adder_stage_3_en    <= '0';
          shifter_stage_1_en  <= '0';
          shifter_stage_2_en  <= '0';
          mul_stage_1_en      <= '0';
          mul_stage_2_en      <= '0';
          mul_stage_3_en      <= '0';
          accum_stage_1_en    <= '0';
          accum_stage_2_en    <= '0';
          relu_stage_1_en     <= '0';
          relu_stage_2_en     <= '0';
		when  dsp_exec =>
          dsp_data_gnt_i_lat <= dsp_data_gnt_i;
          adder_stage_1_en   <= dsp_data_gnt_i_lat and add_en;
          adder_stage_2_en   <= adder_stage_1_en;
          adder_stage_3_en   <= adder_stage_2_en;
          mul_stage_1_en     <= dsp_data_gnt_i_lat and mul_en;
          mul_stage_2_en     <= mul_stage_1_en;
          mul_stage_3_en     <= mul_stage_2_en;
          relu_stage_1_en    <= dsp_data_gnt_i_lat and relu_en;
          relu_stage_2_en    <= relu_stage_1_en;
          if dotpps = '1' then
            shifter_stage_1_en <= mul_stage_2_en;
            shifter_stage_2_en <= shifter_stage_1_en;
            accum_stage_1_en   <= shifter_stage_2_en;
            accum_stage_2_en   <= accum_stage_1_en;
          elsif dotp = '1' then
            accum_stage_1_en   <= mul_stage_2_en;
            accum_stage_2_en   <= accum_stage_1_en;
          else
            shifter_stage_1_en <= dsp_data_gnt_i_lat and shift_en;
            shifter_stage_2_en <= shifter_stage_1_en;
            shifter_stage_3_en <= shifter_stage_2_en;
            accum_stage_1_en   <= dsp_data_gnt_i_lat and accum_en;
            accum_stage_2_en   <= accum_stage_1_en;
          end if;
        when others =>
          null;
      end case;
      halt_dsp_lat          <= halt_dsp;
      state_DSP             <= nextstate_DSP;
      busy_DSP_internal_lat <= busy_DSP_internal;
      for i in 0 to SIMD-1 loop
        for j in 0 to 1 loop
          dsp_in_adder_operands_lat(j)(15 +16*(i) downto 16*(i)) <= dsp_in_adder_operands(j)(31+32*(i) downto 16+32*(i));
        end loop;
      end loop;
    end if;
  end process;


  ------------------------------------------------------------------------------------------------------------
  --      ###      #######   #######   #######  #######    ######       ######  ########   ######    ###    --
  --     #   #     ##     #  ##     #  ##       ##    ##  ##           ##          ##     ##        # ##    --
  --    #######    ##     #  ##     #  ######   #######    #####        #####      ##     ##  ####    ##    --
  --   ##     ##   ##     #  ##     #  ##       ## ##          ##           ##     ##     ##    ##    ##    --
  --  ##       ##  #######   #######   #######  ##   ##   ######       ######      ##      ######   ######  --
  ------------------------------------------------------------------------------------------------------------
		
  fsm_DSP_adder_stage_1 : process(all)
  begin
    dsp_add_8_0_wire  <= dsp_add_8_0;
    dsp_add_16_8_wire <= dsp_add_16_8;
    --  Addition in SIMD Virtual Parallelism is executed here, if the carries are blocked, we will have a chain of 8-bit or 16-bit adders, else we have 32-bit adders
    for i in 0 to SIMD-1 loop
      if (adder_stage_1_en = '1' or recover_state_wires = '1') then
        -- Unwinding the loop: 
        -- (1) the term "8*(4*i)" is used to jump between the 32-bit words, inside the 128-bit values read by the DSP
        -- (2) Each addition results in an 8-bit value, and the 9th bit being the carry, depending on the instruction (KADDV32, KADDV16, KADDV8) we either pass the or block the carries.
        -- (3) CARRIES:
         -- (a) If we pass all the carries in the 32-bit word, we will have executed KADDV32 (4*32-bit parallel additions)
         -- (b) If we pass the 9th and 25th carries we would have executed KADDV16 (8*16-bit parallel additions)
         -- (c) If we pass none of the carries then we would have executed KADDV8 (16*8-bit parallel additions)
        dsp_add_8_0_wire(i)   <= std_logic_vector('0' & unsigned(dsp_in_adder_operands(0)(7+8*(4*i)  downto 8*(4*i)))    + unsigned(dsp_in_adder_operands(1)(7+8*(4*i)  downto 8*(4*i))) + twos_complement(0+(4*i)));
        dsp_add_16_8_wire(i)  <= std_logic_vector('0' & unsigned(dsp_in_adder_operands(0)(15+8*(4*i) downto 8+8*(4*i)))  + unsigned(dsp_in_adder_operands(1)(15+8*(4*i) downto 8+8*(4*i)))  + carry_8_wire(i) + twos_complement(1+(4*i)));
        -- All the 8-bit adders are lumped into one output write signal that will write to the scratchpads
      end if;
      -- Carries are either passed or blocked for the 9-th, 17-th, and 25-th bits
      carry_8_wire(i)  <= dsp_add_8_0_wire(i)(8)   and carry_pass(0);
      carry_16_wire(i) <= dsp_add_16_8_wire(i)(8)  and carry_pass(1);
    end loop;
  end process;

  -------------------------------------------------------------------------------------------------------------
  --      ###      #######   #######   #######  #######    ######       ######  ########   ######    #####   --
  --     #   #     ##     #  ##     #  ##       ##    ##  ##           ##          ##     ##        ##   ##  --
  --    #######    ##     #  ##     #  ######   #######    #####        #####      ##     ##  ####     ##    --
  --   ##     ##   ##     #  ##     #  ##       ## ##          ##           ##     ##     ##    ##   ##      --
  --  ##       ##  #######   #######   #######  ##   ##   ######       ######      ##      ######   #######  --
  -------------------------------------------------------------------------------------------------------------

  fsm_DSP_adder_stage_2 : process(all)
  begin
    carry_24_wire               <= (others => '0');
    dsp_add_24_16_wire          <= (others => (others => '0'));
    dsp_add_32_24_wire          <= (others => (others => '0'));
    -- Addition is here
    if adder_stage_2_en = '1' and halt_dsp_lat = '0' then
    --  Addition in SIMD Virtual Parallelism is executed here, if the carries are blocked, we will have a chain of 8-bit or 16-bit adders, else we have 32-bit adders
      for i in 0 to SIMD-1 loop
        if (adder_stage_2_en = '1' or recover_state_wires = '1') then
          dsp_add_24_16_wire(i) <= std_logic_vector('0' & unsigned(dsp_in_adder_operands_lat(0)(7+8*(2*i) downto 8*(2*i))) + 
			                                              unsigned(dsp_in_adder_operands_lat(1)(7+8*(2*i) downto 8*(2*i))) + 
			                                                       carry_16(i) + twos_complement(2+(4*i)));
          dsp_add_32_24_wire(i) <= std_logic_vector('0' & unsigned(dsp_in_adder_operands_lat(0)(15+8*(2*i) downto 8+8*(2*i))) + 
		                                                  unsigned(dsp_in_adder_operands_lat(1)(15+8*(2*i) downto 8+8*(2*i))) + 
		                                                           carry_24_wire(i) + twos_complement(3+(4*i)));
          -- All the 8-bit adders are lumped into one output write signal that will write to the scratchpads
        end if;
        -- Carries are either passed or blocked for the 9-th, 17-th, and 25-th bits
        carry_24_wire(i) <= dsp_add_24_16_wire(i)(8) and carry_pass(2);
      end loop;
    end if;
  end process;

  fsm_DSP_adder : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
    elsif rising_edge(clk_i) then
      -- Addition is here
      if add_en = '1' and halt_dsp_lat = '0' then
        carry_16 <= carry_16_wire;
        dsp_add_8_0  <= dsp_add_8_0_wire;
        dsp_add_16_8 <= dsp_add_16_8_wire;
        --  Addition in SIMD Virtual Parallelism is executed here, if the carries are blocked, we will have a chain of 8-bit or 16-bit adders, else we have normal 32-bit adders
        for i in 0 to SIMD-1 loop
          if (adder_stage_2_en = '1' or recover_state_wires = '1') then
              -- All the 8-bit adders are lumped into one output signal that will write to the scratchpads
            dsp_out_adder_results(31+32*(i) downto 32*(i)) <= dsp_add_32_24_wire(i)(7 downto 0) & dsp_add_24_16_wire(i)(7 downto 0) & dsp_add_16_8(i)(7 downto 0) & dsp_add_8_0(i)(7 downto 0);
          end if;
        end loop;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------------------------------------------------
  --   ######  ##     ##  #####  #######  ########  #######  #######    ######       ######  ########   ######    ###    --
  --  ##       ##     ##    #    ##          ##     ##       ##    ##  ##           ##          ##     ##        # ##    --
  --   #####   #########    #    #####       ##     ######   #######    #####        #####      ##     ##  ####    ##    --
  --       ##  ##     ##    #    ##          ##     ##       ## ##          ##           ##     ##     ##    ##    ##    --
  --  ######   ##     ##  #####  ##          ##     #######  ##   ##   ######       ######      ##      ######   ######  --
  -----------------------------------------------------------------------------------------------------------------------
  fsm_DSP_shifter_stg_1 : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
    elsif rising_edge(clk_i) then
      if shift_en = '1' and (shifter_stage_1_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
        for i in 0 to SIMD-1 loop
          dsp_int_shifter_operand(31+32*(i) downto 32*(i)) <= to_stdlogicvector(to_bitvector(dsp_in_shifter_operand(31+32*(i) downto 32*(i))) srl to_integer(unsigned(dsp_in_shift_amount)));
        end loop;
        for i in 0 to 4*SIMD-1 loop -- latch the sign bits
          dsp_in_sign_bits(i) <= dsp_in_shifter_operand(7+8*(i));
        end loop;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------------------------------------------------
  --   ######  ##     ##  #####  #######  ########  #######  #######    ######       ######  ########   ######    #####   --
  --  ##       ##     ##    #    ##          ##     ##       ##    ##  ##           ##          ##     ##        ##   ##  --
  --   #####   #########    #    #####       ##     ######   #######    #####        #####      ##     ##  ####     ##    --
  --       ##  ##     ##    #    ##          ##     ##       ## ##          ##           ##     ##     ##    ##   ##      --
  --  ######   ##     ##  #####  ##          ##     #######  ##   ##   ######       ######      ##      ######   #######  --
  --------------------------------------------------------------------------------------------------------------------------
  fsm_DSP_shifter_stg_2 : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
    elsif rising_edge(clk_i) then
      if shift_en = '1' and (shifter_stage_2_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
        if    vec_width_DSP = "10" then
          for i in 0 to SIMD-1 loop
            dsp_out_shifter_results(31+32*(i) downto 32*(i)) <= dsp_in_shifter_operand_lat(31 +32*(i) downto 32*(i)) or dsp_int_shifter_operand(31+32*(i) downto 32*(i)); 
          end loop;
        elsif vec_width_DSP = "01" or decoded_instruction_DSP_lat(KDOTPPS8_bit_position) = '1' then -- KDOTPPS8 has been added here because the number of elements loaded for mul operations is equal for 8-bit and 16-bits instr
          for i in 0 to 2*SIMD-1 loop
            dsp_out_shifter_results(15+16*(i) downto 16*(i)) <=  dsp_in_shifter_operand_lat(15 +16*(i) downto 16*(i)) or (dsp_int_shifter_operand(15+16*(i) downto 16*(i)) and dsp_shift_enabler(15 downto 0));
          end loop;
        elsif vec_width_DSP = "00" then
          for i in 0 to 4*SIMD-1 loop
            dsp_out_shifter_results(7+8*(i) downto 8*(i))    <=  dsp_in_shifter_operand_lat(7 +8*(i) downto 8*(i)) or  (dsp_int_shifter_operand(7+8*(i) downto 8*(i)) and dsp_shift_enabler(7 downto 0));
          end loop;
        end if;
      end if;
    end if;
  end process;

  fsm_DSP_shifter_comb : process(all)
  begin
    dsp_shift_enabler <= (others => '0');
    dsp_in_shifter_operand_lat <= (others => '0');
    if shift_en = '1' and halt_dsp_lat = '0' then
      if vec_width_DSP = "01" then
        dsp_shift_enabler(15 - to_integer(unsigned(dsp_in_shift_amount(3 downto 0))) downto 0) <= (others => '1');
      elsif vec_width_DSP = "00" then
        dsp_shift_enabler(7 -  to_integer(unsigned(dsp_in_shift_amount(2 downto 0))) downto 0) <= (others => '1');
      end if;
      if decoded_instruction_DSP_lat(KSRAV32_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS32_bit_position) = '1' then    -- 32-bit sign extension for for srl in stage 1
        for i in 0 to SIMD-1 loop
          dsp_in_shifter_operand_lat(31+32*(i) downto 31 - to_integer(unsigned(dsp_in_shift_amount(4 downto 0)))+32*(i))   <= (others => dsp_in_sign_bits(3+4*(i)));
        end loop;
      elsif decoded_instruction_DSP_lat(KSRAV16_bit_position) = '1' or 
            decoded_instruction_DSP_lat(KDOTPPS16_bit_position)   = '1' or
            decoded_instruction_DSP_lat(KDOTPPS8_bit_position) = '1'then -- 16-bit sign extension for for srl in stage 1
        for i in 0 to 2*SIMD-1 loop
          dsp_in_shifter_operand_lat(15+16*(i) downto 15 - to_integer(unsigned(dsp_in_shift_amount(3 downto 0)))+16*(i))   <= (others => dsp_in_sign_bits(1+2*(i)));
        end loop;
      elsif decoded_instruction_DSP_lat(KSRAV8_bit_position) = '1' then  -- 8-bit  sign extension for for srl in stage 1
        for i in 0 to 4*SIMD-1 loop
          dsp_in_shifter_operand_lat(7+8*(i) downto 7 - to_integer(unsigned(dsp_in_shift_amount(2 downto 0)))+8*(i))    <= (others => dsp_in_sign_bits(i));
        end loop;
      end if;
    end if;
  end process; 
  ----------------------------------------------------------------------------------------------------------
  --  ###   ###  ##    ##  ##     ########   #####  #######   ##       #####  #######  #######    ######  --
  --  ## # # ##  ##    ##  ##        ##        #    ##    ##  ##         #    ##       ##    ##  ##       --
  --  ##  #  ##  ##    ##  ##        ##        #    #######   ##         #    ######   #######    #####   --
  --  ##     ##  ##    ##  ##        ##        #    ##        ##         #    ##       ## ##          ##  --
  --  ##     ##   ######   ######    ##      #####  ##        #######  #####  #######  ##   ##   ######   --
  ----------------------------------------------------------------------------------------------------------
  -- STAGE 1 --
  fsm_MUL_STAGE_1 : process(clk_i,rst_ni)
  begin
    if rst_ni = '0' then
    elsif rising_edge(clk_i) then
      if halt_dsp_lat = '0' then
        if mul_en = '1' and (mul_stage_1_en = '1' or recover_state_wires = '1') then
	      for i in 0 to SIMD-1 loop
            -- Unwinding the loop: 
            -- (1) The impelemtation in the loop does multiplication for KDOTP32, and KDOTP16 using only 16-bit multipliers. "A*B" = [Ahigh*(2^16) + Alow]*[Bhigh*(2^16) + Blow]
            -- (2) Expanding this equation "[Ahigh*(2^16) + Alow]*[Bhigh*(2^16) + Blow]"  gives: "Ahigh*Bhigh*(2^32) + Ahigh*Blow*(2^16) + Alow*Bhigh*(2^16) + Alow*Blow" which are the terms being stored in dsp_out_mul_results
            -- (3) Partial Multiplication 
                -- (a) "dsp_mul_a" <= Ahigh*Bhigh 
                -- (b) "dsp_mul_b" <= Ahigh*Blow
                -- (c) "dsp_mul_c" <= Alow*Bhigh
                -- (d) "dsp_mul_d" <= Alow*Blow
            -- (4) "dsp_mul_a" is shifted by 32 bits to the left, "dsp_mul_b" and "dsp_mul_c" are shifted by 16-bits to the left, "dsp_mul_d" is not shifted
            -- (5) For 16-bit and 8-bit muls, the FUNCT_SELECT_MASK is set to x"00000000" blocking the terms in "dsp_mul_b" and "dsp_mul_c". For executing 32-bit muls , we set the mask to x"FFFFFFFF"
            dsp_mul_a(31+32*(i)  downto 32*(i)) <= std_logic_vector(unsigned(dsp_in_mul_operands(0)(15+16*(2*i+1)    downto 16*(2*i+1))) * unsigned(dsp_in_mul_operands(1)(15+16*(2*i+1)  downto 16*(2*i+1))));
            dsp_mul_b(31+32*(i)  downto 32*(i)) <= std_logic_vector((unsigned(dsp_in_mul_operands(0)(16*(2*i+1) - 1  downto 16*(2*i)))   * unsigned(dsp_in_mul_operands(1)(15+16*(2*i+1)  downto 16*(2*i+1)))) and unsigned(FUNCT_SELECT_MASK));
            dsp_mul_c(31+32*(i)  downto 32*(i)) <= std_logic_vector((unsigned(dsp_in_mul_operands(0)(15+16*(2*i+1)   downto 16*(2*i+1))) * unsigned(dsp_in_mul_operands(1)(16*(2*i+1) - 1 downto 16*(2*i))))   and unsigned(FUNCT_SELECT_MASK));
            dsp_mul_d(31+32*(i)  downto 32*(i)) <= std_logic_vector(unsigned(dsp_in_mul_operands(0)(16*(2*i+1)  - 1  downto 16*(2*i)))   * unsigned(dsp_in_mul_operands(1)(16*(2*i+1) - 1 downto 16*(2*i))));
          end loop;
        end if;
      end if;
    end if;
  end process;

  fsm_MUL_STAGE_1_COMB : process(all)
  begin
    mul_tmp_a <= (others => (others => '0'));
    mul_tmp_b <= (others => (others => '0'));
    mul_tmp_c <= (others => (others => '0'));
    mul_tmp_d <= (others => (others => '0'));
    -- KDOTP and KSVMUL instructions are handeled here
    -- this part right here shifts the intermidiate resutls appropriately, and then accumulates them in order to get the final mul result
    if mul_en = '1' and (mul_stage_2_en = '1' or recover_state_wires = '1') then
      for i in 0 to SIMD-1 loop
        if vec_width_DSP /= "10" then
          ------------------------------------------------------------------------------------
          mul_tmp_a(i) <= (dsp_mul_a(15+16*(2*i)  downto 16*(2*i)) & x"0000");
          mul_tmp_d(i) <= (x"0000" & dsp_mul_d(15+16*(2*i)  downto 16*(2*i)));
          ------------------------------------------------------------------------------------
        elsif vec_width_DSP = "10" then
          -- mul_tmp_a(i) <= (dsp_mul_a(31+32*(2*i)  downto 31*(2*i)) & x"0000");     -- The upper 32-bit results of the multiplication are discarded   (Ah*Bh)
          mul_tmp_b(i) <= (dsp_mul_b(15+16*(2*i) downto 16*(2*i)) & x"0000");         -- Modified to only add the partail result to the lower 32-bits   (Ah*Bl)
          mul_tmp_c(i) <= (dsp_mul_c(15+16*(2*i) downto 16*(2*i)) & x"0000");         -- Modified to only add the partail result to the lower 32-bits   (Al*Bh)
          mul_tmp_d(i) <= (dsp_mul_d(31+32*(i)   downto 32*(i)));                     -- This is the lower 32-bit result of the partial mmultiplication (Al*Bl)
        end if;
      end loop;
    end if;
  end process;

  -- STAGE 2 --
  fsm_MUL_STAGE_2 : process(clk_i, rst_ni)
  begin
	if rst_ni = '0' then
    elsif rising_edge(clk_i) then
      -- Accumulate the partial multiplications to make up bigger multiplications
      if mul_en = '1' and (mul_stage_2_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
        for i in 0 to SIMD-1 loop
          dsp_out_mul_results((Data_Width-1)+Data_Width*(i) downto Data_Width*(i))  <= (std_logic_vector(unsigned(mul_tmp_a(i)) + unsigned(mul_tmp_b(i)) + unsigned(mul_tmp_c(i)) + unsigned(mul_tmp_d(i))));
        end loop;
      end if;
    end if;
  end process;

  ----------------------------------------------------------
  --      ###       ######   ######  ##    ##  ###   ###  --
  --     #   #     ##       ##       ##    ##  ## # # ##  --
  --    #######    ##       ##       ##    ##  ##  #  ##  --
  --   ##     ##   ##       ##       ##    ##  ##     ##  --
  --  ##       ##   ######   ######   ######   ##     ##  --
  ----------------------------------------------------------


 ACCUM_STG : ACCUMULATOR
	port map(
      clk_i                             => clk_i,
      rst_ni                            => rst_ni,
      accum_stage_1_en                  => accum_stage_1_en,
      recover_state_wires               => recover_state_wires,
      halt_dsp_lat                      => halt_dsp_lat,
      state_DSP                         => state_DSP,
      decoded_instruction_DSP_lat       => decoded_instruction_DSP_lat,
      dsp_in_accum_operands             => dsp_in_accum_operands,
      dsp_out_accum_results             => dsp_out_accum_results
	);

--------------------------------------------
--  #######   #######  ##       ##    ##  --
--  ##     #  ##       ##       ##    ##  --
--  #######   ######   ##       ##    ##  --
--  ## ##     ##       ##       ##    ##  --
--  ##   ##   #######  #######   ######   --
--------------------------------------------
  fsm_RELU : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
    elsif rising_edge(clk_i) then
      if relu_en = '1' then
        if (relu_stage_1_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
          if    vec_width_DSP = "10" then
			for i in 0 to SIMD-1 loop
              if dsp_in_relu_operands(31+32*(i)) = '1' then
                dsp_out_relu_results(31+32*(i) downto 32*(i)) <= (others => '0');
              else
                dsp_out_relu_results(31+32*(i) downto 32*(i)) <= dsp_in_relu_operands(31+32*(i) downto 32*(i));
              end if;
            end loop;
          elsif vec_width_DSP = "01" then
			for i in 0 to 2*SIMD-1 loop
              if dsp_in_relu_operands(15+16*(i)) = '1' then
                dsp_out_relu_results(15+16*(i) downto 16*(i)) <= (others => '0');
              else
                dsp_out_relu_results(15+16*(i) downto 16*(i)) <= dsp_in_relu_operands(15+16*(i) downto 16*(i));
              end if;
            end loop;
          elsif vec_width_DSP = "00" then
			for i in 0 to 4*SIMD-1 loop
              if dsp_in_relu_operands(7+8*(i)) = '1' then
                dsp_out_relu_results(7+8*(i) downto 8*(i)) <= (others => '0');
              else
                dsp_out_relu_results(7+8*(i) downto 8*(i)) <= dsp_in_relu_operands(7+8*(i) downto 8*(i));
              end if;
            end loop;
          end if;
        end if;
      end if;
    end if;
  end process;

end DSP;
--------------------------------------------------------------------------------------------------
-- END of DSP architecture -----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------