-------------------------------------------------------------------------------
-- proc_tb.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

-- START USER CODE (Do not remove this line)

-- User: Put your libraries here. Code in this
--       section will not be overwritten.

-- END USER CODE (Do not remove this line)

entity proc_tb is
end proc_tb;

architecture STRUCTURE of proc_tb is

  constant CLK_PRC_PERIOD : time := 12500.000000 ps;
  constant RESET_LENGTH : time := 208000 ps;

  component proc is
    port (
      RESET : in std_logic;
      CLK_PRC : in std_logic;
      MCB_DDR2_uo_done_cal_pin : out std_logic;
      MCB_DDR2_mcbx_dram_addr_pin : out std_logic_vector(12 downto 0);
      MCB_DDR2_mcbx_dram_ba_pin : out std_logic_vector(1 downto 0);
      MCB_DDR2_mcbx_dram_ras_n_pin : out std_logic;
      MCB_DDR2_mcbx_dram_cas_n_pin : out std_logic;
      MCB_DDR2_mcbx_dram_we_n_pin : out std_logic;
      MCB_DDR2_mcbx_dram_cke_pin : out std_logic;
      MCB_DDR2_mcbx_dram_clk_pin : out std_logic;
      MCB_DDR2_mcbx_dram_clk_n_pin : out std_logic;
      MCB_DDR2_mcbx_dram_dq : inout std_logic_vector(15 downto 0);
      MCB_DDR2_mcbx_dram_dqs : inout std_logic;
      MCB_DDR2_mcbx_dram_dqs_n : inout std_logic;
      MCB_DDR2_mcbx_dram_udqs : inout std_logic;
      MCB_DDR2_mcbx_dram_udqs_n : inout std_logic;
      MCB_DDR2_mcbx_dram_udm_pin : out std_logic;
      MCB_DDR2_mcbx_dram_ldm_pin : out std_logic;
      MCB_DDR2_mcbx_dram_odt_pin : out std_logic;
      MCB_DDR2_rzq : inout std_logic;
      MCB_DDR2_zio : inout std_logic;
      CAN_dbg_out : out std_logic_vector(7 downto 0);
      CAN_TX : out std_logic;
      CAN_RX : in std_logic;
      CAN_BOFF : out std_logic;
      GPIO : inout std_logic_vector(2 downto 0);
      axi_uart16550_0_Sin_pin : in std_logic;
      axi_uart16550_0_Sout_pin : out std_logic;
      axi_spi_0_SPISEL_pin : in std_logic;
      axi_spi_0_SCK_pin : inout std_logic;
      axi_spi_0_MISO_pin : inout std_logic;
      axi_spi_0_MOSI_pin : inout std_logic;
      axi_spi_0_SS_pin : inout std_logic;
      to_fpga : out std_logic_vector(31 downto 0);
      from_fpga : in std_logic_vector(31 downto 0);
      axi_iic_0_Gpo_pin : out std_logic;
      axi_iic_0_Sda_pin : inout std_logic;
      axi_iic_0_Scl_pin : inout std_logic
    );
  end component;

  -- Internal signals

  signal CAN_BOFF : std_logic;
  signal CAN_RX : std_logic;
  signal CAN_TX : std_logic;
  signal CAN_dbg_out : std_logic_vector(7 downto 0);
  signal CLK_PRC : std_logic;
  signal GPIO : std_logic_vector(2 downto 0);
  signal MCB_DDR2_mcbx_dram_addr_pin : std_logic_vector(12 downto 0);
  signal MCB_DDR2_mcbx_dram_ba_pin : std_logic_vector(1 downto 0);
  signal MCB_DDR2_mcbx_dram_cas_n_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_cke_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_clk_n_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_clk_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_dq : std_logic_vector(15 downto 0);
  signal MCB_DDR2_mcbx_dram_dqs : std_logic;
  signal MCB_DDR2_mcbx_dram_dqs_n : std_logic;
  signal MCB_DDR2_mcbx_dram_ldm_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_odt_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_ras_n_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_udm_pin : std_logic;
  signal MCB_DDR2_mcbx_dram_udqs : std_logic;
  signal MCB_DDR2_mcbx_dram_udqs_n : std_logic;
  signal MCB_DDR2_mcbx_dram_we_n_pin : std_logic;
  signal MCB_DDR2_rzq : std_logic;
  signal MCB_DDR2_uo_done_cal_pin : std_logic;
  signal MCB_DDR2_zio : std_logic;
  signal RESET : std_logic;
  signal axi_iic_0_Gpo_pin : std_logic;
  signal axi_iic_0_Scl_pin : std_logic;
  signal axi_iic_0_Sda_pin : std_logic;
  signal axi_spi_0_MISO_pin : std_logic;
  signal axi_spi_0_MOSI_pin : std_logic;
  signal axi_spi_0_SCK_pin : std_logic;
  signal axi_spi_0_SPISEL_pin : std_logic;
  signal axi_spi_0_SS_pin : std_logic;
  signal axi_uart16550_0_Sin_pin : std_logic;
  signal axi_uart16550_0_Sout_pin : std_logic;
  signal from_fpga : std_logic_vector(31 downto 0);
  signal to_fpga : std_logic_vector(31 downto 0);

  -- START USER CODE (Do not remove this line)

  -- User: Put your signals here. Code in this
  --       section will not be overwritten.

  -- END USER CODE (Do not remove this line)

begin

  dut : proc
    port map (
      RESET => RESET,
      CLK_PRC => CLK_PRC,
      MCB_DDR2_uo_done_cal_pin => MCB_DDR2_uo_done_cal_pin,
      MCB_DDR2_mcbx_dram_addr_pin => MCB_DDR2_mcbx_dram_addr_pin,
      MCB_DDR2_mcbx_dram_ba_pin => MCB_DDR2_mcbx_dram_ba_pin,
      MCB_DDR2_mcbx_dram_ras_n_pin => MCB_DDR2_mcbx_dram_ras_n_pin,
      MCB_DDR2_mcbx_dram_cas_n_pin => MCB_DDR2_mcbx_dram_cas_n_pin,
      MCB_DDR2_mcbx_dram_we_n_pin => MCB_DDR2_mcbx_dram_we_n_pin,
      MCB_DDR2_mcbx_dram_cke_pin => MCB_DDR2_mcbx_dram_cke_pin,
      MCB_DDR2_mcbx_dram_clk_pin => MCB_DDR2_mcbx_dram_clk_pin,
      MCB_DDR2_mcbx_dram_clk_n_pin => MCB_DDR2_mcbx_dram_clk_n_pin,
      MCB_DDR2_mcbx_dram_dq => MCB_DDR2_mcbx_dram_dq,
      MCB_DDR2_mcbx_dram_dqs => MCB_DDR2_mcbx_dram_dqs,
      MCB_DDR2_mcbx_dram_dqs_n => MCB_DDR2_mcbx_dram_dqs_n,
      MCB_DDR2_mcbx_dram_udqs => MCB_DDR2_mcbx_dram_udqs,
      MCB_DDR2_mcbx_dram_udqs_n => MCB_DDR2_mcbx_dram_udqs_n,
      MCB_DDR2_mcbx_dram_udm_pin => MCB_DDR2_mcbx_dram_udm_pin,
      MCB_DDR2_mcbx_dram_ldm_pin => MCB_DDR2_mcbx_dram_ldm_pin,
      MCB_DDR2_mcbx_dram_odt_pin => MCB_DDR2_mcbx_dram_odt_pin,
      MCB_DDR2_rzq => MCB_DDR2_rzq,
      MCB_DDR2_zio => MCB_DDR2_zio,
      CAN_dbg_out => CAN_dbg_out,
      CAN_TX => CAN_TX,
      CAN_RX => CAN_RX,
      CAN_BOFF => CAN_BOFF,
      GPIO => GPIO,
      axi_uart16550_0_Sin_pin => axi_uart16550_0_Sin_pin,
      axi_uart16550_0_Sout_pin => axi_uart16550_0_Sout_pin,
      axi_spi_0_SPISEL_pin => axi_spi_0_SPISEL_pin,
      axi_spi_0_SCK_pin => axi_spi_0_SCK_pin,
      axi_spi_0_MISO_pin => axi_spi_0_MISO_pin,
      axi_spi_0_MOSI_pin => axi_spi_0_MOSI_pin,
      axi_spi_0_SS_pin => axi_spi_0_SS_pin,
      to_fpga => to_fpga,
      from_fpga => from_fpga,
      axi_iic_0_Gpo_pin => axi_iic_0_Gpo_pin,
      axi_iic_0_Sda_pin => axi_iic_0_Sda_pin,
      axi_iic_0_Scl_pin => axi_iic_0_Scl_pin
    );

  -- Clock generator for CLK_PRC

  process
  begin
    CLK_PRC <= '0';
    loop
      wait for (CLK_PRC_PERIOD/2);
      CLK_PRC <= not CLK_PRC;
    end loop;
  end process;

  -- Reset Generator for RESET

  process
  begin
    RESET <= '0';
    wait for (RESET_LENGTH);
    RESET <= not RESET;
    wait;
  end process;

  -- START USER CODE (Do not remove this line)

  -- User: Put your stimulus here. Code in this
  --       section will not be overwritten.

  -- END USER CODE (Do not remove this line)

end architecture STRUCTURE;

