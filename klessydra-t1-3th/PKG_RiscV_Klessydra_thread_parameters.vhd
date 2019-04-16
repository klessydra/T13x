-----------------------------------------------------------------------------------------
-- Klessydra core family multi-threading definitions.
-- Fundamental micro-architecture parameter values: 
-- THREAD_ID_SIZE: max hardware context id length in bits.
-- THREAD_POOL_SIZE: maximum number of threads allowed in the microarchitecture
-- NOP_POOL_SIZE (i.e. THREAD_POOL_BASELINE): minimum number of active threads for safe pipeline operation
-- The relation NOP_POOL_SIZE + THREAD_POOL_SIZE - 1 < 2**THREAD_ID_SIZE must hold.
-----------------------------------------------------------------------------------------


library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

package thread_parameters_klessydra is

  type array_2d is array (integer range<>) of std_logic_vector;
  type array_3d is array (integer range<>) of array_2d;

  constant THREAD_ID_SIZE   : integer := 4;
  
  constant THREAD_POOL_SIZE : integer := 3;  -- Changing the TPS to less than "pipeline stage-1" is not allowed. And making it bigger than "pipeline stage-1" is okay but not recommended
  constant NOP_POOL_SIZE    : integer := 2;  -- should be static and not touched, unless the number of pipeline stages changes; presently unused

  constant BRANCHING_DELAY_SLOT    : integer := 3;  -- should be static and not touched, unless the number of pipeline stages change

  constant HARC_SIZE : integer := THREAD_POOL_SIZE; -- for the moment we do not implement "nop" threads 
  subtype harc_range is integer range THREAD_POOL_SIZE - 1 downto 0;  -- will be used replicated units in the core 

  -----------------------------------------------------------------------
  --    ######   #####   ###    ##  #######  #####   ######    ######  --
  --   ##       #     #  ## #   ##  ##         #    ##        ##       --
  --   ##       #     #  ##  #  ##  #####      #    ##  ####   #####   --
  --   ##       #     #  ##   # ##  ##         #    ##    ##       ##  --
  --    ######   #####   ##    ###  ##       #####   ######   ######   --
  -----------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  constant RF_SIZE        : natural := 32;  -- Regfile size, Can be set to 32 for RV32I or 16 for RV32E
  constant SPM_NUM		  : natural := 4;   -- The number of scratchpads available "Minimum allowed is two"
  constant Addr_Width     : natural := 12;   -- This address is for scratchpads. Setting this will make the size of the spm to be: "2^Addr_Width -1"
  constant SPM_STRT_ADDR  : std_logic_vector(31 downto 0) := x"1000_0000";  -- This is starting address of the spms, it shouldn't be bigger than 2^32, and shouldn't overlap any sections in the memory map
  constant SIMD           : natural := 4;   -- Changing the SIMD, would change the number of the functional units in the dsp, and the number of banks in the spms (can be power of 2 only e.g. 1,2,4,8)
  constant MCYCLE_EN      : natural := 1;   -- Can be set to 1 or 0 only. Setting to zero will disable MCYCLE and MCYCLEH
  constant MINSTRET_EN    : natural := 1;   -- Can be set to 1 or 0 only. Setting to zero will disable MINSTRET and MINSTRET
  constant MHPMCOUNTER_EN : natural := 1;   -- Can be set to 1 or 0 only. Setting to zero will disable all the other program counters
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  constant RF_CEIL        : natural := integer(ceil(log2(real(RF_SIZE))));
  constant SPM_ADDR_WID   : natural := integer(ceil(log2(real(SPM_NUM+1)))); 
  constant SIMD_BITS      : natural := integer(ceil(log2(real(SIMD))));
  constant Data_Width     : natural := 32;
  constant SIMD_Width    : natural := SIMD*Data_Width;

  --constant XLEN    : natural := 32;  -- aaa use this instead of Data_Width, the name is shorter and more convenient

  type dsp_states is (dsp_init, dsp_exec);
  type fsm_LS_states is (normal , data_valid_waiting);

end package;

  
