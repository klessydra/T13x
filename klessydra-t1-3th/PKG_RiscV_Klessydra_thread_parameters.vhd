library ieee;
use ieee.std_logic_1164.all;

package thread_parameters_klessydra is

  constant THREAD_ID_SIZE   : integer := 4;
  
  constant THREAD_POOL_SIZE : integer := 3;
  constant NOP_POOL_SIZE    : integer := 2;

  constant BRANCHING_DELAY_SLOT    : integer := 3;

  constant HARC_SIZE : integer := THREAD_POOL_SIZE;
  subtype harc_range is integer range THREAD_POOL_SIZE - 1 downto 0;

end package;

  
