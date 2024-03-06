--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:47:44 04/20/2017
-- Design Name:   
-- Module Name:   D:/_OLD_D/_work/PLT_A2/PLD/plt_a2/mb_system/pcores/my_can_lite_v1_00_a/hdl/vhdl_tb/can_acf_tb.vhd
-- Project Name:  my_can_lite
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: can_acf
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_UNSIGNED.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY can_acf_tb IS
END can_acf_tb;
 
ARCHITECTURE behavior OF can_acf_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT can_acf
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         id : IN  std_logic_vector(28 downto 0);
         reset_mode : IN  std_logic;
         acceptance_filter_mode : IN  std_logic;
         extended_mode : IN  std_logic;
         acceptance_code_0 : IN  std_logic_vector(7 downto 0);
         acceptance_code_1 : IN  std_logic_vector(7 downto 0);
         acceptance_code_2 : IN  std_logic_vector(7 downto 0);
         acceptance_code_3 : IN  std_logic_vector(7 downto 0);
         acceptance_mask_0 : IN  std_logic_vector(7 downto 0);
         acceptance_mask_1 : IN  std_logic_vector(7 downto 0);
         acceptance_mask_2 : IN  std_logic_vector(7 downto 0);
         acceptance_mask_3 : IN  std_logic_vector(7 downto 0);
         go_rx_crc_lim : IN  std_logic;
         go_rx_inter : IN  std_logic;
         go_error_frame : IN  std_logic;
         data0 : IN  std_logic_vector(7 downto 0);
         data1 : IN  std_logic_vector(7 downto 0);
         rtr1 : IN  std_logic;
         rtr2 : IN  std_logic;
         ide : IN  std_logic;
         no_byte0 : IN  std_logic;
         no_byte1 : IN  std_logic;
         id_ok : OUT  std_logic;
         wr_acceptance_reg : IN  std_logic;
         wr_acceptance_code : IN  std_logic_vector(31 downto 0);
         rd_acceptance_code : OUT  std_logic_vector(31 downto 0);
         wr_acceptance_addr : IN  std_logic_vector(5 downto 0);
         filtering_in_progress : OUT  std_logic;
         make_filtering : IN  std_logic;
         filter_number : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    
	type CAN_FILTER_TYPE is array (0 to 31) of UNSIGNED(31 downto 0);

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal id : std_logic_vector(28 downto 0) := (others => '0');
   signal reset_mode : std_logic := '0';
   signal acceptance_filter_mode : std_logic := '0';
   signal extended_mode : std_logic := '0';
   signal acceptance_code_0 : std_logic_vector(7 downto 0) := (others => '0');
   signal acceptance_code_1 : std_logic_vector(7 downto 0) := (others => '0');
   signal acceptance_code_2 : std_logic_vector(7 downto 0) := (others => '0');
   signal acceptance_code_3 : std_logic_vector(7 downto 0) := (others => '0');
   signal acceptance_mask_0 : std_logic_vector(7 downto 0) := (others => '0');
   signal acceptance_mask_1 : std_logic_vector(7 downto 0) := (others => '0');
   signal acceptance_mask_2 : std_logic_vector(7 downto 0) := (others => '0');
   signal acceptance_mask_3 : std_logic_vector(7 downto 0) := (others => '0');
   signal go_rx_crc_lim : std_logic := '1';
   signal go_rx_inter : std_logic := '0';
   signal go_error_frame : std_logic := '0';
   signal data0 : std_logic_vector(7 downto 0) := (others => '0');
   signal data1 : std_logic_vector(7 downto 0) := (others => '0');
   signal rtr1 : std_logic := '0';
   signal rtr2 : std_logic := '0';
   signal ide : std_logic := '0';
   signal no_byte0 : std_logic := '0';
   signal no_byte1 : std_logic := '0';
   signal wr_acceptance_reg : std_logic := '0';
   signal wr_acceptance_code : std_logic_vector(31 downto 0) := (others => '0');
   signal wr_acceptance_addr : std_logic_vector(5 downto 0) := (others => '0');
   signal make_filtering : std_logic := '0';

 	--Outputs
   signal id_ok : std_logic;
   signal rd_acceptance_code : std_logic_vector(31 downto 0);
   signal filtering_in_progress : std_logic;
   signal filter_number : std_logic_vector(4 downto 0);

   --Custom Signals
   signal can_filter_wr_codes 	: CAN_FILTER_TYPE := (others => (others => '0'));
   signal can_mask_wr_codes 	: CAN_FILTER_TYPE := (others => (others => '1'));
   signal can_filter_rd_codes 	: CAN_FILTER_TYPE := (others => (others => '0'));
   signal can_mask_rd_codes 	: CAN_FILTER_TYPE := (others => (others => '0'));
   
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
	--stimulus procedures
	procedure write_can_filter(
		signal clk 	: in std_logic;
		wr_addr 	: in UNSIGNED(4 downto 0);
		wr_filter 	: in UNSIGNED(31 downto 0); 
		wr_mask 	: in UNSIGNED(31 downto 0);
		signal wr_acceptance_reg 	: out std_logic;
		signal wr_acceptance_code 	: out std_logic_vector(31 downto 0);
		signal wr_acceptance_addr 	: out std_logic_vector(5 downto 0)
	)	is
	begin
		wait until rising_edge(clk);
		wr_acceptance_reg <= '1';
		wr_acceptance_addr <= '0' & std_logic_vector(wr_addr);
		wr_acceptance_code <= std_logic_vector(wr_filter);
		wait until rising_edge(clk);
		wr_acceptance_reg <= '1';
		wr_acceptance_addr <= '1' & std_logic_vector(wr_addr);
		wr_acceptance_code <= std_logic_vector(wr_mask);
	end;
	
	procedure read_can_filter(
		signal clk 	: in std_logic;
		rd_addr 	: in UNSIGNED(4 downto 0);
		rd_filter_data	: out UNSIGNED(31 downto 0);
		rd_mask_data	: out UNSIGNED(31 downto 0);
		signal wr_acceptance_addr 	: out std_logic_vector(5 downto 0);
		signal rd_acceptance_code 	: in std_logic_vector(31 downto 0)
	) is
	begin
		wr_acceptance_addr <= '0' & std_logic_vector(rd_addr);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		rd_filter_data := unsigned(rd_acceptance_code);
		wr_acceptance_addr <= '1' & std_logic_vector(rd_addr);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		rd_mask_data := unsigned(rd_acceptance_code);
	end;
		
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: can_acf PORT MAP (
          clk => clk,
          rst => rst,
          id => id,
          reset_mode => reset_mode,
          acceptance_filter_mode => acceptance_filter_mode,
          extended_mode => extended_mode,
          acceptance_code_0 => acceptance_code_0,
          acceptance_code_1 => acceptance_code_1,
          acceptance_code_2 => acceptance_code_2,
          acceptance_code_3 => acceptance_code_3,
          acceptance_mask_0 => acceptance_mask_0,
          acceptance_mask_1 => acceptance_mask_1,
          acceptance_mask_2 => acceptance_mask_2,
          acceptance_mask_3 => acceptance_mask_3,
          go_rx_crc_lim => go_rx_crc_lim,
          go_rx_inter => go_rx_inter,
          go_error_frame => go_error_frame,
          data0 => data0,
          data1 => data1,
          rtr1 => rtr1,
          rtr2 => rtr2,
          ide => ide,
          no_byte0 => no_byte0,
          no_byte1 => no_byte1,
          id_ok => id_ok,
          wr_acceptance_reg => wr_acceptance_reg,
          wr_acceptance_code => wr_acceptance_code,
          rd_acceptance_code => rd_acceptance_code,
          wr_acceptance_addr => wr_acceptance_addr,
          filtering_in_progress => filtering_in_progress,
          make_filtering => make_filtering,
          filter_number => filter_number
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
	stim_proc: process
	--Variables
		variable i : integer := 0;
		variable j : integer := 0;
		variable rd_filter_tmp : UNSIGNED(31 downto 0);
		variable rd_mask_tmp : UNSIGNED(31 downto 0);
	begin		
		  -- hold reset state for 100 ns.
		wait for 100 ns;	
		rst <= '0';
		wait until rising_edge(clk);

		--fill can_filter_values
		for i in 0 to 7 loop
			for j in 0 to 3 loop
				can_filter_wr_codes(j+4*i) <= to_unsigned(64 * i + j, 32);
				can_mask_wr_codes(j+4*i)   <= to_unsigned(16#7FF#, 32);
			end loop;		
		end loop;
		
		wait until rising_edge(clk);
-- Write can_filter_values into memory
		for i in 0 to 31 loop
--			wait until rising_edge(clk);
			write_can_filter(
				clk 			=> clk,
				wr_addr 		=> to_unsigned(i, 5),
				wr_filter 	=> can_filter_wr_codes(i),
				wr_mask 		=> can_mask_wr_codes(i),
				wr_acceptance_reg 	=> wr_acceptance_reg,
				wr_acceptance_code 	=> wr_acceptance_code,
				wr_acceptance_addr 	=> wr_acceptance_addr
			);
		end loop;
		wait until rising_edge(clk);
		wr_acceptance_reg <= '0';
-- Read Filter Memory Back
		for i in 0 to 31 loop
			read_can_filter(
				clk 			=> clk,
				rd_addr 		=> to_unsigned(i, 5),
				rd_filter_data	=> rd_filter_tmp,
				rd_mask_data	=> rd_mask_tmp, 
				wr_acceptance_addr	=> wr_acceptance_addr,
				rd_acceptance_code 	=> rd_acceptance_code
			);
			can_filter_rd_codes(i) <= rd_filter_tmp;
			can_mask_rd_codes(i) <= rd_mask_tmp;
		end loop;
		
		wait until rising_edge(clk);
-- Compare Writed and Readed data		
		for i in 0 to 31 loop
			assert (can_filter_rd_codes(i) = can_filter_wr_codes(i))
			report "(can_filter_rd_codes != can_filter_wr_codes)"
			severity error;
			
			assert (can_mask_rd_codes(i) = can_mask_wr_codes(i))
			report "(can_filter_rd_codes != can_filter_wr_codes)"
			severity error;
			
		end loop;

-- Start Filtration
-- Set new filters with enable bit and don`t mask nothing
		for i in 0 to 7 loop
			for j in 0 to 3 loop
				can_filter_wr_codes(j+4*i) <= '1' & to_unsigned(64 * i + j, 31);
				can_mask_wr_codes(j+4*i)   <= to_unsigned(0, 32);
			end loop;		
		end loop;
		wait until rising_edge(clk);
-- Write can_filter_values into memory
		for i in 0 to 31 loop
			write_can_filter(
				clk 			=> clk,
				wr_addr 		=> to_unsigned(i, 5),
				wr_filter 	=> can_filter_wr_codes(i),
				wr_mask 		=> can_mask_wr_codes(i),
				wr_acceptance_reg 	=> wr_acceptance_reg,
				wr_acceptance_code 	=> wr_acceptance_code,
				wr_acceptance_addr 	=> wr_acceptance_addr
			);
		end loop;
		wait until rising_edge(clk);
		wr_acceptance_reg <= '0';

-- Match in the middle of memory		
		id <= std_logic_vector(to_unsigned(64 * 2 + 3, 29));
		rtr1 <= '0';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '1')
		report "(filter 1 doesn`t matched)"
		severity error;
		
-- Match at start of Memory
		id <= std_logic_vector(to_unsigned(0, 29));
		rtr1 <= '0';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '1')
		report "(filter 2 doesn`t matched)"
		severity error;
-- Match at end of Memory
		id <= std_logic_vector(to_unsigned(64*7+3, 29));
		rtr1 <= '0';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '1')
		report "(filter 3 doesn`t matched)"
		severity error;
		
-- rtr doesn`t match
		id <= std_logic_vector(to_unsigned(64 * 2 + 3, 29));
		rtr1 <= '1';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '0')
		report "(filter 4 shouldn`t matched)"
		severity error;

-- check RTR matching
	can_filter_wr_codes(20) <= '1' & '0' & '1' & to_unsigned(100, 29);
	can_mask_wr_codes(20)   <= to_unsigned(0, 32);
	wait until rising_edge(clk);
	write_can_filter(
		clk 			=> clk,
		wr_addr 		=> to_unsigned(20, 5),
		wr_filter 	=> can_filter_wr_codes(20),
		wr_mask 		=> can_mask_wr_codes(20),
		wr_acceptance_reg 	=> wr_acceptance_reg,
		wr_acceptance_code 	=> wr_acceptance_code,
		wr_acceptance_addr 	=> wr_acceptance_addr
	);
	wr_acceptance_reg <= '0';
	
	id <= std_logic_vector(to_unsigned(100, 29));
	rtr1 <= '1';
		
	wait until rising_edge(clk);
	make_filtering <= '1';
	wait until rising_edge(clk);
	make_filtering <= '0';
	
	wait until rising_edge(clk) and filtering_in_progress = '0';
		
	assert (id_ok = '1')
	report "(filter 4.1 should be matched)"
	severity error;
	
	id <= std_logic_vector(to_unsigned(101, 29));
	rtr1 <= '1';
		
	wait until rising_edge(clk);
	make_filtering <= '1';
	wait until rising_edge(clk);
	make_filtering <= '0';
	
	wait until rising_edge(clk) and filtering_in_progress = '0';
		
	assert (id_ok = '0')
	report "(filter 4.2 shouldn`t be matched)"
	severity error;

-- Set new filters with enable bit, extended can_id and don`t mask nothing
		for i in 0 to 7 loop
			for j in 0 to 3 loop
				can_filter_wr_codes(j+4*i) <= '1' & '1' & to_unsigned(4096 * i + j, 30);
				can_mask_wr_codes(j+4*i)   <= to_unsigned(0, 32);
			end loop;		
		end loop;
		wait until rising_edge(clk);
-- Write can_filter_values into memory
		for i in 0 to 31 loop
			write_can_filter(
				clk 			=> clk,
				wr_addr 		=> to_unsigned(i, 5),
				wr_filter 	=> can_filter_wr_codes(i),
				wr_mask 		=> can_mask_wr_codes(i),
				wr_acceptance_reg 	=> wr_acceptance_reg,
				wr_acceptance_code 	=> wr_acceptance_code,
				wr_acceptance_addr 	=> wr_acceptance_addr
			);
		end loop;
		wait until rising_edge(clk);
		wr_acceptance_reg <= '0';
-- Match in the middle of memory		
		id <= std_logic_vector(to_unsigned(4096 * 2 + 3, 29));
		rtr2 <= '0';
		rtr1 <= '0';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '1')
		report "(filter 5 doesn`t matched)"
		severity error;
		
-- Match at start of Memory
		id <= std_logic_vector(to_unsigned(0, 29));
		rtr2 <= '0';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '1')
		report "(filter 6 doesn`t matched)"
		severity error;
-- Match at end of Memory
		id <= std_logic_vector(to_unsigned(4096*7+3, 29));
		rtr2 <= '0';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '1')
		report "(filter 7 doesn`t matched)"
		severity error;
		
-- rtr doesn`t match
		id <= std_logic_vector(to_unsigned(4096 * 2 + 3, 29));
		rtr2 <= '1';
		
		wait until rising_edge(clk);
		make_filtering <= '1';
		wait until rising_edge(clk);
		make_filtering <= '0';
		
		wait until rising_edge(clk) and filtering_in_progress = '0';
		
		assert (id_ok = '0')
		report "(filter 8 shouldn`t matched)"
		severity error;		
		
 -- check RTR and extended can_id matching
	can_filter_wr_codes(20) <= '1' & '1' & '1' & to_unsigned(100, 29);
	can_mask_wr_codes(20)   <= to_unsigned(0, 32);
	wait until rising_edge(clk);
	write_can_filter(
		clk 			=> clk,
		wr_addr 		=> to_unsigned(20, 5),
		wr_filter 	=> can_filter_wr_codes(20),
		wr_mask 		=> can_mask_wr_codes(20),
		wr_acceptance_reg 	=> wr_acceptance_reg,
		wr_acceptance_code 	=> wr_acceptance_code,
		wr_acceptance_addr 	=> wr_acceptance_addr
	);
	wr_acceptance_reg <= '0';
	
	id <= std_logic_vector(to_unsigned(100, 29));
	rtr2 <= '1';
		
	wait until rising_edge(clk);
	make_filtering <= '1';
	wait until rising_edge(clk);
	make_filtering <= '0';
	
	wait until rising_edge(clk) and filtering_in_progress = '0';
		
	assert (id_ok = '1')
	report "(filter 8.1 should be matched)"
	severity error;
	
	id <= std_logic_vector(to_unsigned(101, 29));
	rtr2 <= '1';
		
	wait until rising_edge(clk);
	make_filtering <= '1';
	wait until rising_edge(clk);
	make_filtering <= '0';
	
	wait until rising_edge(clk) and filtering_in_progress = '0';
		
	assert (id_ok = '0')
	report "(filter 8.2 shouldn`t be matched)"
	severity error;

	rtr2 <= '0';
	
	wait;
	end process;

END;
