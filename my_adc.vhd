----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:30:56 03/25/2024 
-- Design Name: 
-- Module Name:    my_adc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_adc is
port(
	 	clk_10m  	: in  STD_LOGIC;	   	-- Input frequence
	 	xreset 		: in  STD_LOGIC;		-- Global reset
	 
		 -------- my_adc --------
		--RESET 		  : out STD_LOGIC;		-- reset for ads1256
		
		start_ADCS	  : in  STD_LOGIC;		-- ADC start
		acq_completed : out STD_LOGIC; 		-- The measurement cycle is completed
		ch_select	  : in std_logic_vector (2 downto 0);  -- Input channel select
		num_points	  : in std_logic_vector (11 downto 0); -- Number of samples
		
		CS 		     : out STD_LOGIC;
		DIN 		     : in  STD_LOGIC;
		DOUT 		     : out STD_LOGIC;
		EOC  		     : in  STD_LOGIC;
		CLK 		     : out STD_LOGIC;		   -- Clock for SPI
		
		data1	        : out std_logic_vector (11 downto 0);
		we_dat		  : out std_logic--;
		
		--pga_gain 	  : in std_logic_vector (2 downto 0);
		--sampling_rate : in std_logic_vector (7 downto 0)		
	   );
end my_adc;

architecture Behavioral of my_adc is
	--type	mas 	 is  array (integer range <>) of std_logic_vector (7 downto 0);  -- Byte type create

   --type		CLLT_State_Type is (Idle, WRITE_ADC_REG1, WRITE_ADC_REG2, WRITE_ADC_REG3, SELF_CAL1, SELF_CAL2, SELF_CAL3, 
	--										READ_ADC_COM_PREP, RDATA1, RDATA2,
	--										READ_delay1, READ_clk_forming1, READ_clk_forming2, READ_Ending1, READ_Ending2);
	--signal	CLLT_ADCS_FSM	: CLLT_State_Type;

	--signal	mas_com_init	: 	mas (0 to 2);    			-- Command massive
	--signal	mas_dat_init	: 	mas (0 to 6);				-- Data massive
	--signal	clk_2m			:	std_logic	:= '0';		-- Clock 1 MHz
	
	--signal 	delay			: 	integer range 23 downto 0;		-- Delay
	
	--signal	SPI_CLK			: std_logic;
	--signal	inum_points		: unsigned(11 downto 0);--integer range 1023 downto 0;
	--signal	transit_points	: integer range 5 downto 0;
begin


end Behavioral;

