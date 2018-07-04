library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;
entity IF_STAGE is
  port (
    pc_IF                      : in  std_logic_vector(31 downto 0);
    harc_IF                    : in  harc_range;
    dbg_halted_o               : in  std_logic; 
	busy_ID                    : in  std_logic;
	instr_rvalid_i             : in std_logic;  
    harc_ID                    : out harc_range;
    pc_ID_lat                  : out std_logic_vector(31 downto 0);  
    instr_rvalid_ID            : out std_logic; 
	instr_word_ID_lat          : out std_logic_vector(31 downto 0);
	harc_ID_lat                : out harc_range;
    
    clk_i                      : in  std_logic;
    rst_ni                     : in  std_logic;
    
    instr_req_o                : out std_logic;
    instr_gnt_i                : in  std_logic;
    instr_addr_o               : out std_logic_vector(31 downto 0);
    instr_rdata_i              : in  std_logic_vector(31 downto 0);
    
    debug_halted_o             : out std_logic
    );
end entity;  
architecture FETCH of IF_STAGE is
  
  type fsm_IF_states is (normal, waiting);
  signal state_IF, nextstate_IF : fsm_IF_states;
  signal instr_rvalid_state     : std_logic;
  signal pc_ID     : std_logic_vector(31 downto 0);
begin
  instr_addr_o <= pc_IF;
  debug_halted_o <= dbg_halted_o;
  fsm_IF_nextstate : process(all)  
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
          
          
          
          
          
        when others =>                  
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
        
        pc_ID   <= pc_IF;
        
        harc_ID <= harc_IF;
      end if;
    end if;
  end process;
  
  
  process(clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      instr_rvalid_state <= '0';
    elsif rising_edge(clk_i) then
      instr_rvalid_state <= busy_ID and (instr_rvalid_i or instr_rvalid_state);
    end if;
  end process;
  instr_rvalid_ID <= (instr_rvalid_i or instr_rvalid_state);
  
  instr_word_ID_lat  <= instr_rdata_i when instr_rvalid_i = '1';
  
  pc_ID_lat          <= pc_ID      when instr_rvalid_ID = '1' else (others => '0') when rst_ni = '0';
  harc_ID_lat        <= harc_ID    when instr_rvalid_ID = '1' else 0 when rst_ni = '0';
end FETCH;
