-------------------------------------------------------------------------------
-- proc_axi_uart16550_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library axi_uart16550_v1_01_a;
use axi_uart16550_v1_01_a.all;

entity proc_axi_uart16550_0_wrapper is
  port (
    S_AXI_ACLK : in std_logic;
    S_AXI_ARESETN : in std_logic;
    IP2INTC_Irpt : out std_logic;
    Freeze : in std_logic;
    S_AXI_AWADDR : in std_logic_vector(12 downto 0);
    S_AXI_AWVALID : in std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA : in std_logic_vector(31 downto 0);
    S_AXI_WSTRB : in std_logic_vector(3 downto 0);
    S_AXI_WVALID : in std_logic;
    S_AXI_WREADY : out std_logic;
    S_AXI_BRESP : out std_logic_vector(1 downto 0);
    S_AXI_BVALID : out std_logic;
    S_AXI_BREADY : in std_logic;
    S_AXI_ARADDR : in std_logic_vector(12 downto 0);
    S_AXI_ARVALID : in std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA : out std_logic_vector(31 downto 0);
    S_AXI_RRESP : out std_logic_vector(1 downto 0);
    S_AXI_RVALID : out std_logic;
    S_AXI_RREADY : in std_logic;
    BaudoutN : out std_logic;
    CtsN : in std_logic;
    DcdN : in std_logic;
    Ddis : out std_logic;
    DsrN : in std_logic;
    DtrN : out std_logic;
    Out1N : out std_logic;
    Out2N : out std_logic;
    Rclk : in std_logic;
    RiN : in std_logic;
    RtsN : out std_logic;
    RxrdyN : out std_logic;
    Sin : in std_logic;
    Sout : out std_logic;
    TxrdyN : out std_logic;
    Xin : in std_logic;
    Xout : out std_logic
  );
end proc_axi_uart16550_0_wrapper;

architecture STRUCTURE of proc_axi_uart16550_0_wrapper is

  component axi_uart16550 is
    generic (
      C_FAMILY : STRING;
      C_INSTANCE : STRING;
      C_S_AXI_ACLK_FREQ_HZ : INTEGER;
      C_S_AXI_DATA_WIDTH : INTEGER;
      C_IS_A_16550 : INTEGER;
      C_HAS_EXTERNAL_XIN : INTEGER;
      C_HAS_EXTERNAL_RCLK : INTEGER;
      C_EXTERNAL_XIN_CLK_HZ : INTEGER
    );
    port (
      S_AXI_ACLK : in std_logic;
      S_AXI_ARESETN : in std_logic;
      IP2INTC_Irpt : out std_logic;
      Freeze : in std_logic;
      S_AXI_AWADDR : in std_logic_vector(12 downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA : in std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_WSTRB : in std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
      S_AXI_WVALID : in std_logic;
      S_AXI_WREADY : out std_logic;
      S_AXI_BRESP : out std_logic_vector(1 downto 0);
      S_AXI_BVALID : out std_logic;
      S_AXI_BREADY : in std_logic;
      S_AXI_ARADDR : in std_logic_vector(12 downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_RRESP : out std_logic_vector(1 downto 0);
      S_AXI_RVALID : out std_logic;
      S_AXI_RREADY : in std_logic;
      BaudoutN : out std_logic;
      CtsN : in std_logic;
      DcdN : in std_logic;
      Ddis : out std_logic;
      DsrN : in std_logic;
      DtrN : out std_logic;
      Out1N : out std_logic;
      Out2N : out std_logic;
      Rclk : in std_logic;
      RiN : in std_logic;
      RtsN : out std_logic;
      RxrdyN : out std_logic;
      Sin : in std_logic;
      Sout : out std_logic;
      TxrdyN : out std_logic;
      Xin : in std_logic;
      Xout : out std_logic
    );
  end component;

begin

  axi_uart16550_0 : axi_uart16550
    generic map (
      C_FAMILY => "spartan6",
      C_INSTANCE => "axi_uart16550_0",
      C_S_AXI_ACLK_FREQ_HZ => 40000000,
      C_S_AXI_DATA_WIDTH => 32,
      C_IS_A_16550 => 1,
      C_HAS_EXTERNAL_XIN => 0,
      C_HAS_EXTERNAL_RCLK => 0,
      C_EXTERNAL_XIN_CLK_HZ => 25000000
    )
    port map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      IP2INTC_Irpt => IP2INTC_Irpt,
      Freeze => Freeze,
      S_AXI_AWADDR => S_AXI_AWADDR,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA => S_AXI_WDATA,
      S_AXI_WSTRB => S_AXI_WSTRB,
      S_AXI_WVALID => S_AXI_WVALID,
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_BRESP => S_AXI_BRESP,
      S_AXI_BVALID => S_AXI_BVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      S_AXI_ARADDR => S_AXI_ARADDR,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA => S_AXI_RDATA,
      S_AXI_RRESP => S_AXI_RRESP,
      S_AXI_RVALID => S_AXI_RVALID,
      S_AXI_RREADY => S_AXI_RREADY,
      BaudoutN => BaudoutN,
      CtsN => CtsN,
      DcdN => DcdN,
      Ddis => Ddis,
      DsrN => DsrN,
      DtrN => DtrN,
      Out1N => Out1N,
      Out2N => Out2N,
      Rclk => Rclk,
      RiN => RiN,
      RtsN => RtsN,
      RxrdyN => RxrdyN,
      Sin => Sin,
      Sout => Sout,
      TxrdyN => TxrdyN,
      Xin => Xin,
      Xout => Xout
    );

end architecture STRUCTURE;

