-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

-- local packages ------------
use work.riscv_klessydra.all;
use work.thread_parameters_klessydra.all;

-- SCI  pinout --------------------
entity Scratchpad_memory_interface is
  port (
    clk_i, rst_ni              : in std_logic;
    data_rvalid_i              : in std_logic;
    state_LS                   : in fsm_LS_states;
    dsp_we_word                : in std_logic_vector(SIMD-1 downto 0);
    ls_sc_data_write_wire      : in std_logic_vector(Data_Width-1 downto 0);
    dsp_sc_data_write_wire     : in std_logic_vector(SIMD_Width-1 downto 0);
    ls_sc_read_addr            : in std_logic_vector(Addr_Width - (SIMD_BITS+3) downto 0);
    ls_sc_write_addr           : in std_logic_vector(Addr_Width - (SIMD_BITS+3) downto 0);
    dsp_sc_write_addr          : in std_logic_vector(Addr_Width - 1 downto 0);
    ls_sci_req                 : in std_logic_vector(SPM_NUM-1 downto 0);
    ls_sci_we                  : in std_logic_vector(SPM_NUM-1 downto 0);
    dsp_sci_req                : in std_logic_vector(SPM_NUM-1 downto 0);
    dsp_sci_we                 : in std_logic_vector(SPM_NUM-1 downto 0);
    dsp_to_sc                  : in  array_2d(SPM_NUM-1 downto 0)(1 downto 0);
    dsp_sc_read_addr           : in  array_2d(1 downto 0)(Addr_Width -1 downto 0);
    dsp_sc_data_read           : out array_2d(1 downto 0)(SIMD_Width -1 downto 0);
    ls_sc_data_read_wire       : out std_logic_vector(Data_Width - 1 downto 0);
    ls_sci_wr_gnt              : out std_logic;
    dsp_sci_wr_gnt             : out std_logic;
    ls_data_gnt_i              : out std_logic_vector(SPM_NUM-1 downto 0);
    dsp_data_gnt_i             : out std_logic
	);
end entity;  ------------------------------------------


architecture SCI of Scratchpad_memory_interface is

signal dsp_sc_data_write_int_wire : std_logic_vector(SIMD_Width-1 downto 0);
signal rd_offset                  : array_2d(1 downto 0)(SIMD-1 downto 0);
signal wr_offset                  : std_logic_vector(SIMD-1 downto 0);
signal dsp_sc_data_read_int_wire  : array_2d(1 downto 0)(SIMD_Width-1 downto 0);
signal dsp_sc_read_addr_lat       : array_2d(1 downto 0)(SIMD_BITS+1 downto 0);  --  Only need the lower part to check for the word access
signal dsp_sci_req_lat            : std_logic_vector(SPM_NUM-1 downto 0);
signal dsp_to_sc_lat              : array_2d(SPM_NUM-1 downto 0)(1 downto 0);
signal dsp_sc_data_read_wire      : array_2d(1 downto 0)(SIMD_Width-1 downto 0);
signal ls_sc_data_read            : std_logic_vector(Data_Width-1 downto 0);
signal dsp_sci_wr_gnt_lat         : std_logic;
signal ls_sci_wr_gnt_lat          : std_logic;
signal halt_dsp                   : std_logic;
signal sc_cycle_lat               : std_logic_vector(SIMD_BITS-1 downto 0);
signal sc_cycle                   : std_logic_vector(SIMD_BITS-1 downto 0);
signal sc_addr_rd                 : array_2d(SIMD*SPM_NUM-1 downto 0)(Addr_Width-(SIMD_BITS+3) downto 0);
signal sc_addr_wr                 : array_2d(SIMD*SPM_NUM-1 downto 0)(Addr_Width-(SIMD_BITS+3) downto 0);
signal sc_data_rd                 : array_2d(SIMD*SPM_NUM-1 downto 0)(31 downto 0);
signal sc_data_wr                 : array_2d(SIMD*SPM_NUM-1 downto 0)(31 downto 0);
signal sc_we                      : std_logic_vector(SIMD*SPM_NUM-1 downto 0);

component Scratchpad_memory
  port(
    clk_i                         : in   std_logic;
    sc_we                         : in   std_logic_vector(SIMD*SPM_NUM-1 downto 0);
    sc_addr_rd                    : in   array_2d(SIMD*SPM_NUM-1 downto 0)(Addr_Width-(SIMD_BITS+3) downto 0);
    sc_addr_wr                    : in   array_2d(SIMD*SPM_NUM-1 downto 0)(Addr_Width-(SIMD_BITS+3) downto 0);
    sc_data_rd                    : out  array_2d(SIMD*SPM_NUM-1 downto 0)(Data_Width-1 downto 0);
    sc_data_wr                    : in   array_2d(SIMD*SPM_NUM-1 downto 0)(Data_Width-1 downto 0)
    );
end component;
--------------------------------------------------------------------------------------------------
-------------------------------- SCI BEGIN -------------------------------------------------------
begin

  SC : Scratchpad_memory
    port map(
       sc_we            => sc_we,
       clk_i            => clk_i,
       sc_addr_rd       => sc_addr_rd,
       sc_addr_wr       => sc_addr_wr,
       sc_data_wr       => sc_data_wr,
       sc_data_rd       => sc_data_rd
      );
  
  SCI_Exec_Unit : process(clk_i, rst_ni)  -- single cycle unit, fully synchronous 
  begin
    if rst_ni = '0' then
      dsp_sc_read_addr_lat <= (others => (others => '0'));
      dsp_to_sc_lat        <= (others => (others => '0'));
      ls_data_gnt_i        <= (others => '0');
      dsp_sci_req_lat      <= (others => '0');
      sc_cycle_lat         <= (others => '0');
      sc_cycle             <= (others => '0');
    elsif rising_edge(clk_i) then
      halt_dsp             <= '0';
      dsp_sci_wr_gnt_lat   <= dsp_sci_wr_gnt;
      ls_sci_wr_gnt_lat    <= ls_sci_wr_gnt;
      dsp_sci_req_lat      <= dsp_sci_req;
      dsp_to_sc_lat        <= dsp_to_sc;
      sc_cycle_lat         <= sc_cycle; 
      if state_LS = normal then
        sc_cycle <= (others => '0');     
      end if;
      if to_integer(unsigned(ls_data_gnt_i)) /= 0 then
        ls_sc_data_read  <= ls_sc_data_read_wire;
      end if;
      if (dsp_sci_wr_gnt = '0' and dsp_sci_we /= (0 to SPM_NUM-1 => '0')) then
        halt_dsp <= '1';
      end if;
      if halt_dsp = '0' then
        dsp_sc_data_read     <= dsp_sc_data_read_wire;
      end if;

      for i in 0 to SPM_NUM-1 loop
	    if dsp_sci_req(i) = '1' then 
          for k in 0 to 1 loop
            dsp_sc_read_addr_lat(k) <= dsp_sc_read_addr(k)(SIMD_BITS+1 downto 0);
          end loop;
        end if;
        if ls_sci_req(i) = '1' then      -- AAA remember to change to dsp_gnt_i
          ls_data_gnt_i(i) <= '1';
        elsif ls_sci_req(i) = '0' then
          ls_data_gnt_i(i) <= '0';
        end if;
        if ls_sci_we(i) = '1' then            -- Scratchpad bank selector, interleave within the banks
          if data_rvalid_i = '1' then
            if to_integer(unsigned(sc_cycle)) = SIMD-1 then
              sc_cycle <= (others => '0');         
            else
              sc_cycle <= std_logic_vector(unsigned(sc_cycle)+'1');
            end if;
          end if;
        elsif ls_sci_we(i) = '0' and ls_sci_req(i) = '1' then
          if to_integer(unsigned(sc_cycle)) = SIMD-1 then
            sc_cycle <= (others => '0');         
          else
            sc_cycle <= std_logic_vector(unsigned(sc_cycle)+'1');
          end if;
        end if;
      end loop;
    end if;
  end process;

  SCI_Exec_Unit_comb : process(all)

  begin
    dsp_data_gnt_i             <= '0';
    sc_we                      <= (others => '0');
    sc_addr_rd                 <= (others => (others => '0'));
    sc_addr_wr                 <= (others => (others => '0'));
    sc_data_wr                 <= (others => (others => '0'));
    rd_offset                  <= (others => (others => '0'));
    dsp_sc_data_read_int_wire  <= (others => (others => '0'));
    wr_offset                  <= (others => '0');
	ls_sci_wr_gnt              <= ls_sci_wr_gnt_lat;
	dsp_sci_wr_gnt             <= dsp_sci_wr_gnt_lat;
    ls_sc_data_read_wire       <= ls_sc_data_read;
	dsp_sc_data_write_int_wire <= (others => '0');
    dsp_sc_data_read_wire      <= dsp_sc_data_read;
    for i in 0 to SPM_NUM-1 loop	-- Loop through scratchpads A,B,C,D

      if data_rvalid_i = '1' then        -- LS write port
        if ls_sci_req(i) = '1' and ls_sci_we(i) = '1' and ls_sci_wr_gnt = '1' then
          sc_we((SIMD)*i + to_integer(unsigned(sc_cycle))) <= '1';
          sc_data_wr(to_integer(unsigned(sc_cycle)) + (SIMD)*i) <= ls_sc_data_write_wire(31 downto 0);
          sc_addr_wr(to_integer(unsigned(sc_cycle)) + (SIMD)*i) <= ls_sc_write_addr;
        end if;   
      end if;
      if ls_data_gnt_i(i) = '1' then
        ls_sc_data_read_wire <= sc_data_rd((SIMD)*i + to_integer(unsigned(sc_cycle_lat)));  -- sc_cycle_lat because data being read is delayed one cycle after the request
      end if;

      if ls_sci_req(i) = '1' then         -- LS read port
        sc_addr_rd(to_integer(unsigned(sc_cycle)) + (SIMD)*i) <= ls_sc_read_addr;
      end if;

      if dsp_sci_we(i) = '1' and dsp_sci_wr_gnt = '1' then         -- DSP write port;
        for j in 0 to SIMD-1 loop        -- Loop through the sub-scratchpads
          sc_we((SIMD)*i+j) <= dsp_we_word(j);
          sc_addr_wr((SIMD)*i+j) <= std_logic_vector(unsigned(dsp_sc_write_addr(Addr_Width - 1 downto SIMD_BITS+2)) + wr_offset(j));
          sc_data_wr((SIMD)*i+j) <= dsp_sc_data_write_int_wire(31+32*j downto 32*j);
        end loop;
      end if;   

      if dsp_sci_req(i) = '1' and dsp_to_sc(i)(0) = '1' then         -- DSP read port 1
        for j in 0 to SIMD-1 loop      -- Loop through the sub-scratchpads
          sc_addr_rd((SIMD)*i+j) <= std_logic_vector(unsigned(dsp_sc_read_addr(0)(Addr_Width - 1 downto SIMD_BITS+2)) + rd_offset(0)(j));
        end loop;
      end if;
      for j in 0 to SIMD-1 loop        -- Loop through the sub-scratchpads
        if dsp_sci_req_lat(i) = '1' and dsp_to_sc_lat(i)(0) = '1' then         -- DSP read port 1
          dsp_sc_data_read_int_wire(0)(31+32*j downto 32*j) <= sc_data_rd((SIMD)*i+j);
        end if;
      end loop;
		
      if dsp_sci_req(i) = '1' and dsp_to_sc(i)(1) = '1' then       -- DSP read port 2
        for j in 0 to SIMD-1 loop        -- Loop through the sub-scratchpads
          sc_addr_rd((SIMD)*i+j) <= std_logic_vector(unsigned(dsp_sc_read_addr(1)(Addr_Width - 1 downto SIMD_BITS+2)) + rd_offset(1)(j));
        end loop;
      end if;
      for j in 0 to SIMD-1 loop        -- Loop through the sub-scratchpads
        if dsp_sci_req_lat(i) = '1' and dsp_to_sc_lat(i)(1) = '1' then         -- DSP read port 2
          dsp_sc_data_read_int_wire(1)(31+32*j downto 32*j) <= sc_data_rd((SIMD)*i+j);
        end if;
      end loop;

      if dsp_sci_req(i) = '1' and ls_sci_we(i) = '1' then  -- A handler for when the DSP unit tries to read a vector that is still being loaded in the scratchpad memory 
        if dsp_sc_read_addr(0)(Addr_Width - 1 downto SIMD_BITS+2) = ls_sc_write_addr  or  (dsp_sc_read_addr(1)(Addr_Width - 1 downto SIMD_BITS+2) = ls_sc_write_addr)  then
          dsp_data_gnt_i <= '0';
        else
          dsp_data_gnt_i <= '1';
        end if;
      elsif dsp_sci_req(i) = '1' and ls_sci_we(i) = '0' then
        dsp_data_gnt_i <= '1';
      end if;

      if ls_sci_we(i) = '0' and dsp_sci_we(i) = '1' then -- One DSP write enable request will put the dsp_sci_wr_gnt to '1' if the no ongoing LSU writes to the same scratchpad
        dsp_sci_wr_gnt <= '1';
      elsif unsigned(dsp_sci_we) = 0 then  -- All the dsp_sci_we must be zero in-order to switch the dsp_sci_wr_gnt back to '0'
        dsp_sci_wr_gnt <= '0';
      end if;

      if ls_sci_we(i) = '1' and dsp_sci_we(i) = '0' then -- One LSU write enable request will put the ls_sci_wr_gnt to '1' if the no ongoing DSP writes to the same scratchpad
        ls_sci_wr_gnt <= '1';
      elsif unsigned(ls_sci_we) = 0 then   -- All the ls_sci_we must be zero in-order to switch the ls_sci_wr_gnt back to '0'
        ls_sci_wr_gnt <= '0';
      end if;
    end loop;

      ---------------------------------------------------------------------------------------------------------------------------------
      --  ######       ###      ########      ###          #######   #######         #######   #######   ######   #######  #######   --
      --  ##    #     #   #        ##        #   #         ##     #  ##             ##     ##  ##     #  ##    #  ##       ##     #  --
      --  ##    #    #######       ##       #######        #######   #####    ####  ##     ##  #######   ##    #  #####    #######   --
      --  ##    #   ##     ##      ##      ##     ##       ## ##     ##             ##     ##  ## ##     ##    #  ##       ## ##     -- 
      --  ######   ##       ##     ##     ##       ##      ##   ##   #######         #######   ##   ##   ######   #######  ##   ##   --  
      ---------------------------------------------------------------------------------------------------------------------------------  

    for i in 0 to SIMD-1 loop
      if (to_integer(unsigned(dsp_sc_write_addr(SIMD_BITS+1 downto 0))) = 4*i) and (i /= 0) then
        wr_offset(i-1 downto 0) <= (others => '1');
      end if;
    end loop;
    for i in 0 to SIMD-1 loop		  
      if (to_integer(unsigned(dsp_sc_write_addr(SIMD_BITS+1 downto 0))) = 4*i) then
        for j in 0 to SIMD-1 loop
          if j <= (SIMD-1)-i then
            dsp_sc_data_write_int_wire(31+32*(j+i) downto 32*(j+i)) <= dsp_sc_data_write_wire(31+32*j downto 32*j);
          elsif j > (SIMD-1)-i then
            dsp_sc_data_write_int_wire(31+32*(j-(SIMD-1)+(i-1)) downto 32*(j-(SIMD-1)+(i-1))) <= dsp_sc_data_write_wire(31+32*j downto 32*j);
          end if;
        end loop;
      end if;
    end loop;
	  
    for k in 0 to 1 loop
      for i in 0 to SIMD-1 loop
        if (to_integer(unsigned(dsp_sc_read_addr(k)(SIMD_BITS+1 downto 0))) = 4*i) and (i /= 0) then
          rd_offset(k)(i-1 downto 0) <= (others => '1');
        end if;
      end loop;
      for i in 0 to SIMD-1 loop
        if (to_integer(unsigned(dsp_sc_read_addr_lat(k))) = 4*i) then
          for j in 0 to SIMD-1 loop
            if j >= i then
              dsp_sc_data_read_wire(k)(31+32*(j-i) downto 32*(j-i)) <= dsp_sc_data_read_int_wire(k)(31+32*j downto 32*j);
			elsif j < i then
              dsp_sc_data_read_wire(k)(31+32*((SIMD-1)-i+(j+1)) downto 32*((SIMD-1)-i+(j+1))) <= dsp_sc_data_read_int_wire(k)(31+32*j downto 32*j);
            end if;
          end loop;
        end if;
      end loop;
    end loop;

  end process;

		  
end SCI;
--------------------------------------------------------------------------------------------------
-- END of SCI architecture -----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------