library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

-- local packages ------------
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;


---------------------------------------------------------------------------------------------------
entity Scratchpad_memory is
  port(
       clk_i                         : in  std_logic;
       sc_we                         : in  std_logic_vector(4*Num_SCs-1 downto 0);
       sc_addr_rd                    : in  array_2d(4*Num_SCs-1 downto 0)(Addr_Width -1 downto 0);
       sc_addr_wr                    : in  array_2d(4*Num_SCs-1 downto 0)(Addr_Width -1 downto 0);
       sc_data_wr                    : in  array_2d(4*Num_SCs-1 downto 0)(Data_Width/4 -1 downto 0);
       sc_data_rd                    : out array_2d(4*Num_SCs-1 downto 0)(Data_Width/4 -1 downto 0)
       );
end Scratchpad_memory;

---------------------------------------------------------------------------------------------------
architecture SC of Scratchpad_memory is

signal mem : array_3d(4*Num_SCs-1 downto 0)(2**7 -1  downto 0)(Data_Width/4-1 downto 0);
attribute ram_style : string;
attribute ram_style of mem : signal is "block";

begin

 --------- replicate logic three times --------------------------------
  sc_mem : for h in 0 to 4*NUM_SCs -1 generate 
    
    write_logic: process(clk_i) -- 
    begin
      if(clk_i'event and clk_i='1') then
         sc_data_rd(h) <= mem(h)(to_integer(unsigned(sc_addr_rd(h)(8 downto 0))));
        if sc_we(h) = '1' then         --write mode
          mem(h)(to_integer(unsigned(sc_addr_wr(h)(8 downto 0)))) <= sc_data_wr(h);
        end if; -- we
      end if; -- clk
    end process;

    --read_logic: process (all) -- reading is combinational, like a reg. file 
    --begin
      --sc_data_rd(h) <= mem(h)(to_integer(unsigned(sc_addr_rd(h)(8 downto 0)))); 
    --end process;
    
  end generate sc_mem;
  -- end of replicated logic --------------------------------------------

end SC;

