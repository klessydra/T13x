-----------------------------------------------------------------------------------------
-- Klessydra core family multi-threading definitions.
-- Fundamental micro-architecture parameter values: 
-- THREAD_ID_SIZE: max hardware context id length in bits.
-- THREAD_POOL_SIZE: maximum number of threads allowed in the microarchitecture
-- NOP_POOL_SIZE (i.e. THREAD_POOL_BASELINE): minimum number of active threads for safe pipeline operation
-- The relation NOP_POOL_SIZE + THREAD_POOL_SIZE - 1 < 2**THREAD_ID_SIZE must hold.
-----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package thread_parameters_klessydra is

  constant THREAD_ID_SIZE   : integer := 4;
  
  constant THREAD_POOL_SIZE : integer := 3;
  constant NOP_POOL_SIZE    : integer := 2;  -- should be static and not touched, unless the number of pipeline stages change; presently unused

  constant BRANCHING_DELAY_SLOT    : integer := 3;  -- should be static and not touched, unless the number of pipeline stages change

  constant HARC_SIZE : integer := THREAD_POOL_SIZE; -- for the moment we do not implement "nop" threads 
  subtype harc_range is integer range THREAD_POOL_SIZE - 1 downto 0;  -- will be used replicated units in the core 

end package;

  
