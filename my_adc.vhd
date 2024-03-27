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
		
		start_ADC	  : in  STD_LOGIC;		-- ADC start
		acq_completed : out STD_LOGIC; 		-- The measurement cycle is completed
		ch_select	  : in std_logic_vector (2 downto 0);  -- Input channel select
		num_points	  : in std_logic_vector (11 downto 0); -- Number of samples
		
		CS 		     : inout STD_LOGIC;
		DIN 		     : in  STD_LOGIC;
		DOUT 		     : out STD_LOGIC;
		EOC  		     : in  STD_LOGIC;
		CLK 		     : inout STD_LOGIC;		
		
		data1	        : out std_logic_vector (11 downto 0);
		--we_dat		  : out std_logic--;
		
		--pga_gain 	  : in std_logic_vector (2 downto 0);
		--sampling_rate : in std_logic_vector (7 downto 0)	
     o_led : out std_logic		
	   );
end my_adc;

architecture Behavioral of my_adc is
signal delay      : integer range 23 downto 0;		-- Delay
signal f          : std_logic;
signal int_clk    : std_logic;
signal bit_c      : integer range 0 to 10;
signal byte_c     : integer range 0 to 10;
signal status     : integer range 0 to 10;
signal f1, f2, f3 : std_logic;
signal a1, a2, a3 : std_logic;
signal load       : std_logic;
signal byte       : std_logic_vector (0 to 7);

begin
capt : process (start_ADC, xreset) begin
   if(xreset = '1') then
      a1 <= '0';
		
   elsif rising_edge(start_ADC) then	
	   a1 <= not a1;
	end if;
end process;

--DM_FSM: process (RST, CLK)
--cloking : process (clk_10m, xreset) begin
--   if(xreset = '1') then
--      delay <= 0;
--		o_led <= '0';
--		f <= '0';
--   elsif rising_edge(clk_10m) then	
--      delay <= delay + 1;
--		if(delay > 0) then
--		f <= not f;
--		   o_led <= f;
--			delay <= 0;
--		end if;		
--   end if;
--end process;

o_led <= a3;

--ADC_SM : process (clk_10m, xreset) begin
ADC_SM : process (int_clk, xreset) begin
   if(xreset = '1') then
     bit_c  <= 0;
	  byte_c <= 0;
	  status <= 0;
	  CS <= '1';
	  a3 <= '0';
     load <= '0';	
     byte <= x"AA";
   --elsif rising_edge(clk_10m) then	
	elsif rising_edge(int_clk) then	
	   if(status = 0) then
		   if(start_ADC = '1') then
			    status <= 1;
				 CS <= '0';	 	
			end if;
		elsif(status = 1) then
		   a3 <= '1';				 
		   if(bit_c < 8) then
        	   bit_c <= bit_c + 1; 
			else
	         status <= 2;
            a3 <= '0';				
         end if;
		elsif(status = 2) then
		   CS <= '1';
			status <= 0;
			bit_c <= 0;			
      end if;
   elsif falling_edge(int_clk) then			
	   if(status = 1) then   
		   if(load = '0') then
		      --DOUT <= (byte srl (bit_c));-- and 1;
				DOUT <= byte(bit_c);-- and 1;
		   end if;
		end if;
   end if;
end process;

clock : process(clk_10m) begin
   if rising_edge(clk_10m) then
	   f1 <= not f1;
	end if;
	if falling_edge(clk_10m) then
	   f2 <= not f1;
	end if;
end process;


CLK <= int_clk when a3 = '1' else '0';
int_clk <= (f1 xor f2);

end Behavioral;

