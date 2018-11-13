-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

-- local packages ------------
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

-- pipeline  pinout --------------------
entity IF_STAGE is
  port (
    pc_IF                      : in  std_logic_vector(31 downto 0);
    harc_IF                    : in  harc_range;
    dbg_halted_o               : in  std_logic; 
	busy_ID                    : in  std_logic;
	instr_rvalid_i             : in std_logic;  
    harc_ID                    : out harc_range;
    pc_ID_lat                  : out std_logic_vector(31 downto 0);  -- pc_ID is PC entering ID stage
    instr_rvalid_ID            : out std_logic; 
	instr_word_ID_lat          : out std_logic_vector(31 downto 0);
	harc_ID_lat                : out harc_range;
    -- clock, reset active low
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic;
    -- program memory interface
    instr_req_o                : out std_logic;
    instr_gnt_i                : in  std_logic;
    instr_addr_o               : out std_logic_vector(31 downto 0);
    instr_rdata_i              : in  std_logic_vector(31 downto 0);
    -- debug interface
    debug_halted_o             : out std_logic
    );
end entity;  ------------------------------------------


-- Klessydra T03x (4 stages) pipeline implementation -----------------------
architecture FETCH of IF_STAGE is

  -- state signals
  type fsm_IF_states is (normal, waiting);

  signal state_IF, nextstate_IF : fsm_IF_states;
  signal instr_rvalid_state     : std_logic;
  signal pc_ID     : std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------------------------
----------------------- ARCHITECTURE BEGIN -------------------------------------------------------
begin

  instr_addr_o <= pc_IF;


  debug_halted_o <= dbg_halted_o;
----------------------------------------------------------------------------------------------------
-- stage IF -- (instruction fetch)
----------------------------------------------------------------------------------------------------
-- This pipeline stage is implicitly present as the program memory is synchronous
-- with 1 cycle latency.
-- The fsm_IF manages the interface with program memory. 
-- The PC_IF is updated by a dedicated unit which is transparent to the fsm_IF.
----------------------------------------------------------------------------------------------------

  fsm_IF_nextstate : process(all)  -- acts as the control unit of the synchronous program memory
  begin
    if rst_ni = '0' then
      instr_req_o  <= '0';
      nextstate_IF <= normal;
    else
      case state_IF is
        when normal =>
          if busy_ID = '0' then
            instr_req_o <= '1';
            if instr_gnt_i = '1' then
              nextstate_IF <= normal;
            else
              nextstate_IF <= waiting;
            end if;
          else
            instr_req_o  <= '0';
            nextstate_IF <= normal;
          end if;
        when waiting =>
          if busy_ID = '0' then
            instr_req_o <= '1';
            if instr_gnt_i = '1' then
              nextstate_IF <= normal;
            else
              nextstate_IF <= waiting;
            end if;
          else
            instr_req_o  <= '0';
            nextstate_IF <= normal;
          end if;
          -- in the above code, in case of stall during a wait, the present access is aborted, 
          -- the instr_gnt will not come and the pc is not updated. Next access will repeat
          -- with same pc value. OK. This depends on how the memory works when req signal is aborted, 
          -- a more conservative implementation is needed if we want to be 100% sure 
          -- of correct operation

        when others =>                  -- should never occur
          nextstate_IF <= normal;
          instr_req_o  <= '0';
      end case;
    end if;
  end process;

  fsm_IF_register_state : process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      state_IF <= normal;
    elsif rising_edge(clk_i) then
      state_IF <= nextstate_IF;
    end if;
  end process;


  process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      pc_ID        <= (others => '0');
      harc_ID <= 0;
    elsif rising_edge(clk_i) then
      if instr_gnt_i = '1' then
        -- pc propagation
        pc_ID   <= pc_IF;
        -- harc propagation
        harc_ID <= harc_IF;
      end if;
    end if;
  end process;

  -- instr_rvalid_ID controller, needed to keep instr_valid_ID set during 
  -- stalls of the fetch stage. This is a synthesized mealy fsm
  process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      instr_rvalid_state <= '0';
    elsif rising_edge(clk_i) then
      instr_rvalid_state <= busy_ID and (instr_rvalid_i or instr_rvalid_state);
    end if;
  end process;
  instr_rvalid_ID <= (instr_rvalid_i or instr_rvalid_state);

  -- latch ir on program memory output, because memory output remains for 1 cycle only
  instr_word_ID_lat  <= instr_rdata_i when instr_rvalid_i = '1';
  -- latches just to have pc, harc and ir updated together, probably useless
  pc_ID_lat          <= pc_ID      when instr_rvalid_ID = '1' else (others => '0') when rst_ni = '0';
  harc_ID_lat        <= harc_ID    when instr_rvalid_ID = '1' else 0 when rst_ni = '0';

--------------------------------------------------------------------- end of IF stage ---------------
-----------------------------------------------------------------------------------------------------
end FETCH;
-----------------------------------------------------------------------------------------------------