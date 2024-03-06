
-- VHDL Instantiation Created from source file proc.vhd -- 13:09:34 03/06/2024
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT proc
	PORT(
		RESET : IN std_logic;
		CLK_PRC : IN std_logic;
		CAN_RX : IN std_logic;
		axi_uart16550_0_Sin_pin : IN std_logic;
		axi_spi_0_SPISEL_pin : IN std_logic;
		from_fpga : IN std_logic_vector(31 downto 0);    
		MCB_DDR2_mcbx_dram_dq : INOUT std_logic_vector(15 downto 0);
		MCB_DDR2_mcbx_dram_dqs : INOUT std_logic;
		MCB_DDR2_mcbx_dram_dqs_n : INOUT std_logic;
		MCB_DDR2_mcbx_dram_udqs : INOUT std_logic;
		MCB_DDR2_mcbx_dram_udqs_n : INOUT std_logic;
		MCB_DDR2_rzq : INOUT std_logic;
		MCB_DDR2_zio : INOUT std_logic;
		GPIO : INOUT std_logic_vector(2 downto 0);
		axi_spi_0_SCK_pin : INOUT std_logic;
		axi_spi_0_MISO_pin : INOUT std_logic;
		axi_spi_0_MOSI_pin : INOUT std_logic;
		axi_spi_0_SS_pin : INOUT std_logic;
		axi_iic_0_Sda_pin : INOUT std_logic;
		axi_iic_0_Scl_pin : INOUT std_logic;      
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
		axi_uart16550_0_Sout_pin : OUT std_logic;
		to_fpga : OUT std_logic_vector(31 downto 0);
		axi_iic_0_Gpo_pin : OUT std_logic
		);
	END COMPONENT;

attribute box_type : string;
attribute box_type of proc : component is "user_black_box";


	Inst_proc: proc PORT MAP(
		RESET => ,
		CLK_PRC => ,
		MCB_DDR2_uo_done_cal_pin => ,
		MCB_DDR2_mcbx_dram_addr_pin => ,
		MCB_DDR2_mcbx_dram_ba_pin => ,
		MCB_DDR2_mcbx_dram_ras_n_pin => ,
		MCB_DDR2_mcbx_dram_cas_n_pin => ,
		MCB_DDR2_mcbx_dram_we_n_pin => ,
		MCB_DDR2_mcbx_dram_cke_pin => ,
		MCB_DDR2_mcbx_dram_clk_pin => ,
		MCB_DDR2_mcbx_dram_clk_n_pin => ,
		MCB_DDR2_mcbx_dram_dq => ,
		MCB_DDR2_mcbx_dram_dqs => ,
		MCB_DDR2_mcbx_dram_dqs_n => ,
		MCB_DDR2_mcbx_dram_udqs => ,
		MCB_DDR2_mcbx_dram_udqs_n => ,
		MCB_DDR2_mcbx_dram_udm_pin => ,
		MCB_DDR2_mcbx_dram_ldm_pin => ,
		MCB_DDR2_mcbx_dram_odt_pin => ,
		MCB_DDR2_rzq => ,
		MCB_DDR2_zio => ,
		CAN_dbg_out => ,
		CAN_TX => ,
		CAN_RX => ,
		CAN_BOFF => ,
		GPIO => ,
		axi_uart16550_0_Sin_pin => ,
		axi_uart16550_0_Sout_pin => ,
		axi_spi_0_SPISEL_pin => ,
		axi_spi_0_SCK_pin => ,
		axi_spi_0_MISO_pin => ,
		axi_spi_0_MOSI_pin => ,
		axi_spi_0_SS_pin => ,
		to_fpga => ,
		from_fpga => ,
		axi_iic_0_Gpo_pin => ,
		axi_iic_0_Sda_pin => ,
		axi_iic_0_Scl_pin => 
	);



