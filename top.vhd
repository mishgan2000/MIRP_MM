----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:06:04 01/10/2024 
-- Design Name: 
-- Module Name:    top - Behavioral 
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

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library work;
--	use work.inclin.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( in_clk : in  STD_LOGIC;
           in_reset : in  STD_LOGIC;
           GPIO_P : inout std_logic_vector(2 downto 0);--yes
			  GPIO_F : inout std_logic_vector(2 downto 0);--yes
			  IO     : out std_logic_vector(7 downto 0);--yes
			  
			  --out_led : out std_logic;--yes
			  --
			  --CLK_OUT1 : out std_logic;
			  --CLK_OUT2 : out std_logic;
			  --out_led2 : out  STD_LOGIC;
           --out_led3 : out  STD_LOGIC;
			  --mike_port : INOUT std_logic_vector(7 downto 0);
			  -- CAN INTERFACE ----------
			  can_tx					:out std_logic;
		     can_rx					:in std_logic;
			  -- DDR2 - ports
		     DDR_DQ				: inout std_logic_vector(15 downto 0);--yes
			  DDR_ADR			: out std_logic_vector(12 downto 0);--yes
				
			  DDR_UDQS			: inout std_logic;--yes
			  DDR_UDQSN			: inout std_logic;--yes
			  DDR_LDQS			: inout std_logic;--yes
			  DDR_LDQSN			: inout std_logic;--yes
			  DDR_UDM 			: out std_logic;--yes
			  DDR_LDM 			: out std_logic;--yes
			  DDR_RAS 			: out std_logic;--yes
			  DDR_CAS 			: out std_logic;--yes
			  DDR_ODT 			: out std_logic;--yes
			  DDR_CLK 			: out std_logic;--yes
			  DDR_CLKN			: out std_logic;--yes
			  DDR_BA				: out std_logic_vector(1 downto 0);--yes
			  DDR_WE				: out std_logic;--yes
			  DDR_CLE 			: out std_logic;--yes
			  ----------------------------------------------
			  MTX             : out std_logic;--yes
			  MRX             : in  std_logic;--yes
			  ---------------------------------------------------
			  --	ADC for resistivitymeter
		     ADC_nINT_RES						:in std_logic;
	        ADC_nRST_RES						:out std_logic;
	        ADC_MISO_RES						:inout std_logic;
		     ADC_MOSI_RES						:inout std_logic;--!!!!!!!!!!!!!!!!!!!!!!!!!!
		     ADC_nCS_RES						:inout std_logic;
		     ADC_SCK_RES						:inout std_logic;
		     ADC_CLK_RES						:out std_logic;
			  --	ADC for SP
		     ADC_nINT_SP							:in std_logic;
		     ADC_nRST_SP							:out std_logic;
		     ADC_MISO_SP							:inout std_logic;
		     ADC_MOSI_SP							:inout std_logic;
		     ADC_nCS_SP							:inout std_logic;
		     ADC_SCK_SP							:inout std_logic;
		     ADC_CLK_SP							:out std_logic;
			  ---------------------------------------------------
			  I2C_SDA                     :inout std_logic; 
			  I2C_SCL                     :inout std_logic; 
			  ---------------------------------------------------
			  RS422_RX        : in  std_logic;    
           RS422_TX        : inout std_logic  -- tx output
			  );		  
end top;

architecture Behavioral of top is
---------------------------------------------------
component pll3
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic; -- 80 MHz
  -- Clock out ports
  CLK_OUT1          : out    std_logic; -- 80 MHz
  CLK_OUT2          : out    std_logic; -- 10 MHz
  CLK_OUT3          : out    std_logic; -- 40 MHz
  CLK_OUT4          : out    std_logic; -- 7.68 MHz
  CLK_OUT5          : out    std_logic; -- 150 MHz
  -- Status and control signals
  LOCKED            : out    std_logic
 );
end component;
-----------------------------------
COMPONENT mem_res
  PORT (
    clka   : IN STD_LOGIC;
    wea    : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina   : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    clkb   : IN STD_LOGIC;
    addrb  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb  : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END COMPONENT;
-----------------------------------
COMPONENT mem_sp
  PORT (
    clka   : IN STD_LOGIC;
    wea    : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra  : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    dina   : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    clkb   : IN STD_LOGIC;
    addrb  : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    doutb  : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END COMPONENT;
--------------------------------------------------------------
component ads1256 is
	port(
	 	clk_10m 	     : in  std_logic;		-- aoiaiay ?anoioa 10IAo 
	 	xreset 		  : in  std_logic;		-- aeiaaeuiue na?in
		RESET 		  : out std_logic;		-- reset aey ads1256
		SCLK 		     : out std_logic;		-- eeie aey SPI
		start_ADCS	  : in  std_logic;		-- noa?o ?aaiou AOI
		acq_completed : out std_logic; 		-- oeee ecia?aiee caaa?oai
		ch_select	  : in std_logic_vector (2 downto 0); -- auai? aoiaiiai eaiaea
		num_points	  : in std_logic_vector (11 downto 0); -- eiee?anoai auai?ie
		CS1 		     : out std_logic;
		DIN1 		     : in  std_logic;
		DOUT 		     : out std_logic;
		DRDY1 		  : in  std_logic;
		data1		     : out std_logic_vector (23 downto 0);
		we_dat		  : out std_logic;
		pga_gain 	  : in std_logic_vector (2 downto 0);
		sampling_rate : in std_logic_vector (7 downto 0)		
	     );
end component;	
---------------------------------------------------
component inclin
port(
    clk        		: in  std_logic;
    rst        		: in  std_logic;
	 start_incl 		: in  std_logic;
	 incl_data_rdy	   : out  std_logic;
	 data_out		   : out  std_logic_vector(7 downto 0);
	 data_addr		   : in  std_logic_vector(4 downto 0);
	 incl_cmd		   : in  std_logic_vector(7 downto 0);
	 incl_wr_data	   : in  std_logic_vector(31 downto 0);
    --
    rxflex           : in  std_logic; -- rx input    
    txflex           : out std_logic;  -- tx output	
	 --
	  -----
	 ax               : out std_logic_vector (15 downto 0);
	 ay               : out std_logic_vector (15 downto 0);
	 az               : out std_logic_vector (15 downto 0);
	 hx               : out std_logic_vector (15 downto 0);
	 hy               : out std_logic_vector (15 downto 0);
	 hz               : out std_logic_vector (15 downto 0);
	 v                : out std_logic_vector (15 downto 0);
	 t                : out std_logic_vector (15 downto 0);
	 crc              : out std_logic_vector (15 downto 0);
	 
	 tf               : out std_logic_vector (15 downto 0);	 
	 mt               : out std_logic_vector (15 downto 0);
	 inc              : out std_logic_vector (15 downto 0);
	 bt               : out std_logic_vector (15 downto 0);
	 ad               : out std_logic_vector (15 downto 0);
	 gt               : out std_logic_vector (15 downto 0);
	 v2               : out std_logic_vector (15 downto 0);
	 t2               : out std_logic_vector (15 downto 0);	 
	 crc2             : out std_logic_vector (15 downto 0);
	 
	 flag             : in std_logic
	 -----	 --
	 --status           : out std_logic_vector (15 downto 0)
);
end component;
---------------------------------------------------
COMPONENT proc
	PORT(
		RESET : IN std_logic;
		CLK_PRC : IN std_logic;
		CAN_RX : IN std_logic;
		from_fpga : IN std_logic_vector(31 downto 0);    
		MCB_DDR2_mcbx_dram_dq : INOUT std_logic_vector(15 downto 0);
		MCB_DDR2_mcbx_dram_dqs : INOUT std_logic;
		MCB_DDR2_mcbx_dram_dqs_n : INOUT std_logic;
		MCB_DDR2_mcbx_dram_udqs : INOUT std_logic;
		MCB_DDR2_mcbx_dram_udqs_n : INOUT std_logic;
		MCB_DDR2_rzq : INOUT std_logic;
		MCB_DDR2_zio : INOUT std_logic;
		GPIO : INOUT std_logic_vector(2 downto 0);      
		MCB_DDR2_uo_done_cal_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_addr_pin : OUT std_logic_vector(12 downto 0);
		MCB_DDR2_mcbx_dram_ba_pin : OUT std_logic_vector(1 downto 0);
		MCB_DDR2_mcbx_dram_ras_n_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_cas_n_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_we_n_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_cke_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_clk_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_clk_n_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_udm_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_ldm_pin : OUT std_logic;
		MCB_DDR2_mcbx_dram_odt_pin : OUT std_logic;
		CAN_dbg_out : OUT std_logic_vector(7 downto 0);
		CAN_TX : OUT std_logic;
		CAN_BOFF : OUT std_logic;
		to_fpga : OUT std_logic_vector(31 downto 0);
      
		axi_uart16550_0_Sin_pin  : IN std_logic;
		axi_uart16550_0_Sout_pin : OUT std_logic;
		
		axi_spi_0_SPISEL_pin : IN std_logic;		
		axi_spi_0_SCK_pin    : INOUT std_logic;
		axi_spi_0_MISO_pin   : INOUT std_logic;
		axi_spi_0_MOSI_pin   : INOUT std_logic;
		axi_spi_0_SS_pin     : INOUT std_logic;
		
		axi_iic_0_Sda_pin : INOUT std_logic;
		axi_iic_0_Scl_pin : INOUT std_logic;		
		axi_iic_0_Gpo_pin : OUT std_logic	
		);
	END COMPONENT;

attribute box_type : string;
attribute box_type of proc : component is "user_black_box";


signal out_clk1   : std_logic; 
signal out_clk2   : std_logic;
signal clock_40   : std_logic;
signal out_clk5   : std_logic;
signal clock_768  : std_logic;
signal pll_locked : std_logic;
signal locked_768 : std_logic;

signal test_led :  std_logic_vector(2 downto 0);
signal test_le :  std_logic_vector(2 downto 0);


signal s1 : std_logic; 
signal s2 : std_logic; 
signal s3 : std_logic; 

signal s_test : std_logic;

signal rst: std_logic;
signal clk_p: std_logic;

signal ddr_cal_done	: std_logic;

signal rzq : std_logic;
signal zio : std_logic;

signal can_dbg_out : std_logic_vector(7 downto 0);

signal test_sig : std_logic_vector(7 downto 0); 
signal test_sig_o : std_logic_vector(7 downto 0);
signal test_sig_p : std_logic_vector(7 downto 0);
signal x_int: integer range 0 to 3;

--signal pwm : std_logic_vector(7 downto 0);
signal ff : std_logic_vector(31 downto 0);
signal tf : std_logic_vector(31 downto 0);

signal proc_clk: std_logic;
-------------------------------
-- UART ------
signal uclk : std_logic_vector(7 downto 0);
-------------------------------
----- INCLIN SIGNALS ------------------
signal incl_reset:    std_logic;
signal start_incl:    std_logic; 
signal incl_data_rdy: std_logic;
signal incl_data:     std_logic_vector(7 downto 0);
signal incl_addr:     std_logic_vector(4 downto 0);
signal incl_cmd:      std_logic_vector(7 downto 0);
signal incl_wr_data:  std_logic_vector(31 downto 0);

--signal RS422_RX:      std_logic;    
--signal RS422_TX:      std_logic;  -- tx output	
----------------------------------------	 
signal reset:    std_logic;
signal status:  std_logic_vector(31 downto 0);
----------------------------------------
signal s_ax   :  std_logic_vector(15 downto 0);
signal s_ay   :  std_logic_vector(15 downto 0);
signal s_az   :  std_logic_vector(15 downto 0);
signal s_hx   :  std_logic_vector(15 downto 0);
signal s_hy   :  std_logic_vector(15 downto 0);
signal s_hz   :  std_logic_vector(15 downto 0);
signal s_v    :  std_logic_vector(15 downto 0);
signal s_t    :  std_logic_vector(15 downto 0);
signal s_v2   :  std_logic_vector(15 downto 0);
signal s_t2   :  std_logic_vector(15 downto 0);
signal s_crc  :  std_logic_vector(15 downto 0);
signal s_crc2 :  std_logic_vector(15 downto 0);
signal s_te   :  std_logic_vector(15 downto 0);
signal s_ti   :  std_logic_vector(15 downto 0);

signal s_tf   :  std_logic_vector(15 downto 0);
signal s_mt   :  std_logic_vector(15 downto 0);
signal s_inc  :  std_logic_vector(15 downto 0);
signal s_bt   :  std_logic_vector(15 downto 0);
signal s_ad   :  std_logic_vector(15 downto 0);
signal s_gt   :  std_logic_vector(15 downto 0);
----------------------------------------
signal cnt    :  integer range 0 to 6;
----------------------------------------
--signal ccc : integer range 0 to 10000001;
signal f1, f2 : std_logic;
signal s_flag : std_logic;
----------------------------------------
--- SIGNAL FOR ADC RES/SP --------------
signal xreset : std_logic;
signal start_ADC_res		   			: std_logic;
signal start_ADC_sp						: std_logic;
signal adc_res_acq_completed			: std_logic;
--signal iadc_sp_acq_completed			: std_logic;
signal din_adc_res 						: std_logic_vector(23 DOWNTO 0);
signal din_adc_sp 						: std_logic_vector(23 DOWNTO 0);
signal we_dat_res 						: std_logic_vector(0 DOWNTO 0);	  -- data availiable for res
signal we_dat_sp  						: std_logic_vector(0 DOWNTO 0);	  -- data availiable for sp
signal iadc_res_pga_gain				: std_logic_vector(2 downto 0);
signal ich_select_res					: std_logic_vector(2 downto 0);
signal a : std_logic;
--constant num_points_res					: std_logic_vector(11 downto 0) := x"0F0";
constant num_points_res					: std_logic_vector(11 downto 0) := x"001";
--constant num_points_sp					: std_logic_vector(11 downto 0) := x"064"; 
constant num_points_sp					: std_logic_vector(11 downto 0) := x"002"; 

	
signal adc_mem_addra_res				: std_logic_vector(9 DOWNTO 0);
signal adc_mem_addra_sp 				: std_logic_vector(8 DOWNTO 0);
signal addrb_adc_res 					: std_logic_vector(9 DOWNTO 0);
signal dout_adc_res 					   : std_logic_vector(23 DOWNTO 0); 
signal addrb_adc_sp						: std_logic_vector(8 DOWNTO 0);
signal dout_adc_sp						: std_logic_vector(23 DOWNTO 0); 
signal adc_sp_acq_completed			: std_logic;
signal iadc_res_acq_completed			: std_logic;
signal iadc_sp_acq_completed			: std_logic;
--signal start_ADC_sp						: std_logic;
signal adc_sp_pga_gain					: std_logic_vector(26 downto 0);
signal iadc_sp_pga_gain					: std_logic_vector(2 downto 0);
signal adc_res_pga_gain					: std_logic_vector(11 downto 0);
signal ich_select_sp				   	: std_logic_vector(2 downto 0);
signal control_reg						: std_logic_vector(12 downto 0);
signal status_RD					   	: std_logic_vector(3 downto 0);
signal status_RES					   	: std_logic;
signal status_SP					   	: std_logic;
signal status_GYRO						: std_logic;
signal status_INCL						: std_logic;
	
signal regdat_in, regdat_out			   :std_logic_vector(31 downto 0);	

type	   ADC_State_Type1 is (Idle, ch1, prep_ch2, ch2, prep_ch3, ch3, prep_ch4, ch4, Ending);
signal	ADC_RES_FSM	 :  ADC_State_Type1;
signal	ADC_SP_FSM	 :  ADC_State_Type1;
----------------------------------------
signal s01, s02, s03, s04 : std_logic;
signal t01, t02, t03, t04 : std_logic;
----------------------------------------
signal FL_REG_LED				   		:boolean;
signal FL_REG_INFO						:boolean;
signal FL_REG_ADC_MAX1227				:boolean;
signal FL_REG_TIME						:boolean;
--signal FL_REG_TIME_IRQ					:boolean;
signal FL_REG_IRQ					   	:boolean;
--signal FL_REG_NPI						:boolean;
signal FL_REG_STATUS				   	:boolean;
--	signal FL_REG_VALID						:boolean;
signal FL_REG_ADC_RES					:boolean;
signal FL_REG_ADC_SP				   	:boolean;
signal FL_REG_ADC_GAIN_RES				:boolean;
signal FL_REG_ADC_GAIN_SP				:boolean;
signal FL_REG_CONTROL					:boolean;
signal FL_REG_INCL						:boolean;
signal FL_REG_DATA_WR_INCL				:boolean;
signal FL_REG_GYRO						:boolean;

signal rega								:std_logic_vector(7 downto 0);
signal adrwr 							:std_logic;
signal regwr 							:std_logic;

signal st0, st1 : std_logic;

signal uart_tx : std_logic;
signal uart_rx : std_logic;

--signal i2c_scl : std_logic;
--signal i2c_sda : std_logic;
signal i2c_gpo : std_logic;

signal spi_sel  : std_logic;
signal spi_sck  : std_logic;
signal spi_miso : std_logic;
signal spi_mosi : std_logic;
signal spi_ss   : std_logic;


begin
---------------------------------------
slow : process(out_clk2, reset)
   variable ccc : integer range 0 to 10_000_000;
   begin
      if reset = '1' then
   	   ccc := 0;
      	t01 <= '0';
			--control_reg(0) <= '0';
      else
		   if rising_edge(out_clk2) then
            ccc := ccc + 1;
		     --if ccc = 5_000_000 then
--            if ccc = 1 then
--				   control_reg(0) <= '1';
--				end if;
--            if ccc = 10 then
--				   control_reg(0) <= '0';
--            end if; 
				
			   if ccc = 50 then		   
			      t01 <= '0';
					--control_reg(0) <= '0';
		      end if;
	         if ccc = 10_000_000 then
		         ccc := 0;
			      t01 <= '1';
					--control_reg(0) <= '1';
		      end if;
			end if;	
	   end if;
end process;

sec_proc: process(t01, reset)
begin
if reset = '1' then
t02 <='1';
t03 <= not t02;
else
   if rising_edge(t01) then
		t02 <= not t02;
	end if;
	if falling_edge(t01) then
	   t03 <= not t02;
	end if;
end if;	
end process;
t04 <= '1' when t02 = t03 else '0';
--IO(0) <= t04;
---------------------------------------
s01 <= clock_768;
clock_proc: process(s01)
begin
   if rising_edge(s01) then
		s02 <= not s02;
	end if;
	if falling_edge(s01) then
	   s03 <= not s02;
	end if;
end process;
s04 <= '1' when s02 = s03 else '0';
---------------------------------------
adc_mem_res: mem_res 
 	Port map(  
	    clka  => out_clk1,
	    wea   => we_dat_res,
	    addra => adc_mem_addra_res,
	    dina  => din_adc_res,
	    clkb  => out_clk1,
	    addrb => addrb_adc_res,
	    doutb => dout_adc_res
  	);
---------------------------------------
adc_mem_sp: mem_sp 
 	Port map(  
	    clka  => out_clk1,
	    wea   => we_dat_sp,
	    addra => adc_mem_addra_sp,
	    dina  => din_adc_sp,
	    clkb  => out_clk1,
	    addrb => addrb_adc_sp,
	    doutb => dout_adc_sp
  	);
--------------------------------------	
--ADC_CLK_RES <= clock_768;
ADC_CLK_RES <= s04;
ADC_CLK_SP  <= s04;
--regdat_out <= r1_out;
regdat_out(15 downto 0) <= ff(15 downto 0);

adc_RES: ads1256 
	port map(
	 	clk_10m  	  => clock_768,		-- 7.68 MHz--
	 	xreset 		  => xreset,			-- reset--
		RESET 		  => ADC_nRST_RES,	-- reset aey ads1256--
		SCLK 		     => ADC_SCK_RES,		-- eeie aey SPI--
		start_ADCS	  => start_ADC_res,	-- noa?o ?aaiou AOI--
		acq_completed => adc_res_acq_completed,--
		ch_select	  => ich_select_res, 	-- auai? aoiaiiai eaiaea
		num_points	  => num_points_res, 	-- eiee?anoai auai?ie
		CS1 		     => ADC_nCS_RES,--
		DIN1 		     => ADC_MISO_RES,--
		DOUT 		     => ADC_MOSI_RES,--
		DRDY1 	     => ADC_nINT_RES,--
		data1	        => din_adc_res,--
		we_dat		  => we_dat_res(0),--
		pga_gain 	  => iadc_res_pga_gain,--
		--sampling_rate => "11110000"	-- 30kSPS
		sampling_rate => "10010010"	-- 500SPS
	   );

adc_SP: ads1256 
	port map(
	 	clk_10m   	  => clock_768,		-- aoiaiay ?anoioa 10IAo 
	 	xreset 		  => xreset,			-- na?in
		RESET 		  => ADC_nRST_SP,		-- reset aey ads1256
		SCLK 		     => ADC_SCK_SP,		-- eeie aey SPI
		start_ADCS    => start_ADC_sp,	-- noa?o ?aaiou AOI
		acq_completed => adc_sp_acq_completed,
		ch_select	  => ich_select_sp, 	-- auai? aoiaiiai eaiaea
		num_points	  => num_points_sp, 			-- eiee?anoai auai?ie
		CS1 		     => ADC_nCS_SP,
		DIN1 	        => ADC_MISO_SP,
		DOUT 		     => ADC_MOSI_SP,
		DRDY1 		  => ADC_nINT_SP,
		data1		     => din_adc_sp,
		we_dat		  => we_dat_sp(0),
		pga_gain 	  => iadc_sp_pga_gain,
		sampling_rate => "10010010"	-- 500SPS
	   );		

pga_adc_res_flag: process (reset, out_clk1) is
	begin
		if reset = '1' then
			adc_res_pga_gain <= (others => '0');
		elsif rising_edge(out_clk1) then 
			if FL_REG_ADC_GAIN_RES and regwr = '1' then
				adc_res_pga_gain <= regdat_out(adc_res_pga_gain'range);
			end if;
		end if;
	end process;

pga_adc_sp_flag: process (reset, out_clk1) is
	begin
		if reset = '1' then
			adc_sp_pga_gain <= (others => '0');
		elsif rising_edge(out_clk1) then 
			if FL_REG_ADC_GAIN_SP and regwr = '1' then
				adc_sp_pga_gain <= regdat_out(adc_sp_pga_gain'range);
			end if;
		end if;
	end process;	

reset <= not pll_locked;
--xreset	<= reset or control_reg(2) when rising_edge(clock_80);
--xreset	<= reset when rising_edge(clock_80);

xreset <= not pll_locked;



--------------------------------------
clock_module : PLL3
  port map
   (-- Clock in ports
    CLK_IN1 => in_clk,
    -- Clock out ports
    CLK_OUT1 => out_clk1,
    CLK_OUT2 => out_clk2,
	 CLK_OUT3 => clock_40,
	 CLK_OUT4 => clock_768,
	 CLK_OUT5 => out_clk5,
	 -- Status and control signals
	 LOCKED => pll_locked
	 );	
 
-------------------------------------------
microblaze_proc: proc PORT MAP(
		--RESET => s_test,
		--RESET => reset,
		RESET => pll_locked,
		--CLK_PRC => in_clk,
		CLK_PRC => out_clk1,
		MCB_DDR2_uo_done_cal_pin => ddr_cal_done,
		MCB_DDR2_mcbx_dram_addr_pin => DDR_ADR,
		MCB_DDR2_mcbx_dram_ba_pin => DDR_BA,
		MCB_DDR2_mcbx_dram_ras_n_pin => DDR_RAS,
		MCB_DDR2_mcbx_dram_cas_n_pin => DDR_CAS,
		MCB_DDR2_mcbx_dram_we_n_pin => DDR_WE,
		MCB_DDR2_mcbx_dram_cke_pin => DDR_CLE,
		MCB_DDR2_mcbx_dram_clk_pin => DDR_CLK,
		MCB_DDR2_mcbx_dram_clk_n_pin => DDR_CLKN,
		MCB_DDR2_mcbx_dram_dq => DDR_DQ,
		MCB_DDR2_mcbx_dram_dqs => DDR_LDQS,
		MCB_DDR2_mcbx_dram_dqs_n => DDR_LDQSN,
		MCB_DDR2_mcbx_dram_udqs => DDR_UDQS,
		MCB_DDR2_mcbx_dram_udqs_n => DDR_UDQSN,
		MCB_DDR2_mcbx_dram_udm_pin => DDR_UDM,
		MCB_DDR2_mcbx_dram_ldm_pin => DDR_LDM,
		MCB_DDR2_mcbx_dram_odt_pin => DDR_ODT,
		MCB_DDR2_rzq => rzq,
		MCB_DDR2_zio => zio,
		--axi_gpio_0_GPIO_IO_pin => out_led,
		GPIO => GPIO_P,
		CAN_dbg_out => can_dbg_out,
		CAN_TX => can_tx,
		CAN_RX => can_rx,
		from_fpga => ff,
		to_fpga => tf,
		
		axi_uart16550_0_Sin_pin => uart_rx,
		axi_uart16550_0_Sout_pin => uart_tx,
		axi_spi_0_SPISEL_pin => spi_sel,
		axi_spi_0_SCK_pin => spi_sck,
		axi_spi_0_MISO_pin => spi_miso,
		axi_spi_0_MOSI_pin => spi_mosi,
		axi_spi_0_SS_pin => spi_ss,
		axi_iic_0_Gpo_pin => i2c_gpo,
		axi_iic_0_Sda_pin => I2C_SDA,
		axi_iic_0_Scl_pin => I2C_SCL
--    CAN_BOFF : out std_logic
	);	
-------------------------------------------	
	 --proc_clk <= CLK_OUT1;	 
	 s1 <= '1';
	 s2 <= '1';
	 s3 <= '1';	 
	 s_test <= '1'; 
----- INCLINOMETR--------------------------


Incl:  inclin port map(
    clk        		=> clock_40,
    --rst        		=> incl_reset,
	 rst        		=> reset,
 	 start_incl 		=> start_incl, 
	 incl_data_rdy 	=> incl_data_rdy,
	 data_out		   => incl_data,
	 data_addr		   => incl_addr,
	 incl_cmd		   => incl_cmd,
	 incl_wr_data	   => incl_wr_data,
    --rxflex    		   => RS422_RX,    
	 rxflex    		   => MRX,    
    txflex    		   => RS422_TX,  -- tx output
	 --
    ax               => s_ax,
	 ay               => s_ay,
	 az               => s_az,
	 hx               => s_hx,
	 hy               => s_hy,
	 hz               => s_hz,
    v                => s_v,
	 t                => s_t,	 
	 
	 tf               => s_tf,
	 mt               => s_mt,
	 inc              => s_inc,
	 bt               => s_bt,
	 ad               => s_ad,
	 gt               => s_gt,
	 v2               => s_v2,
	 t2               => s_t2,	 
	 	
    crc              => s_crc,
	 crc2             => s_crc2,
    flag    	      => tf(31)--,
	 --
	 --status => status
   );	 
	
MTX <= RS422_TX;
--MRX <= RS422_RX;	
-------------------------------------------	 
--incl_com : process(reset, t04) 
incl_com : process(t04) 
variable aa : integer range 0 to 100;
begin
	if reset = '1' then
	   start_incl <= '0';
		-----------------------
		--control_reg(0) <= '0';
		-----------------------
      incl_cmd <= x"80";
		aa := 0;
	else
      if aa < 10 then
		   aa := aa + 1;	
		end if;	
	   start_incl <= t04;
		
		if aa = 1 then
		   --control_reg(0) <= t04;
		  -- control_reg(0) <= '1';	
		else	
		 --  control_reg(0) <= '0';
		end if;	
   end if;			
--   if falling_edge (t04) then
--	      start_incl <= not start_incl;
--	end if;
	--end if;	
end process;	
-----------------------------------------
--ff <= x"01234567";


--ff(31 downto 0) <= status(31 downto 0);	
data: process (reset, out_clk5) is
begin
  -- ff(31 downto 0) <= tf(31 downto 0);
   if rising_edge (out_clk5) then  
	   s_te <= x"AAAA";
		s_ti <= x"BBBB";
      if (tf(31) = '1') then
         if(tf = x"80000000") then	         
				ff(15 downto 0) <= s_te(15 downto 0);
         elsif (tf = x"80000001") then
	         ff(31 downto 16) <= s_hx(15 downto 0);	
            ff(15 downto 0)  <= s_ax(15 downto 0);									
	      elsif (tf = x"80000002") then	         
				ff(31 downto 16) <= s_hy(15 downto 0);
				ff(15 downto 0)  <= s_ay(15 downto 0);
	      elsif (tf = x"80000003") then
	         ff(31 downto 16) <= s_hz(15 downto 0);	
				ff(15 downto 0)  <= s_az(15 downto 0);
	      elsif (tf = x"80000004") then
	         ff(31 downto 16) <= s_t(15 downto 0);
				ff(15 downto 0)  <= s_v(15 downto 0);				
	      elsif (tf = x"80000005") then
			   ff(31 downto 16) <= x"0000";	
			   ff(15 downto 0) <= s_crc(15 downto 0);		         
	      elsif (tf = x"80000006") then
	         ff(31 downto 16) <= s_tf(15 downto 0);	
            ff(15 downto 0)  <= s_mt(15 downto 0);
	      elsif (tf = x"80000007") then
	         ff(31 downto 16) <= s_inc(15 downto 0);	
            ff(15 downto 0)  <= s_bt(15 downto 0);
	      elsif (tf = x"80000008") then
	         ff(31 downto 16) <= s_ad(15 downto 0);	
            ff(15 downto 0)  <= s_gt(15 downto 0);
         elsif (tf = x"80000009") then
	         ff(31 downto 16) <= s_t2(15 downto 0);
				ff(15 downto 0)  <= s_v2(15 downto 0);				
	      elsif (tf = x"8000000A") then
			   ff(31 downto 16) <= x"0000";	
			   ff(15 downto 0) <= s_crc2(15 downto 0);  
			elsif (tf = x"8000000B") then
			   ff(23 downto 16) <= din_adc_sp(23 downto 16);
			   ff(15 downto 0)  <= din_adc_sp(15 downto 0);  	
         end if;--
	   end if;		
   end if;
end process;
-----================ ADC RES Control state machine ====================------
status_RD(3) <= status_RES when rising_edge(out_clk1); 
 -- control_res_adc: process (reset, control_reg(2), clock_40) is
control_res_adc: process (xreset, clock_40) is
	begin
		if xreset = '1' then
			ADC_RES_FSM		<= Idle; 
			start_ADC_res 	<= '0';
			status_RES	 	<= '0';	 -- aeie ?acenoeaeiao?a ia caiyo
			ich_select_res <= "000";
			iadc_res_pga_gain <= "000";
			--status <= (others => '0');
			status(10) <= '1';
		elsif rising_edge(clock_40) then 
			case ADC_RES_FSM is 	
 				when Idle =>  
				   status(0) <= '1';
					if status(7) = '1' then
					   status(9) <= '1';
					end if;
					status_RES	 	<= '0';				 -- aeie ?acenoeaeiao?a ia caiyo
					if control_reg(0) = '1' then -- ?aai noa?o io iee?iaeaeca
 						ADC_RES_FSM <= ch1;
						start_ADC_res <= '1';
						iadc_res_pga_gain <= adc_res_pga_gain(2 downto 0);
						---iadc_res_pga_gain <= "111";------------------------------------------------------------------------
						ich_select_res <= "001";
					end if;
 				when ch1 =>  -- ia?aue eaiae
				   status(8) <= '1';
					status_RES	 	<= '1';			 -- aeie ?acenoeaeiao?a caiyo
					if iadc_res_acq_completed = '1' then
  						--ADC_RES_FSM <= prep_ch2;
						ADC_RES_FSM <= Ending;
   					start_ADC_res <= '0';
					end if;
 				when prep_ch2 =>
--				   status(1) <= '1';
--					if iadc_res_acq_completed = '0' then
--  						ADC_RES_FSM <= ch2;
--						iadc_res_pga_gain <= adc_res_pga_gain(5 downto 3);
--						ich_select_res <= "010";
--					end if;
				when ch2 =>  -- aoi?ie eaiae
--				   status(2) <= '1';
--					if iadc_res_acq_completed = '1' then
--  						ADC_RES_FSM <= prep_ch3;
--					end if;
 				when prep_ch3 => 
--				   status(3) <= '1';
--					if iadc_res_acq_completed = '0' then
--  						ADC_RES_FSM <= ch3;
--						iadc_res_pga_gain <= adc_res_pga_gain(8 downto 6);
--						ich_select_res <= "011";
--					end if;
 				when ch3 =>  -- o?aoee eaiae
--				   status(4) <= '1';
--					if iadc_res_acq_completed = '1' then
--  						ADC_RES_FSM <= prep_ch4;	 	
--					end if;
 				when prep_ch4 =>  -- ?aoaa?oue eaiae
--				   status(5) <= '1';
--					if iadc_res_acq_completed = '0' then
--  						ADC_RES_FSM <= ch4;
--						iadc_res_pga_gain <= adc_res_pga_gain(11 downto 9);
--						ich_select_res <= "100";
--					end if;
 				when ch4 =>  -- ?aoaa?oue eaiae
--				   status(6) <= '1';
--					if iadc_res_acq_completed = '1' then
--  						ADC_RES_FSM <= Ending;
--						start_ADC_res <= '0';
--					end if;
 				when Ending =>  -- caaa?oaai oeee
				   status(7) <= '1';
					if iadc_res_acq_completed = '0' then
  						ADC_RES_FSM <= Idle;
					end if;
			end case;
		end if;
	end process;
-----================ ADC SP Control state machine ====================------
status_RD(2) <= status_SP when rising_edge(out_clk1); 
--control_sp_adc: process (reset, control_reg(2), clock_40) is
control_sp_adc: process (xreset, clock_40) is
	begin
		if xreset = '1' then
			ADC_SP_FSM		<= Idle; 
			start_ADC_sp 	<= '0';
			status_SP	 	<= '0';	 -- aeie IN ia caiyo
			ich_select_sp 	<= "000";
			iadc_sp_pga_gain <="000";
		elsif rising_edge(clock_40) then 
			case ADC_SP_FSM is 	
 				when Idle =>  
						status_SP	 	<= '0';	 				-- aeie IN ia caiyo
					if control_reg(1) = '1' then -- ?aai noa?o io iee?iaeaeca
						ich_select_sp 	<= "001";
						iadc_sp_pga_gain <= adc_sp_pga_gain(2 downto 0);
						start_ADC_sp 	<= '1';	-- noa?o ?aaiou AOI
						ADC_SP_FSM 		<= ch1;
					end if;
 				when ch1 =>  -- ia?aue eaiae
					status_SP	  <= '1';	 				-- aeie IN caiyo
					if iadc_sp_acq_completed = '1' then	 -- oeee ecia?aiey AOI caeii?ai
  						ADC_SP_FSM <= prep_ch2;
					end if;
 				when prep_ch2 =>
					if iadc_sp_acq_completed = '0' then	 -- ?oaiea aaiiuo ec AOI caaa?oaii
						ich_select_sp <= "010";
  						ADC_SP_FSM <= ch2;
						iadc_sp_pga_gain <= adc_sp_pga_gain(5 downto 3);
					end if;
				when ch2 =>  -- aoi?ie eaiae
					if iadc_sp_acq_completed = '1' then
  						ADC_SP_FSM <= prep_ch3;
					end if;
 				when prep_ch3 => 
					if iadc_sp_acq_completed = '0' then
						ich_select_sp <= "011";
  						ADC_SP_FSM <= ch3;
						iadc_sp_pga_gain <= adc_sp_pga_gain(8 downto 6);
					end if;
 				when ch3 =>  -- o?aoee eaiae
					if iadc_sp_acq_completed = '1' then
  						ADC_SP_FSM <= prep_ch4;	 		
					end if;
 				when prep_ch4 =>  -- ?aoaa?oue eaiae
					if iadc_sp_acq_completed = '0' then
  						ADC_SP_FSM <= ch4;
						iadc_sp_pga_gain <= adc_sp_pga_gain(11 downto 9);
						ich_select_sp <= "100";	
					end if;
  				when ch4 =>  -- ?aoaa?oue eaiae
					if iadc_sp_acq_completed = '1' then
  						ADC_SP_FSM <= Ending;
						start_ADC_sp <= '0';  -- noii ?aaiou AOI
					end if;
  				when Ending =>  -- caaa?oaai oeee
					if iadc_sp_acq_completed = '0' then
  						ADC_SP_FSM <= Idle;
					end if;
			end case;
		end if;
	end process;	
-----================ Memory counter for RES ====================------
iadc_res_acq_completed <= adc_res_acq_completed when rising_edge(out_clk1);  
  addr_res_counter: process (reset, out_clk1) is
  		variable	addra_x			: unsigned(9 downto 0);
  		variable	wea_x			: std_logic_vector(3 downto 0);
	begin
		if reset = '1' then
			addra_x := (others => '0');
			wea_x := (others => '0');
			adc_mem_addra_res <= (others => '0');
		elsif rising_edge(out_clk1) then 
			if wea_x = "1100" then
				addra_x := addra_x + 1;
			end if;
			wea_x := (wea_x(2 downto 0) & we_dat_res);
			if start_ADC_res = '0' then
				addra_x := "0000000000";
			end if;
			adc_mem_addra_res <= std_logic_vector(addra_x);
		end if;
	end process;
-----===========================================================------
-----================ Memory counter for SP ====================------
iadc_sp_acq_completed <= adc_sp_acq_completed when rising_edge(out_clk1);  
  addr_sp_counter: process (reset, out_clk1) is
  		variable	addra_x			: unsigned(8 downto 0);
  		variable	wea_x			: std_logic_vector(3 downto 0);
	begin
		if reset = '1' then
			addra_x := (others => '0');
			wea_x := (others => '0');
			adc_mem_addra_sp <= (others => '0');
		elsif rising_edge(out_clk1) then 
			if wea_x(3 downto 0) = "1100" then
				addra_x := addra_x + 1;
			end if;
			wea_x(3 downto 0) := (wea_x(2 downto 0) & we_dat_sp);
			if start_ADC_sp = '0' then
				addra_x := "000000000";
			end if;
			adc_mem_addra_sp <= std_logic_vector(addra_x);
		end if;
	end process;	
------------------------------------------------------------------------
fsl_adc_res_flag : process (reset, out_clk1) is
	begin
		if reset = '1' then
			addrb_adc_res <= (others => '0');
		elsif rising_edge(out_clk1) then 
			if FL_REG_ADC_RES and regwr = '1' then
				addrb_adc_res <= regdat_out(addrb_adc_res'range);
			end if;
		end if;
	end process;
-------------------------------------------------------------------------	
	
	
--IO(1) <= ADC_nINT_RES;
--IO(2) <= ADC_nRST_RES;
--IO(2) <= iadc_res_acq_completed;
--iO(3) <= '1' when ADC_RES_FSM = Idle else '0';

c : process (out_clk1) is
   begin
   if rising_edge(out_clk1) then
      if t01 = '1' then
	      control_reg(0) <= '1';
			control_reg(1) <= '1';
	   else 
	      control_reg(0) <= '0';
			control_reg(1) <= '0';
	   end if;
		if ADC_MOSI_RES = '1' then
		   st0 <= '1';
		else
		   st0 <= '0';
		end if;
		
		if ADC_SCK_RES = '1' then
		   st1 <= '1';
		else
		   st1 <= '0';
		end if;
		
	end if;
end process;

	
--control_reg(0) <= '1' when t01 = '1' else '0';
--ADC_SCK_RES

IO(0) <= ADC_nCS_RES;
IO(1) <= ADC_nCS_SP;
--IO(3) <= control_reg(0);-- запуск
IO(2) <= ADC_MOSI_RES;-- запуск
IO(3) <= ADC_MOSI_SP;-- запуск
IO(4) <= ADC_MISO_RES;-- MOSI
IO(5) <= ADC_MISO_SP;--MISO
IO(6) <= ADC_SCK_RES;--MISO
IO(7) <= ADC_SCK_SP;--SCK
end Behavioral;

