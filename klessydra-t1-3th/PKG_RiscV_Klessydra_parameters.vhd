----------------------------------------------------------------------------------------------------------------
-- Klessydra core family parameter definitions.                                                               --
-- Fundamental micro-architecture parameter values:                                                           --
-- THREAD_POOL_SIZE: maximum number of threads allowed in the microarchitecture                               --
-- RV32M: Enables the MUL/DIV RISC-V Extension                                                                --
-- RV32E: Enables the emeeeded extension of the RISC-V Extension                                              --
-- accl_en: enables the generation of the custom hardware acceelerator, that executes the custom K-extension  --
-- Other configurations to the T13 are described below                                                        --
----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

package klessydra_parameters is

---------------------------------------------------------------
--   ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ ███████╗  --
--  ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ ██╔════╝  --
--  ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗███████╗  --
--  ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║╚════██║  --
--  ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝███████║  --
--   ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝  --
---------------------------------------------------------------                                                         

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
generic (debug_en              : natural := 1;
		 LUTRAM_RF             : natural := 0);
--  THREAD_POOL_SIZE      : integer := 3;   -- Changing the TPS to less than "number of pipeline stages-1" is not allowed. And making it bigger than "pipeline stages-1" is okay but not recommended
--  RV32E                 : natural := 0;   -- Regfile size, Can be set to 32 for RV32E being 0 else 16 for RV32E being set to 1
--  RV32M                 : natural := 1;   -- Enable the M-extension of the risc-v instruction set
--  accl_en               : natural := 1;   -- Enable the generation of the special purpose accelerator
--  replicate_accl_en     : natural := 0;   -- Set to 1 to replicate the accelerator for every thread
--  multithreaded_accl_en : natural := 0;   -- Set to 1 to let the replicated accelerator share the functional units (note: replicate_accl_en must be set to '1')
--  SPM_NUM		        : natural := 3;   -- The number of scratchpads available "Minimum allowed is two"
--  Addr_Width            : natural := 12;  -- This address is for scratchpads. Setting this will make the size of the spm to be: "2^Addr_Width -1"
--  SPM_STRT_ADDR         : std_logic_vector(31 downto 0) := x"1000_0000";  -- This is starting address of the spms, it shouldn't overlap any sections in the memory map
--  SIMD                  : natural := 1;   -- Changing the SIMD, would change the number of the functional units in the dsp, and the number of banks in the spms (can be power of 2 only e.g. 1,2,4,8)
--  MCYCLE_EN             : natural := 1;   -- Can be set to 1 or 0 only. Setting to zero will disable MCYCLE and MCYCLEH
--  MINSTRET_EN           : natural := 1;   -- Can be set to 1 or 0 only. Setting to zero will disable MINSTRET and MINSTRETH
--  MHPMCOUNTER_EN        : natural := 1;   -- Can be set to 1 or 0 only. Setting to zero will disable all performance counters except "MCYCLE/H" and "MINSTRET/H"
--  count_all             : natural := 1;   -- Perfomance counters count for all the harts instead of there own hart
--  debug_en              : natural := 1   -- Generates the debug unit
--);
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

end package;

  
