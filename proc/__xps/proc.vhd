LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY proc IS
PORT (
	RESET : IN STD_LOGIC;
	CLK_PRC : IN STD_LOGIC;
	MCB_DDR2_uo_done_cal_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_addr_pin : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
	MCB_DDR2_mcbx_dram_ba_pin : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	MCB_DDR2_mcbx_dram_ras_n_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_cas_n_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_we_n_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_cke_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_clk_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_clk_n_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	MCB_DDR2_mcbx_dram_dqs : INOUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_dqs_n : INOUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_udqs : INOUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_udqs_n : INOUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_udm_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_ldm_pin : OUT STD_LOGIC;
	MCB_DDR2_mcbx_dram_odt_pin : OUT STD_LOGIC;
	MCB_DDR2_rzq : INOUT STD_LOGIC;
	MCB_DDR2_zio : INOUT STD_LOGIC;
	CAN_dbg_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	CAN_TX : OUT STD_LOGIC;
	CAN_RX : IN STD_LOGIC;
	CAN_BOFF : OUT STD_LOGIC;
	GPIO : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	axi_uart16550_0_Sin_pin : IN STD_LOGIC;
	axi_uart16550_0_Sout_pin : OUT STD_LOGIC;
	axi_spi_0_SPISEL_pin : IN STD_LOGIC;
	axi_spi_0_SCK_pin : INOUT STD_LOGIC;
	axi_spi_0_MISO_pin : INOUT STD_LOGIC;
	axi_spi_0_MOSI_pin : INOUT STD_LOGIC;
	axi_spi_0_SS_pin : INOUT STD_LOGIC;
	to_fpga : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	from_fpga : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	axi_iic_0_Gpo_pin : OUT STD_LOGIC;
	axi_iic_0_Sda_pin : INOUT STD_LOGIC;
	axi_iic_0_Scl_pin : INOUT STD_LOGIC
	);
END proc;

ARCHITECTURE STRUCTURE OF proc IS

BEGIN
END ARCHITECTURE STRUCTURE;
