-------------------------------------------------------------------------------
--
-- Title       : ads1256
-- Design      : 
-- Author      : 
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- File        : ads1255.vhd
-- Generated   : Tue Jun 17 14:10:13 2008
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {ads1255} architecture {ads1255_body}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;


entity ads1256 is
	port(
	 	clk_10m 	: in  STD_LOGIC;	   	-- Input frequence
	 	xreset 		: in  STD_LOGIC;		-- Global reset
	 
		 -------- ADS1256 --------
		RESET 		: out STD_LOGIC;		-- reset for ads1256
		SCLK 		: out STD_LOGIC;		   -- Clock for SPI
		start_ADCS	: in  STD_LOGIC;		-- ADC start
		acq_completed:out STD_LOGIC; 		-- The measurement cycle is completed
		ch_select	: in std_logic_vector (2 downto 0);  -- Input channel select
		num_points	: in std_logic_vector (11 downto 0); -- Number of samples
		
		CS1 		: out STD_LOGIC;
		DIN1 		: in  STD_LOGIC;
		DOUT 		: out STD_LOGIC;
		DRDY1 		: in  STD_LOGIC;
		
		data1		: out std_logic_vector (23 downto 0);
		we_dat		: out std_logic;
		
		pga_gain 	: in std_logic_vector (2 downto 0);
		sampling_rate:in std_logic_vector (7 downto 0)		
	     );
end ads1256;


--}} End of automatically maintained section

architecture ads1256_body of ads1256 is			  

	type	mas 	 is  array (integer range <>) of std_logic_vector (7 downto 0);  -- Byte type create

   type		CLLT_State_Type is (Idle, WRITE_ADC_REG1, WRITE_ADC_REG2, WRITE_ADC_REG3, SELF_CAL1, SELF_CAL2, SELF_CAL3, 
											READ_ADC_COM_PREP, RDATA1, RDATA2,
											READ_delay1, READ_clk_forming1, READ_clk_forming2, READ_Ending1, READ_Ending2);
	signal	CLLT_ADCS_FSM	: CLLT_State_Type;

	signal	mas_com_init	: 	mas (0 to 2);    			-- Command massive
	signal	mas_dat_init	: 	mas (0 to 6);				-- Data massive
	signal	clk_2m			:	std_logic	:= '0';		-- Clock 1 MHz
	
	signal 	delay			: 	integer range 23 downto 0;		-- Delay
	
	signal	SPI_CLK			: std_logic;
	signal	inum_points		: unsigned(11 downto 0);--integer range 1023 downto 0;
	signal	transit_points	: integer range 5 downto 0;

	
begin
-------------------------------------------------------	
	process (clk_10m, xreset) -- forming 2MHz from 10MHz
		variable 	count : integer range 2 downto 0 := 0;
	begin		
		if xreset = '1' then
			clk_2m 	<= '0'; 
			count 	:=  1;
			count := 0;
		elsif rising_edge(clk_10m) then
			if count = 2 then
				count := 1;
				clk_2m <= not clk_2m; -- forming 5 MHz
			else		   
				count := count + 1;
			end if;	
		end if;	
	end process;	
-----------------------------------------------------------------
-------------------------------------------------------------------	
	process (clk_2m, xreset)  --State machine ads1256
		variable 	count_bit	:	integer range 7 downto 0; -- counter of transmitted bits
		variable 	count_byte	:	integer range 6 downto 0; -- counter of transmitted b�t�s
		variable 	byte_send	:	std_logic_vector (7 downto 0); -- transmitted byte
	begin
		if (xreset = '1') then
		
			CS1 			<= '1';	 
			DOUT 			<= '0';
			SPI_CLK			<= '0';			  
			CLLT_ADCS_FSM 	<= Idle; 
			count_bit 		:= 7;
			count_byte 		:= 0;
			delay 			<= 0;	
			byte_send 		:= (others => '0');
			we_dat			<= '0';
			acq_completed	<= '0';
			inum_points(11 downto 0)<=(others => '0');
			transit_points 	<= 0;
			data1(23 downto 0)		<=(others => '0');
		elsif rising_edge(clk_2m) then

			
		case CLLT_ADCS_FSM is 	

						  --- init Registers ---
				when Idle =>  -- Variable reset and set CS in '1'
					count_byte 	:= 0;
					count_bit 	:= 7;
					CS1 	      <= '1'; -- Resetting the transceiver ads1255
					acq_completed <= '0';
					if start_ADCS = '1'	then -- Starting a mesurement
						inum_points <= unsigned(num_points) + 5;
						--inum_points <= 6;----------------------------------------------------------------:;%�%;�%;�";"%;:%;?*:%*?:(%:(
						transit_points <= 5;
						if DRDY1 = '0' then -- Waiting until DRDY1 = '1'
							byte_send := mas_dat_init(count_byte);  -- Reading byte fo transmit to ADC
							CLLT_ADCS_FSM	<= WRITE_ADC_REG1;--avt		<= "0100";
						end if;
--						if delay <32 then
--							CLLT_ADCS_FSM		<= Idle;
--							delay <= delay+1;
--						end if;
					end if;
 
----------		Write configuration register
			  when WRITE_ADC_REG1 =>
				 CS1 		   <= '0';
				 SPI_CLK 	<= '1';           -- rising edge
				 DOUT		<= byte_send(count_bit);
				 CLLT_ADCS_FSM <= WRITE_ADC_REG2;
				 if 	count_byte > 5 then	 -- transmit complit 
					CLLT_ADCS_FSM <= WRITE_ADC_REG3;
					SPI_CLK 		<= '0';
					count_byte 	:= 0;
					count_bit 	:= 7;
					if DRDY1 = '0' then 
						CLLT_ADCS_FSM		<= WRITE_ADC_REG1;
						count_byte 	:= 6;
					end if;
				 end if;
----------		Write configuration register
			  when WRITE_ADC_REG2 =>
				 SPI_CLK <= '0';
				 CLLT_ADCS_FSM <= WRITE_ADC_REG1;
				 if count_bit = 0 then
					count_byte := count_byte + 1;	-- byte counter increase
					count_bit  := 7; 
					byte_send  := mas_dat_init(count_byte);  -- get new byte from massive
				 else
					count_bit := count_bit - 1;
				 end if;
---------		waiting for DRDY1 = "0", what means that the configuration is ended (in time of configurating = "1")
				when WRITE_ADC_REG3 =>	 --"0101";
					if DRDY1 = '0' then -- waiting '0'
						CLLT_ADCS_FSM	<= SELF_CAL1;--avt		<= "0111";
						count_byte 	:= 0;
						byte_send := mas_com_init(0);  -- read selfcalibrating command
					end if;	
----------------------------------------
---------		perfoming selfcalibrating operation
			  when SELF_CAL1 =>
				 SPI_CLK 	<= '1';           -- rising edge
				 DOUT			<= byte_send(count_bit);
				 CLLT_ADCS_FSM <= SELF_CAL2;
				 if 	count_byte > 0 then	 -- transmitt ended 
					CLLT_ADCS_FSM 	<= SELF_CAL3;-- with this transition, DRDY = "1", later you need to wait until it becomes = "0"
					SPI_CLK 			<= '0';
					count_byte 		:= 0;
					count_bit 		:= 7;
					if DRDY1 = '0' then 	-- self-calibration has not started yet, we are waiting for DRDY = "1"
						CLLT_ADCS_FSM		<= SELF_CAL1;
						count_byte 	:= 1;
					end if;
				 end if;
---------		perfoming selfcalibrating operation
			  when SELF_CAL2 =>
				 SPI_CLK <= '0';
				 CLLT_ADCS_FSM <= SELF_CAL1;
				 if count_bit = 0 then
					count_byte := count_byte + 1;	-- increasing the counter of transmitted bytes
					count_bit  := 7; 
					byte_send  := mas_dat_init(count_byte);  -- get new byte from massive
				 else
					count_bit := count_bit - 1;
				 end if;
---------		perfoming selfcalibrating operation
				when SELF_CAL3 =>	 --"0101";
				if DRDY1 = '0' then -- and wait until DRDY drops to "0"
					CLLT_ADCS_FSM	<= READ_ADC_COM_PREP;--READ_Ending2;
					byte_send := mas_com_init(1);  -- reading the transmitted byte (start rdatac)
					CS1 <= '1';
				end if;	
-----------------------------------------------
---------		preparing to send a command to read data
				when READ_ADC_COM_PREP =>	 --"0101";
					if DRDY1 = '0' then -- and wait until DRDY drops to "0"
						CLLT_ADCS_FSM	<= RDATA1;--SEND_ADC_COM;
						count_bit  := 7;
					end if;
---------		sending the read data command
			  when RDATA1 =>
				 SPI_CLK 	<= '1';           -- rising edge
				 CS1 			<= '0';
				 DOUT			<= byte_send(count_bit);
				 CLLT_ADCS_FSM <= RDATA2;
---------		sending the read data command
			  when RDATA2 =>
				 SPI_CLK <= '0';
				 CLLT_ADCS_FSM <= RDATA1;
				 if count_bit = 0 then
					count_bit  := 7; 
					delay <= 0;
					CLLT_ADCS_FSM	<= READ_delay1;
					if inum_points = 0 then
						CLLT_ADCS_FSM	<= Idle;
						acq_completed <= '0';
					end if;
						
				 else
					count_bit := count_bit - 1;
				 end if;

----------
				when READ_delay1 =>	  
					CS1 <= '0';
					if delay < 23 then -- making a small delay
						delay	<= delay + 1;
					else
						if DRDY1 = '0' then -- and we are waiting for DRDY to drop to zero
							CLLT_ADCS_FSM	<= READ_clk_forming1; 
							delay <= 23; 
						end if;							
					end if;				
----------				
				when READ_clk_forming1 =>	-- generation of 24 SCLK sync signals
						we_dat	<= '0';
						SPI_CLK <= '1';
						CLLT_ADCS_FSM	<= READ_clk_forming2; 
----------				
				when READ_clk_forming2 =>	-- generation of 24 SCLK sync signals	
						SPI_CLK <= '0';
						data1(delay) <= DIN1; 
						CLLT_ADCS_FSM	<= READ_clk_forming1; 
						if delay = 0 then 
							CLLT_ADCS_FSM	<= READ_Ending1; 
							CS1 	<= '1';
							if transit_points = 0 then
								we_dat	<= '1'; -- we set the data readiness checkbox
							else
								transit_points <= transit_points -1;
							end if;
						else 	 
							delay <= delay - 1;
						end if;					
----------
				when READ_Ending1 =>				
--					CS1 	<= '0';
					if delay < 10 then
						delay <= delay + 1;
					else
						if DRDY1 = '1' then -- We are waiting for DRDY in 11
							CLLT_ADCS_FSM	<= READ_Ending2;
							we_dat	<= '0';
							inum_points <= inum_points - 1;
						end if;
					end if;	
						
----------
				when READ_Ending2 =>	
--						if start_ADCS = '1' then -- we are waiting for the data to be ready
						if DRDY1 = '0' then --  waiting for DRDY in 1
							CLLT_ADCS_FSM	<= READ_delay1;--READ_ADC_COM_PREP; --starting the data reading procedure
							if inum_points = 0 then
								byte_send := mas_com_init(2);  -- reading the transmitted byte (stop sdatac)
								CLLT_ADCS_FSM	<= READ_ADC_COM_PREP; -- we begin the procedure of stopping the data reading
								acq_completed <= '1';
							end if;
							count_bit  := 7;
							delay <= 23;
						end if;
						CS1 <= '1';
--						end if;
----------						
--				when others =>
--						DOUT 		<= '0';			  
--						CLLT_ADCS_FSM	<= Idle; 
--						count_bit 	:= 7;
--						count_byte 	:= 0;
--						delay 	<= 0;	
			
			end case;	 
		end if;	 
	end process;	
	
   
	process (xreset,pga_gain, ch_select, sampling_rate)  -- initialization of arrays of commands and registers
	begin
		if xreset = '1' then  
			
			for j in 0 to 2 loop   -- zeroing out
				mas_com_init(j) <= conv_std_logic_vector(0,8); 
            end loop;
			for j in 0 to 6 loop
				mas_dat_init(j) <= conv_std_logic_vector(0,8); 
            end loop;
		else	
			mas_com_init(0) 	<=  "11110000"; 		-- SELFCAL	
			mas_com_init(1) 	<=  "00000011";		-- RDATAC		   
			mas_com_init(2) 	<=  "00001111";		-- SDATAC		   
			mas_dat_init(0) 	<=  "01010000";		-- 1st Command Byte -- запись начиная с адр. 0x00 (STATUS)
			mas_dat_init(1) 	<=  "00000011";		-- 2nd Command Byte -- будет запис. 4 байт
			mas_dat_init(2) 	<=  "00000010";		-- BUFEN enable   (STATUS)
--			mas_dat_init(3) 	<=  "00000001";		-- Input Multiplexer Control Register
			mas_dat_init(4) 	<=  "00100"&pga_gain;--"00100001";		-- ADCON  - 0x20 (PGA)
--			mas_dat_init(5) 	<=  "11110000";		-- DRATE  -  -- 30000sps
			mas_dat_init(6) 	<=  "11110000";		-- DRATE  -  -- 30000sps

			case ch_select(2 downto 0) is
				when "001" 				=>	mas_dat_init(3) <= x"01";	
				when "010" 				=>	mas_dat_init(3) <= x"23";	
				when "011" 				=>	mas_dat_init(3) <= x"45";	
				when "100" 				=>	mas_dat_init(3) <= x"67";	
				when others				=>	mas_dat_init(3) <= "00000001";
			end case;	

			case sampling_rate is
				when "11110000" 		=>	mas_dat_init(5) <= "11110000";	-- 30kSPS
				when "11100000" 		=>	mas_dat_init(5) <= "11100000";	
				when "11010000" 		=>	mas_dat_init(5) <= "11010000";	
				when "11000000" 		=>	mas_dat_init(5) <= "11000000";	
				when "10110000" 		=>	mas_dat_init(5) <= "10110000";
				when "10100001" 		=>	mas_dat_init(5) <= "10100001";	
				when "10010010" 		=>	mas_dat_init(5) <= "10010010";	-- 500SPS
				when "10000010" 		=>	mas_dat_init(5) <= "10000010";	-- 100SPS
				when "01110010" 		=>	mas_dat_init(5) <= "01110010";	-- 60SPS
				when "01100011" 		=>	mas_dat_init(5) <= "01100011";	-- 50SPS
				when "01110110" 		=>	mas_dat_init(5) <= "01110110";	-- fake freq
				when others				=>	mas_dat_init(5) <= "11110000";
			end case;
							
		end if;	
	end process;
	

	reset 	<= not xreset;	 
	SCLK 	<=  SPI_CLK; --SCLK signal generation for ADC1255

end ads1256_body;