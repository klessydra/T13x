library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;
entity WB_STAGE is
  port (
	   
      clk_i, rst_ni              : in std_logic;
	  LS_WB_EN                   : in std_logic;
	  IE_WB_EN                   : in std_logic;
	  IE_WB                      : in std_logic_vector(31 downto 0);
	  LS_WB                      : in std_logic_vector(31 downto 0);
	  instr_word_LS_WB           : in std_logic_vector(31 downto 0);
	  instr_word_IE_WB           : in std_logic_vector(31 downto 0);
	  instr_rvalid_WB            : in std_logic;
	  harc_LS_WB                 : in harc_range;
	  harc_IE_WB                 : in harc_range;
	  regfile                    : out regfile_replicated_array
       );
end entity; 
architecture WRITEBACK of WB_STAGE is
signal WB_RD            : std_logic_vector(31 downto 0);
signal WB_EN            : std_logic;
signal harc_WB          : harc_range;
signal instr_word_WB    : std_logic_vector(31 downto 0);
begin
  harc_WB <= harc_LS_WB when LS_WB_EN = '1' else harc_IE_WB when IE_WB_EN = '1';
  instr_word_WB <= instr_word_LS_WB when LS_WB_EN = '1' else instr_word_IE_WB when IE_WB_EN = '1';
  WB_EN <= '1' when (LS_WB_EN = '1' or IE_WB_EN = '1') else '0';
  WB_RD <= IE_WB when IE_WB_EN = '1' else LS_WB when LS_WB_EN = '1';  
  fsm_WB_seq : process(clk_i, rst_ni)
	  
  variable regfile_wire : regfile_replicated_array;
  begin
    if rst_ni = '0' then
      for index in 0 to 31
      loop
        for h in harc_range loop
          regfile_wire(h)(index) := std_logic_vector(to_unsigned(0, 32));
        end loop;
      end loop;
    elsif rising_edge(clk_i) then
      if WB_EN = '1' then 
        regfile_wire(harc_WB)(rd(instr_word_WB)) := WB_RD;
      end if;
    end if;
  regfile <= regfile_wire;
  end process;
end WRITEBACK;
