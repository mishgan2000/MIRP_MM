----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:19:06 03/26/2024 
-- Design Name: 
-- Module Name:    test_adc - Behavioral 
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

entity test_adc is
    Port ( in_clk : in  STD_LOGIC;
           reset  : in  STD_LOGIC;
			  o_led  : out STD_LOGIC
			  );
end test_adc;

architecture Behavioral of test_adc is
signal 	delay	: integer range 23 downto 0;		-- Delay
signal f : std_logic;
begin
--DM_FSM: process (RST, CLK)
cloking : process (in_clk, reset) begin
   if(reset = '1') then
      delay <= 0;
		o_led <= '0';
		f <= '0';
   elsif rising_edge(in_clk) then	
      delay <= delay + 1;
		if(delay > 0) then
		f <= not f;
		   o_led <= f;
			delay <= 0;
		end if;		
   end if;
end process;


end Behavioral;

