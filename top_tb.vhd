--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:49:14 01/25/2024
-- Design Name:   
-- Module Name:   C:/Work/XILINX/Projects/New_25/top_tb.vhd
-- Project Name:  New_25
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
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
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         in_clk : IN  std_logic;
         in_reset : IN  std_logic;
         out_led : INOUT  std_logic_vector(2 downto 0);
         can_tx : OUT  std_logic;
         can_rx : IN  std_logic;
         DDR_DQ : INOUT  std_logic_vector(15 downto 0);
         DDR_ADR : OUT  std_logic_vector(12 downto 0);
         DDR_UDQS : INOUT  std_logic;
         DDR_UDQSN : INOUT  std_logic;
         DDR_LDQS : INOUT  std_logic;
         DDR_LDQSN : INOUT  std_logic;
         DDR_UDM : OUT  std_logic;
         DDR_LDM : OUT  std_logic;
         DDR_RAS : OUT  std_logic;
         DDR_CAS : OUT  std_logic;
         DDR_ODT : OUT  std_logic;
         DDR_CLK : OUT  std_logic;
         DDR_CLKN : OUT  std_logic;
         DDR_BA : OUT  std_logic_vector(1 downto 0);
         DDR_WE : OUT  std_logic;
         DDR_CLE : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal in_clk : std_logic := '0';
   signal in_reset : std_logic := '0';
   signal can_rx : std_logic := '0';

	--BiDirs
   signal out_led : std_logic_vector(2 downto 0);
   signal DDR_DQ : std_logic_vector(15 downto 0);
   signal DDR_UDQS : std_logic;
   signal DDR_UDQSN : std_logic;
   signal DDR_LDQS : std_logic;
   signal DDR_LDQSN : std_logic;

 	--Outputs
   signal can_tx : std_logic;
   signal DDR_ADR : std_logic_vector(12 downto 0);
   signal DDR_UDM : std_logic;
   signal DDR_LDM : std_logic;
   signal DDR_RAS : std_logic;
   signal DDR_CAS : std_logic;
   signal DDR_ODT : std_logic;
   signal DDR_CLK : std_logic;
   signal DDR_CLKN : std_logic;
   signal DDR_BA : std_logic_vector(1 downto 0);
   signal DDR_WE : std_logic;
   signal DDR_CLE : std_logic;

   -- Clock period definitions
   constant in_clk_period : time := 10 ns;
   constant DDR_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          in_clk => in_clk,
          in_reset => in_reset,
          out_led => out_led,
          can_tx => can_tx,
          can_rx => can_rx,
          DDR_DQ => DDR_DQ,
          DDR_ADR => DDR_ADR,
          DDR_UDQS => DDR_UDQS,
          DDR_UDQSN => DDR_UDQSN,
          DDR_LDQS => DDR_LDQS,
          DDR_LDQSN => DDR_LDQSN,
          DDR_UDM => DDR_UDM,
          DDR_LDM => DDR_LDM,
          DDR_RAS => DDR_RAS,
          DDR_CAS => DDR_CAS,
          DDR_ODT => DDR_ODT,
          DDR_CLK => DDR_CLK,
          DDR_CLKN => DDR_CLKN,
          DDR_BA => DDR_BA,
          DDR_WE => DDR_WE,
          DDR_CLE => DDR_CLE
        );

   -- Clock process definitions
   in_clk_process :process
   begin
		in_clk <= '0';
		wait for in_clk_period/2;
		in_clk <= '1';
		wait for in_clk_period/2;
   end process;
 
   DDR_CLK_process :process
   begin
		DDR_CLK <= '0';
		wait for DDR_CLK_period/2;
		DDR_CLK <= '1';
		wait for DDR_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for in_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
