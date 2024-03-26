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
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;

entity my_adc is
port(
	 	clk_10m  	: in  STD_LOGIC;	   	-- Input frequence
	 	xreset 		: in  STD_LOGIC;--		   -- Global reset
	 
		 -------- my_adc --------
		
		--start_ADCS	  : in  STD_LOGIC;		-- ADC start
		--acq_completed : out STD_LOGIC; 		-- The measurement cycle is completed
		--ch_select	  : in std_logic_vector (2 downto 0);  -- Input channel select
		--num_points	  : in std_logic_vector (11 downto 0); -- Number of samples
		
		--CS 		     : out STD_LOGIC;
		--DIN 		     : in  STD_LOGIC;
		--DOUT 		     : out STD_LOGIC;
		--EOC  		     : in  STD_LOGIC;
		--CLK 		     : out STD_LOGIC--;		   -- Clock for SPI
		
		--data1	        : out std_logic_vector (11 downto 0);
		--we_dat		  : out std_logic--;
		
		--pga_gain 	  : in std_logic_vector (2 downto 0);
		--sampling_rate : in std_logic_vector (7 downto 0)	
     o_led : out std_logic		
	   );
end my_adc;

architecture Behavioral of my_adc is
signal 	delay	: integer range 23 downto 0;		-- Delay
signal       f : std_logic;
begin
--DM_FSM: process (RST, CLK)
cloking : process (clk_10m, xreset) begin
   if(xreset = '1') then
      delay <= 0;
		o_led <= '0';
		f <= '0';
   elsif rising_edge(clk_10m) then	
      delay <= delay + 1;
		if(delay > 0) then
		f <= not f;
		   o_led <= f;
			delay <= 0;
		end if;		
   end if;
end process;
end Behavioral;

