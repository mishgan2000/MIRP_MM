------------------------------------------------------------------------------
-- my_can_lite.vhd - entity/architecture pair
------------------------------------------------------------------------------
-- IMPORTANT:
-- DO NOT MODIFY THIS FILE EXCEPT IN THE DESIGNATED SECTIONS.
--
-- SEARCH FOR --USER TO DETERMINE WHERE CHANGES ARE ALLOWED.
--
-- TYPICALLY, THE ONLY ACCEPTABLE CHANGES INVOLVE ADDING NEW
-- PORTS AND GENERICS THAT GET PASSED THROUGH TO THE INSTANTIATION
-- OF THE USER_LOGIC ENTITY.
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          my_can_lite.vhd
-- Version:           1.00.a
-- Description:       Top level design, instantiates library components and user logic.
-- Date:              Tue Mar 28 08:29:14 2017 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- library proc_common_v3_00_a;
-- use proc_common_v3_00_a.proc_common_pkg.all;
-- use proc_common_v3_00_a.ipif_pkg.all;

-- library axi_lite_ipif_v1_01_a;
-- use axi_lite_ipif_v1_01_a.axi_lite_ipif;

-- library my_can_lite_v1_00_a;
-- use my_can_lite_v1_00_a.axi4lite_slave_v3;
library work;
use work.axi4lite_slave_v3;
--use axi4lite_slave_v3;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_S_AXI_DATA_WIDTH           -- AXI4LITE slave: Data width
--   C_S_AXI_ADDR_WIDTH           -- AXI4LITE slave: Address Width
--   C_S_AXI_MIN_SIZE             -- AXI4LITE slave: Min Size
--   C_USE_WSTRB                  -- AXI4LITE slave: Write Strobe
--   C_DPHASE_TIMEOUT             -- AXI4LITE slave: Data Phase Timeout
--   C_BASEADDR                   -- AXI4LITE slave: base address
--   C_HIGHADDR                   -- AXI4LITE slave: high address
--   C_FAMILY                     -- FPGA Family
--   C_NUM_REG                    -- Number of software accessible registers
--   C_NUM_MEM                    -- Number of address-ranges
--   C_SLV_AWIDTH                 -- Slave interface address bus width
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--
-- Definition of Ports:
--   S_AXI_ACLK                   -- AXI4LITE slave: Clock 
--   S_AXI_ARESETN                -- AXI4LITE slave: Reset
--   S_AXI_AWADDR                 -- AXI4LITE slave: Write address
--   S_AXI_AWVALID                -- AXI4LITE slave: Write address valid
--   S_AXI_WDATA                  -- AXI4LITE slave: Write data
--   S_AXI_WSTRB                  -- AXI4LITE slave: Write strobe
--   S_AXI_WVALID                 -- AXI4LITE slave: Write data valid
--   S_AXI_BREADY                 -- AXI4LITE slave: Response ready
--   S_AXI_ARADDR                 -- AXI4LITE slave: Read address
--   S_AXI_ARVALID                -- AXI4LITE slave: Read address valid
--   S_AXI_RREADY                 -- AXI4LITE slave: Read data ready
--   S_AXI_ARREADY                -- AXI4LITE slave: read addres ready
--   S_AXI_RDATA                  -- AXI4LITE slave: Read data
--   S_AXI_RRESP                  -- AXI4LITE slave: Read data response
--   S_AXI_RVALID                 -- AXI4LITE slave: Read data valid
--   S_AXI_WREADY                 -- AXI4LITE slave: Write data ready
--   S_AXI_BRESP                  -- AXI4LITE slave: Response
--   S_AXI_BVALID                 -- AXI4LITE slave: Resonse valid
--   S_AXI_AWREADY                -- AXI4LITE slave: Wrte address ready
------------------------------------------------------------------------------

entity my_can_lite is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    RX_FIFO_BRAM_NUM				: integer 			:= 1;
	TX_FIFO_BRAM_NUM				: integer 			:= 0;
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_S_AXI_DATA_WIDTH             : integer              := 32;
    C_S_AXI_ADDR_WIDTH             : integer              := 32;
    C_S_AXI_MIN_SIZE               : std_logic_vector     := X"000003FF";
    C_USE_WSTRB                    : integer              := 0;
    C_DPHASE_TIMEOUT               : integer              := 8;
    C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
    C_HIGHADDR                     : std_logic_vector     := X"00000000";
    C_FAMILY                       : string               := "virtex6";
    C_NUM_REG                      : integer              := 1;
    C_NUM_MEM                      : integer              := 1;
    C_SLV_AWIDTH                   : integer              := 32;
    C_SLV_DWIDTH                   : integer              := 32
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    CAN_RX							: in  std_logic;
	CAN_TX							: out std_logic;
	CAN_IRQ							: out std_logic;
	CAN_BOFF						: out std_logic;
--	CAN_CLK							: in  std_logic;
	CAN_dbg_output					: out std_logic_vector(7 downto 0);
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    S_AXI_ACLK                     : in  std_logic;
    S_AXI_ARESETN                  : in  std_logic;
    S_AXI_AWADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID                  : in  std_logic;
    S_AXI_WDATA                    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB                    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID                   : in  std_logic;
    S_AXI_BREADY                   : in  std_logic;
    S_AXI_ARADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID                  : in  std_logic;
    S_AXI_RREADY                   : in  std_logic;
    S_AXI_ARREADY                  : out std_logic;
    S_AXI_RDATA                    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_RVALID                   : out std_logic;
    S_AXI_WREADY                   : out std_logic;
    S_AXI_BRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_BVALID                   : out std_logic;
    S_AXI_AWREADY                  : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;
  attribute MAX_FANOUT of S_AXI_ACLK       : signal is "10000";
  attribute MAX_FANOUT of S_AXI_ARESETN       : signal is "10000";
  attribute SIGIS of S_AXI_ACLK       : signal is "Clk";
  attribute SIGIS of S_AXI_ARESETN       : signal is "Rst";
end entity my_can_lite;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of my_can_lite is

  constant USER_SLV_DWIDTH                : integer              := C_S_AXI_DATA_WIDTH;

  constant IPIF_SLV_DWIDTH                : integer              := C_S_AXI_DATA_WIDTH;

--function fifo_size_base_calc(size : integer) return integer is
--begin
--	if size >= 2048 then
--		return integer(ieee.math_real.ceil(ieee.math_real.log2(real(RX_FIFO_SIZE_IN_BYTES))));
--	else
--		return 0;
--	end if;
--end function fifo_size_base_calc;

--constant	RX_FIFO_SIZE_BASE			  : integer		:= RX_FIFO_BRAM_NUM * 11;
--constant	RX_FIFO_SIZE_TMP			  : integer		:= (2 ** RX_FIFO_SIZE_BASE);
--constant	TX_FIFO_SIZE_BASE			  : integer		:= TX_FIFO_BRAM_NUM * 11;
--constant	TX_FIFO_SIZE_TMP			  : integer		:= (2 ** TX_FIFO_SIZE_BASE);


  -- constant ZERO_ADDR_PAD                  : std_logic_vector(0 to 31) := (others => '0');
  -- constant USER_SLV_BASEADDR              : std_logic_vector     := C_BASEADDR;
  -- constant USER_SLV_HIGHADDR              : std_logic_vector     := C_HIGHADDR;

  -- constant IPIF_ARD_ADDR_RANGE_ARRAY      : SLV64_ARRAY_TYPE     := 
    -- (
      -- ZERO_ADDR_PAD & USER_SLV_BASEADDR,  -- user logic slave space base address
      -- ZERO_ADDR_PAD & USER_SLV_HIGHADDR   -- user logic slave space high address
    -- );

  -- constant USER_SLV_NUM_REG               : integer              := 256;
  -- constant USER_NUM_REG                   : integer              := USER_SLV_NUM_REG;
  -- constant TOTAL_IPIF_CE                  : integer              := USER_NUM_REG;

  -- constant IPIF_ARD_NUM_CE_ARRAY          : INTEGER_ARRAY_TYPE   := 
    -- (
      -- 0  => (USER_SLV_NUM_REG)            -- number of ce for user logic slave space
    -- );

  ------------------------------------------
  -- Index for CS/CE
  ------------------------------------------
  -- constant USER_SLV_CS_INDEX              : integer              := 0;
  -- constant USER_SLV_CE_INDEX              : integer              := calc_start_ce_index(IPIF_ARD_NUM_CE_ARRAY, USER_SLV_CS_INDEX);

  -- constant USER_CE_INDEX                  : integer              := USER_SLV_CE_INDEX;

  ------------------------------------------
  -- IP Interconnect (IPIC) signal declarations
  ------------------------------------------
  signal ipif_Bus2IP_Clk                : std_logic;
  signal ipif_Bus2IP_Resetn             : std_logic;
  signal ipif_Bus2IP_Addr               : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  -- signal ipif_Bus2IP_RNW                : std_logic;
  signal ipif_Bus2IP_BE                 : std_logic_vector(IPIF_SLV_DWIDTH/8-1 downto 0);
  -- signal ipif_Bus2IP_CS                 : std_logic_vector((IPIF_ARD_ADDR_RANGE_ARRAY'LENGTH)/2-1 downto 0);
  -- signal ipif_Bus2IP_RdCE               : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
  -- signal ipif_Bus2IP_WrCE               : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
  signal ipif_Bus2IP_Data               : std_logic_vector(IPIF_SLV_DWIDTH-1 downto 0);
  signal ipif_IP2Bus_WrAck              : std_logic;
  signal ipif_IP2Bus_RdAck              : std_logic;
  signal ipif_IP2Bus_Error              : std_logic;
  signal ipif_IP2Bus_Data               : std_logic_vector(IPIF_SLV_DWIDTH-1 downto 0);
  -- signal user_Bus2IP_RdCE               : std_logic_vector(USER_NUM_REG-1 downto 0);
  -- signal user_Bus2IP_WrCE               : std_logic_vector(USER_NUM_REG-1 downto 0);
  signal user_IP2Bus_Data               : std_logic_vector(USER_SLV_DWIDTH-1 downto 0);
  signal user_IP2Bus_RdAck              : std_logic;
  signal user_IP2Bus_WrAck              : std_logic;
  signal user_IP2Bus_Error              : std_logic;
  
  signal ipif_Bus2IP_Rd					: std_logic;
  signal ipif_Bus2IP_Wr					: std_logic;

  signal wd_rw_str						: std_logic;
  signal wb_ack_tmp						: std_logic;
  signal wb_data_out_tmp				: std_logic_vector(USER_SLV_DWIDTH-1 downto 0);
  signal data_out_reg                   : std_logic_vector(USER_SLV_DWIDTH-1 downto 0);
  signal data_rdy_str					: std_logic;  
  
  signal CAN_IRQ_tmp					: std_logic;
  signal can_top_dbg 					: std_logic_vector(7 downto 0);
  signal can_acf_dbg 					: std_logic_vector(7 downto 0);
  ------------------------------------------
  -- Component declaration for verilog user logic
  ------------------------------------------
  component can_top is
  generic(
    RX_FIFO_BRAM_NUM				: integer 			:= 1;
	TX_FIFO_BRAM_NUM				: integer 			:= 0
  );
  port( 
    wb_clk_i	: in std_logic;
    wb_rst_i	: in std_logic;
    wb_dat_i	: in std_logic_vector(31 downto 0);
    wb_cyc_i	: in std_logic;
    wb_stb_i	: in std_logic;
    wb_we_i 	: in std_logic;
    wb_adr_i	: in std_logic_vector(7 downto 0);
    wb_ack_o	: out std_logic;
	wb_dat_o	: out std_logic_vector(31 downto 0);
  
	clk_i		: in std_logic;
	rx_i 		: in std_logic;
	tx_o		: out std_logic;
	bus_off_on	: out std_logic;
	irq_on		: out std_logic;
	clkout_o	: out std_logic;
	can_top_dbg : out std_logic_vector(7 downto 0);
	can_acf_dbg	: out std_logic_vector(7 downto 0)
	);
	end component can_top;
  -- component user_logic is
    -- generic
    -- (
      -- -- ADD USER GENERICS BELOW THIS LINE ---------------
      -- S_ADDR_BASE							 : integer              := 5;
      -- -- ADD USER GENERICS ABOVE THIS LINE ---------------

      -- -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- -- Bus protocol parameters, do not add to or delete
      -- C_NUM_REG                      : integer              := 32;
      -- C_SLV_DWIDTH                   : integer              := 32
      -- -- DO NOT EDIT ABOVE THIS LINE ---------------------
    -- );
    -- port
    -- (
      -- -- ADD USER PORTS BELOW THIS LINE ------------------
      -- CAN_RX						: in  std_logic;
		-- CAN_TX						: out std_logic;
		-- CAN_IRQ						: out std_logic;
		-- CAN_BOFF						: out std_logic;
		-- CAN_CLK						: in  std_logic;
      -- -- ADD USER PORTS ABOVE THIS LINE ------------------

      -- -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- -- Bus protocol ports, do not add to or delete
      -- Bus2IP_Clk                     : in  std_logic;
      -- Bus2IP_Resetn                  : in  std_logic;
      -- Bus2IP_Addr                    : in  std_logic_vector(0 to 31);
      -- Bus2IP_CS                      : in  std_logic_vector(0 to 0);
      -- Bus2IP_RNW                     : in  std_logic;
      -- Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
      -- Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
      -- Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
      -- Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
      -- IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
      -- IP2Bus_RdAck                   : out std_logic;
      -- IP2Bus_WrAck                   : out std_logic;
      -- IP2Bus_Error                   : out std_logic
      -- -- DO NOT EDIT ABOVE THIS LINE ---------------------
    -- );
  -- end component user_logic;

begin

  -- ------------------------------------------
  -- -- instantiate axi_lite_ipif
  -- ------------------------------------------
  -- AXI_LITE_IPIF_I : entity axi_lite_ipif_v1_01_a.axi_lite_ipif
    -- generic map
    -- (
      -- C_S_AXI_DATA_WIDTH             => IPIF_SLV_DWIDTH,
      -- C_S_AXI_ADDR_WIDTH             => C_S_AXI_ADDR_WIDTH,
      -- C_S_AXI_MIN_SIZE               => C_S_AXI_MIN_SIZE,
      -- C_USE_WSTRB                    => C_USE_WSTRB,
      -- C_DPHASE_TIMEOUT               => C_DPHASE_TIMEOUT,
      -- C_ARD_ADDR_RANGE_ARRAY         => IPIF_ARD_ADDR_RANGE_ARRAY,
      -- C_ARD_NUM_CE_ARRAY             => IPIF_ARD_NUM_CE_ARRAY,
      -- C_FAMILY                       => C_FAMILY
    -- )
    -- port map
    -- (
      -- S_AXI_ACLK                     => S_AXI_ACLK,
      -- S_AXI_ARESETN                  => S_AXI_ARESETN,
      -- S_AXI_AWADDR                   => S_AXI_AWADDR,
      -- S_AXI_AWVALID                  => S_AXI_AWVALID,
      -- S_AXI_WDATA                    => S_AXI_WDATA,
      -- S_AXI_WSTRB                    => S_AXI_WSTRB,
      -- S_AXI_WVALID                   => S_AXI_WVALID,
      -- S_AXI_BREADY                   => S_AXI_BREADY,
      -- S_AXI_ARADDR                   => S_AXI_ARADDR,
      -- S_AXI_ARVALID                  => S_AXI_ARVALID,
      -- S_AXI_RREADY                   => S_AXI_RREADY,
      -- S_AXI_ARREADY                  => S_AXI_ARREADY,
      -- S_AXI_RDATA                    => S_AXI_RDATA,
      -- S_AXI_RRESP                    => S_AXI_RRESP,
      -- S_AXI_RVALID                   => S_AXI_RVALID,
      -- S_AXI_WREADY                   => S_AXI_WREADY,
      -- S_AXI_BRESP                    => S_AXI_BRESP,
      -- S_AXI_BVALID                   => S_AXI_BVALID,
      -- S_AXI_AWREADY                  => S_AXI_AWREADY,
      -- Bus2IP_Clk                     => ipif_Bus2IP_Clk,
      -- Bus2IP_Resetn                  => ipif_Bus2IP_Resetn,
      -- Bus2IP_Addr                    => ipif_Bus2IP_Addr,
      -- Bus2IP_RNW                     => ipif_Bus2IP_RNW,
      -- Bus2IP_BE                      => ipif_Bus2IP_BE,
      -- Bus2IP_CS                      => ipif_Bus2IP_CS,
      -- Bus2IP_RdCE                    => ipif_Bus2IP_RdCE,
      -- Bus2IP_WrCE                    => ipif_Bus2IP_WrCE,
      -- Bus2IP_Data                    => ipif_Bus2IP_Data,
      -- IP2Bus_WrAck                   => ipif_IP2Bus_WrAck,
      -- IP2Bus_RdAck                   => ipif_IP2Bus_RdAck,
      -- IP2Bus_Error                   => ipif_IP2Bus_Error,
      -- IP2Bus_Data                    => ipif_IP2Bus_Data
    -- );

	-- AXI_LITE_IPIF_I : entity my_can_lite_v1_00_a.axi4lite_slave_v3
	AXI_LITE_IPIF_I : entity work.axi4lite_slave_v3
	generic map
	(
		C_S_AXI_DATA_WIDTH        => IPIF_SLV_DWIDTH,   --  : integer              := 32;
		C_S_AXI_ADDR_WIDTH        => C_S_AXI_ADDR_WIDTH,--     : integer              := 32;
		C_S_AXI_MIN_SIZE          => C_S_AXI_MIN_SIZE,	--     : std_logic_vector     := X"000001FF";
		C_DPHASE_TIMEOUT          => C_DPHASE_TIMEOUT,	--     : integer              := 8;
		C_BASEADDR                => C_BASEADDR, --     : std_logic_vector     := X"FFFFFFFF";
		C_HIGHADDR                => C_HIGHADDR, --     : std_logic_vector     := X"00000000";
		C_FAMILY                  => C_FAMILY --     : string               := "virtex6"
	--	C_IPIF_ABUS_WIDTH			   : integer			  := Get_Addr_Bits(C_BASEADDR, C_HIGHADDR)
	--	C_IPIF_ABUS_WIDTH			   : integer			  := Get_Addr_Bits
	)
	port map
	(
		-- Bus protocol ports, do not add to or delete
		S_AXI_ACLK          => S_AXI_ACLK,
		S_AXI_ARESETN       => S_AXI_ARESETN,
		S_AXI_AWADDR        => S_AXI_AWADDR,
		S_AXI_AWVALID       => S_AXI_AWVALID,
		S_AXI_WDATA         => S_AXI_WDATA,
		S_AXI_WSTRB         => S_AXI_WSTRB,
		S_AXI_WVALID        => S_AXI_WVALID,
		S_AXI_BREADY        => S_AXI_BREADY,
		S_AXI_ARADDR        => S_AXI_ARADDR,
		S_AXI_ARVALID       => S_AXI_ARVALID,
		S_AXI_RREADY        => S_AXI_RREADY,
		S_AXI_ARREADY       => S_AXI_ARREADY,
		S_AXI_RDATA         => S_AXI_RDATA,
		S_AXI_RRESP         => S_AXI_RRESP,
		S_AXI_RVALID        => S_AXI_RVALID,
		S_AXI_WREADY        => S_AXI_WREADY,
		S_AXI_BRESP         => S_AXI_BRESP,
		S_AXI_BVALID        => S_AXI_BVALID,
		S_AXI_AWREADY       => S_AXI_AWREADY,
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
		Bus2IP_Clk          => ipif_Bus2IP_Clk,--: out std_logic;
		Bus2IP_Resetn       => ipif_Bus2IP_Resetn, --: out std_logic;
		Bus2IP_Addr         => ipif_Bus2IP_Addr, --: out std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		Bus2IP_BE           => ipif_Bus2IP_BE, --: out std_logic_vector(((C_S_AXI_DATA_WIDTH/8) - 1) downto 0);
		Bus2IP_Wr	        => ipif_Bus2IP_Wr, --: out  std_logic;
		Bus2IP_Rd	        => ipif_Bus2IP_Rd, --: out  std_logic;
		Bus2IP_Data         => ipif_Bus2IP_Data, --: out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
		IP2Bus_Data         => ipif_IP2Bus_Data, --: in  std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0)
		IP2Bus_rdAck		=> ipif_IP2Bus_RdAck,
		IP2Bus_wrAck		=> ipif_IP2Bus_WrAck
	);
	
  ------------------------------------------
  -- instantiate User Logic
  ------------------------------------------
  
	wd_rw_str <= ipif_Bus2IP_Wr or ipif_Bus2IP_Rd;
  
	i_can_top : component can_top 
	generic map
	(
		RX_FIFO_BRAM_NUM	=> RX_FIFO_BRAM_NUM,
		TX_FIFO_BRAM_NUM	=> TX_FIFO_BRAM_NUM
	)
	port map
	( 
		--Common Wishbone Signals
		  wb_clk_i	=> ipif_Bus2IP_Clk,
		  wb_rst_i	=> (not ipif_Bus2IP_Resetn),
		--Data Bus Signals  
		  wb_dat_i	=> ipif_Bus2IP_Data,
		  wb_dat_o	=> wb_data_out_tmp,
		--Bus Cycle Signals
		  wb_cyc_i	=> '1',--(1'b1), //if 1 is here, SLAVE DAT_O should be selected
		  wb_stb_i 	=> wd_rw_str,--(slv_write_ack | slv_read_ack), //kind of chip select
		  wb_we_i	=> ipif_Bus2IP_Wr,--(slv_write_ack),	//Active High Write Enable
		  wb_adr_i	=> ipif_Bus2IP_Addr(9 downto 2),--(axi_addr),	//Address
		  wb_ack_o	=> wb_ack_tmp,--(wb_ack_tmp), //Active High Acknowledge
		  
		  clk_i			=> ipif_Bus2IP_Clk,
		  rx_i			=> CAN_RX,
		  tx_o			=> CAN_TX,
		  bus_off_on	=> CAN_BOFF,
		  irq_on		=> CAN_IRQ_tmp,
		  can_top_dbg	=> can_top_dbg,
		  can_acf_dbg	=> can_acf_dbg
		--  .clkout_o()
	);
  
  	-- ACK_TIMEOUT: if true generate
		-- signal data_rdy_cnt	 	: unsigned(7 downto 0);
		-- signal data_rdy_frame  	: std_logic;
		-- signal data_rd_dff  	: std_logic;
			
	-- begin
		
		-- ACK_TIMEOUT_PROC: process( ipif_Bus2IP_Clk ) is
		-- begin
			-- if ( ipif_Bus2IP_Clk'event and ipif_Bus2IP_Clk = '1' ) then
				-- --
				-- data_rd_dff <= ipif_Bus2IP_Rd;
				-- --
				-- if (data_rdy_cnt = to_unsigned(20, data_rdy_cnt'length)) then
					-- data_rdy_frame <= '0';
				-- elsif (data_rd_dff = '0') and (ipif_Bus2IP_Rd = '1') then
					-- data_rdy_frame <= '1';
				-- else
					-- data_rdy_frame <= data_rdy_frame;
				-- end if;
				-- --
				-- if data_rdy_frame = '1' then
					-- data_rdy_cnt <= data_rdy_cnt + 1;
				-- else
					-- data_rdy_cnt <= (others => '0');
				-- end if;
				-- --
				-- data_rdy_str <= '0';
				-- data_out_reg <= (others => '0');
				-- if (data_rdy_cnt = to_unsigned(20, data_rdy_cnt'length)) then
					-- data_rdy_str <= '1';
					-- data_out_reg <= wb_data_out_tmp;
				-- end if;
				-- --
			-- end if;
	
		-- end process ACK_TIMEOUT_PROC;
		
	-- end generate ACK_TIMEOUT;
	
	ipif_IP2Bus_RdAck <= wb_ack_tmp and ipif_Bus2IP_Rd;--data_rdy_str and ipif_Bus2IP_Rd;-- wb_ack_tmp and ipif_Bus2IP_Rd; --data_rdy_str;
	ipif_IP2Bus_WrAck <= wb_ack_tmp and ipif_Bus2IP_Wr;
	ipif_IP2Bus_Data  <= wb_data_out_tmp; --data_out_reg;
  
	CAN_IRQ <= CAN_IRQ_tmp;
	
	--debug output
	CAN_dbg_output <= can_top_dbg;--can_acf_dbg;-- can_top_dbg(7 downto 1) & CAN_IRQ_tmp;
  
  -- USER_LOGIC_I : component user_logic
    -- generic map
    -- (
      -- -- MAP USER GENERICS BELOW THIS LINE ---------------
      -- S_ADDR_BASE							 => integer(ieee.math_real.ceil(ieee.math_real.log2(real(USER_NUM_REG)))),
      -- -- MAP USER GENERICS ABOVE THIS LINE ---------------

      -- C_NUM_REG                      => USER_NUM_REG,
      -- C_SLV_DWIDTH                   => USER_SLV_DWIDTH
    -- )
    -- port map
    -- (
      -- -- MAP USER PORTS BELOW THIS LINE ------------------
      -- CAN_RX		=> CAN_RX,
		-- CAN_TX		=> CAN_TX,
		-- CAN_IRQ		=>	CAN_IRQ,
		-- CAN_BOFF		=>	CAN_BOFF,
		-- CAN_CLK		=> CAN_CLK,
      -- -- MAP USER PORTS ABOVE THIS LINE ------------------

      -- Bus2IP_Clk                     => ipif_Bus2IP_Clk,
      -- Bus2IP_Resetn                  => ipif_Bus2IP_Resetn,
      -- Bus2IP_Addr                    => ipif_Bus2IP_Addr,
      -- Bus2IP_CS                      => ipif_Bus2IP_CS,
      -- Bus2IP_RNW                     => ipif_Bus2IP_RNW,
      -- Bus2IP_Data                    => ipif_Bus2IP_Data,
      -- Bus2IP_BE                      => ipif_Bus2IP_BE,
      -- Bus2IP_RdCE                    => user_Bus2IP_RdCE,
      -- Bus2IP_WrCE                    => user_Bus2IP_WrCE,
      -- IP2Bus_Data                    => user_IP2Bus_Data,
      -- IP2Bus_RdAck                   => user_IP2Bus_RdAck,
      -- IP2Bus_WrAck                   => user_IP2Bus_WrAck,
      -- IP2Bus_Error                   => user_IP2Bus_Error
    -- );

  -- ------------------------------------------
  -- -- connect internal signals
  -- ------------------------------------------
  -- ipif_IP2Bus_Data <= user_IP2Bus_Data;
  -- ipif_IP2Bus_WrAck <= user_IP2Bus_WrAck;
  -- ipif_IP2Bus_RdAck <= user_IP2Bus_RdAck;
  -- ipif_IP2Bus_Error <= user_IP2Bus_Error;

  -- user_Bus2IP_RdCE <= ipif_Bus2IP_RdCE(USER_NUM_REG-1 downto 0);
  -- user_Bus2IP_WrCE <= ipif_Bus2IP_WrCE(USER_NUM_REG-1 downto 0);

end IMP;
