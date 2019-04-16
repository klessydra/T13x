-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

-- local packages ------------
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

entity ACCUMULATOR is
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
end entity;
-- AAA maybe replace decoded_instruction_DSP_lat with vec_width_dsp
architecture ACCUM_STG of ACCUMULATOR is
begin

  DOTP_SIMD_1 : if SIMD=1 generate
    fsm_ACCUM_STAGE : process(clk_i, rst_ni)
    begin
      if rst_ni = '0' then
      elsif rising_edge(clk_i) then
        case state_DSP is
	  		
          when dsp_init =>
  
            dsp_out_accum_results <= (others => '0');
  
          when dsp_exec =>
  
            if (accum_stage_1_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
              if decoded_instruction_DSP_lat(KDOTP32_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS32_bit_position) = '1' then
                dsp_out_accum_results <= std_logic_vector(unsigned(dsp_in_accum_operands(31 downto 0))  +
                                                unsigned(dsp_out_accum_results));
              elsif decoded_instruction_DSP_lat(KDOTP16_bit_position)   = '1' or decoded_instruction_DSP_lat(KDOTP8_bit_position)    = '1' or
				    decoded_instruction_DSP_lat(KDOTPPS16_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS8_bit_position)  = '1' then
                dsp_out_accum_results <= std_logic_vector((unsigned(dsp_in_accum_operands(15 downto 0)))   + (unsigned(dsp_in_accum_operands(31 downto 16)))   +
                                                unsigned(dsp_out_accum_results));
              end if;
            end if;
          when others =>
            null;
        end case;
      end if;
    end process;
  end generate;

  DOTP_SIMD_2 : if SIMD=2 generate
    fsm_ACCUM_STAGE : process(clk_i, rst_ni)
    begin
      if rst_ni = '0' then
      elsif rising_edge(clk_i) then
        case state_DSP is
	  		
          when dsp_init =>
  
            dsp_out_accum_results <= (others => '0');
  
          when dsp_exec =>
  
            if (accum_stage_1_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
              if decoded_instruction_DSP_lat(KDOTP32_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS32_bit_position) = '1' then
                dsp_out_accum_results <= std_logic_vector((unsigned(dsp_in_accum_operands(31 downto 0))  + unsigned(dsp_in_accum_operands(63  downto 32))) +
                                                unsigned(dsp_out_accum_results));
              elsif decoded_instruction_DSP_lat(KDOTP16_bit_position)   = '1' or decoded_instruction_DSP_lat(KDOTP8_bit_position)    = '1' or
				    decoded_instruction_DSP_lat(KDOTPPS16_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS8_bit_position)  = '1' then
                dsp_out_accum_results <= std_logic_vector((unsigned(dsp_in_accum_operands(15 downto 0)))   + (unsigned(dsp_in_accum_operands(31 downto 16)))   +
                                               (unsigned(dsp_in_accum_operands(47 downto 32)))  + (unsigned(dsp_in_accum_operands(63 downto 48)))   +
                                                unsigned(dsp_out_accum_results));
              end if;
            end if;
          when others =>
            null;
        end case;
      end if;
    end process; 
  end generate;

  DOTP_SIMD_4 : if SIMD=4 generate
    fsm_ACCUM_STAGE : process(clk_i, rst_ni)
    begin
      if rst_ni = '0' then
      elsif rising_edge(clk_i) then
        case state_DSP is
	  		
          when dsp_init =>
  
            dsp_out_accum_results <= (others => '0');
  
          when dsp_exec =>
  
            if (accum_stage_1_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
              if decoded_instruction_DSP_lat(KDOTP32_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS32_bit_position) = '1' then
                dsp_out_accum_results <= std_logic_vector((unsigned(dsp_in_accum_operands(31 downto 0))  + unsigned(dsp_in_accum_operands(63  downto 32))) +
                                                          (unsigned(dsp_in_accum_operands(95 downto 64)) + unsigned(dsp_in_accum_operands(127 downto 96))) +
                                                           unsigned(dsp_out_accum_results));
              elsif decoded_instruction_DSP_lat(KDOTP16_bit_position)   = '1' or decoded_instruction_DSP_lat(KDOTP8_bit_position)    = '1' or
				    decoded_instruction_DSP_lat(KDOTPPS16_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS8_bit_position)  = '1' then
                dsp_out_accum_results <= std_logic_vector((unsigned(dsp_in_accum_operands(15 downto 0)))   + (unsigned(dsp_in_accum_operands(31 downto 16)))   +
                                                          (unsigned(dsp_in_accum_operands(47 downto 32)))  + (unsigned(dsp_in_accum_operands(63 downto 48)))   +
                                                          (unsigned(dsp_in_accum_operands(79 downto 64)))  + (unsigned(dsp_in_accum_operands(95 downto 80)))   +
                                                          (unsigned(dsp_in_accum_operands(111 downto 96))) + (unsigned(dsp_in_accum_operands(127 downto 112))) +
                                                           unsigned(dsp_out_accum_results));
              end if;
            end if;
          when others =>
            null;
        end case;
      end if;
    end process;
  end generate;

  DOTP_SIMD_8 : if SIMD=8 generate
    fsm_ACCUM_STAGE : process(clk_i, rst_ni)
    begin
      if rst_ni = '0' then
      elsif rising_edge(clk_i) then
        case state_DSP is
	  		
          when dsp_init =>
  
            dsp_out_accum_results <= (others => '0');
  
          when dsp_exec =>
  
            if (accum_stage_1_en = '1' or recover_state_wires = '1') and halt_dsp_lat = '0' then
              if decoded_instruction_DSP_lat(KDOTP32_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS32_bit_position) = '1' then
                dsp_out_accum_results <= std_logic_vector((unsigned(dsp_in_accum_operands(31 downto 0))    + unsigned(dsp_in_accum_operands(63  downto 32)))   +
                                                          (unsigned(dsp_in_accum_operands(95 downto 64))   + unsigned(dsp_in_accum_operands(127 downto 96)))   +
                                                          (unsigned(dsp_in_accum_operands(159 downto 128)) + unsigned(dsp_in_accum_operands(191  downto 160))) +
                                                          (unsigned(dsp_in_accum_operands(223 downto 192)) + unsigned(dsp_in_accum_operands(255 downto 224)))  +
                                                           unsigned(dsp_out_accum_results));
              elsif decoded_instruction_DSP_lat(KDOTP16_bit_position)   = '1' or decoded_instruction_DSP_lat(KDOTP8_bit_position)    = '1' or
				    decoded_instruction_DSP_lat(KDOTPPS16_bit_position) = '1' or decoded_instruction_DSP_lat(KDOTPPS8_bit_position)  = '1' then
                dsp_out_accum_results <= std_logic_vector((unsigned(dsp_in_accum_operands(15 downto 0)))    + (unsigned(dsp_in_accum_operands(31 downto 16)))     +
                                                          (unsigned(dsp_in_accum_operands(47 downto 32)))   + (unsigned(dsp_in_accum_operands(63 downto 48)))     +
                                                          (unsigned(dsp_in_accum_operands(79 downto 64)))   + (unsigned(dsp_in_accum_operands(95 downto 80)))     +
                                                          (unsigned(dsp_in_accum_operands(111 downto 96)))  + (unsigned(dsp_in_accum_operands(127 downto 112)))   +
                                                          (unsigned(dsp_in_accum_operands(143 downto 128))) + (unsigned(dsp_in_accum_operands(159 downto 144)))   +
                                                          (unsigned(dsp_in_accum_operands(175 downto 160))) + (unsigned(dsp_in_accum_operands(191 downto 176)))   +
                                                          (unsigned(dsp_in_accum_operands(207 downto 192))) + (unsigned(dsp_in_accum_operands(223 downto 208)))   +
                                                          (unsigned(dsp_in_accum_operands(239 downto 224))) + (unsigned(dsp_in_accum_operands(255 downto 240)))   +
                                                           unsigned(dsp_out_accum_results));
              end if;
            end if;
          when others =>
            null;
        end case;
      end if;
    end process;
  end generate;

end ACCUM_STG;
