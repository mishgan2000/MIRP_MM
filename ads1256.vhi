
-- VHDL Instantiation Created from source file ads1256.vhd -- 14:42:29 02/09/2024
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT ads1256
	PORT(
		clk_10m : IN std_logic;
		xreset : IN std_logic;
		start_ADCS : IN std_logic;
		ch_select : IN std_logic_vector(2 downto 0);
		num_points : IN std_logic_vector(11 downto 0);
		DIN1 : IN std_logic;
		DRDY1 : IN std_logic;
		pga_gain : IN std_logic_vector(2 downto 0);
		sampling_rate : IN std_logic_vector(7 downto 0);          
		RESET : OUT std_logic;
		SCLK : OUT std_logic;
		acq_completed : OUT std_logic;
		CS1 : OUT std_logic;
		DOUT : OUT std_logic;
		data1 : OUT std_logic_vector(23 downto 0);
		we_dat : OUT std_logic
		);
	END COMPONENT;

	Inst_ads1256: ads1256 PORT MAP(
		clk_10m => ,
		xreset => ,
		RESET => ,
		SCLK => ,
		start_ADCS => ,
		acq_completed => ,
		ch_select => ,
		num_points => ,
		CS1 => ,
		DIN1 => ,
		DOUT => ,
		DRDY1 => ,
		data1 => ,
		we_dat => ,
		pga_gain => ,
		sampling_rate => 
	);


