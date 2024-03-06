--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:57:42 02/02/2024
-- Design Name:   
-- Module Name:   C:/Work/XILINX/Projects/New_25/incl_2.vhd
-- Project Name:  New_25
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: inclin
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY incl_2 IS
END incl_2;
 
ARCHITECTURE behavior OF incl_2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT inclin
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         start_incl : IN  std_logic;
         incl_data_rdy : OUT  std_logic;
         data_out : OUT  std_logic_vector(7 downto 0);
         data_addr : IN  std_logic_vector(4 downto 0);
         incl_cmd : IN  std_logic_vector(7 downto 0);
         incl_wr_data : IN  std_logic_vector(31 downto 0);
         rxflex : IN  std_logic;
         txflex : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal start_incl : std_logic := '0';
   signal data_addr : std_logic_vector(4 downto 0) := (others => '0');
   signal incl_cmd : std_logic_vector(7 downto 0) := (others => '0');
   signal incl_wr_data : std_logic_vector(31 downto 0) := (others => '0');
   signal rxflex : std_logic := '0';

 	--Outputs
   signal incl_data_rdy : std_logic;
   signal data_out : std_logic_vector(7 downto 0);
   signal txflex : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: inclin PORT MAP (
          clk => clk,
          rst => rst,
          start_incl => start_incl,
          incl_data_rdy => incl_data_rdy,
          data_out => data_out,
          data_addr => data_addr,
          incl_cmd => incl_cmd,
          incl_wr_data => incl_wr_data,
          rxflex => rxflex,
          txflex => txflex
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
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
      incl_cmd <= x"80";
		start_incl <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
