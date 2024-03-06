--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:49:41 09/18/2017
-- Design Name:   
-- Module Name:   D:/_OLD_D/_work/PLT_A2/PLD/plt_a2/mb_system/pcores/my_can_lite_v1_00_a/hdl/vhdl_tb/axi_slave_tb.vhd
-- Project Name:  my_can_lite
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: axi4lite_slave_v3
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY axi_slave_tb IS
END axi_slave_tb;
 
ARCHITECTURE behavior OF axi_slave_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT axi4lite_slave_v3
    PORT(
         S_AXI_ACLK : IN  std_logic;
         S_AXI_ARESETN : IN  std_logic;
         S_AXI_AWADDR : IN  std_logic_vector(31 downto 0);
         S_AXI_AWVALID : IN  std_logic;
         S_AXI_WDATA : IN  std_logic_vector(31 downto 0);
         S_AXI_WSTRB : IN  std_logic_vector(3 downto 0);
         S_AXI_WVALID : IN  std_logic;
         S_AXI_BREADY : IN  std_logic;
         S_AXI_ARADDR : IN  std_logic_vector(31 downto 0);
         S_AXI_ARVALID : IN  std_logic;
         S_AXI_RREADY : IN  std_logic;
         S_AXI_ARREADY : OUT  std_logic;
         S_AXI_RDATA : OUT  std_logic_vector(31 downto 0);
         S_AXI_RRESP : OUT  std_logic_vector(1 downto 0);
         S_AXI_RVALID : OUT  std_logic;
         S_AXI_WREADY : OUT  std_logic;
         S_AXI_BRESP : OUT  std_logic_vector(1 downto 0);
         S_AXI_BVALID : OUT  std_logic;
         S_AXI_AWREADY : OUT  std_logic;
         Bus2IP_Clk : OUT  std_logic;
         Bus2IP_Resetn : OUT  std_logic;
         Bus2IP_Addr : OUT  std_logic_vector(31 downto 0);
         Bus2IP_BE : OUT  std_logic_vector(3 downto 0);
         Bus2IP_Wr : OUT  std_logic;
         Bus2IP_Rd : OUT  std_logic;
         Bus2IP_Data : OUT  std_logic_vector(31 downto 0);
         IP2Bus_Data : IN  std_logic_vector(31 downto 0);
         IP2Bus_rdAck : IN  std_logic;
         IP2Bus_wrAck : IN  std_logic
        );
    END COMPONENT;
    
	COMPONENT can_top
    PORT(
         wb_clk_i 	: IN 	std_logic;
			wb_rst_i 	: IN 	std_logic;
			wb_dat_i 	: IN 	std_logic_vector(31 downto 0);
			wb_dat_o 	: OUT std_logic_vector(31 downto 0);
			wb_cyc_i 	: IN 	std_logic;
			wb_stb_i 	: IN 	std_logic;
			wb_we_i 		: IN 	std_logic;
			wb_adr_i 	: IN 	std_logic_vector(7 downto 0);
			wb_ack_o 	: OUT std_logic;
         clk_i 		: IN  std_logic;
         rx_i 			: IN  std_logic;
         tx_o 			: OUT std_logic;
         bus_off_on 	: OUT std_logic;
         irq_on 		: OUT std_logic;
         clkout_o 	: OUT std_logic
        );
    END COMPONENT;
	
	
   --Inputs
   signal S_AXI_ACLK : std_logic := '0';
   signal S_AXI_ARESETN : std_logic := '0';
   signal S_AXI_AWADDR : std_logic_vector(31 downto 0) := (others => '0');
   signal S_AXI_AWVALID : std_logic := '0';
   signal S_AXI_WDATA : std_logic_vector(31 downto 0) := (others => '0');
   signal S_AXI_WSTRB : std_logic_vector(3 downto 0) := (others => '0');
   signal S_AXI_WVALID : std_logic := '0';
   signal S_AXI_BREADY : std_logic := '0';
   signal S_AXI_ARADDR : std_logic_vector(31 downto 0) := (others => '0');
   signal S_AXI_ARVALID : std_logic := '0';
   signal S_AXI_RREADY : std_logic := '0';
   signal IP2Bus_Data : std_logic_vector(31 downto 0) := (others => '0');
   signal IP2Bus_rdAck : std_logic := '0';
   signal IP2Bus_wrAck : std_logic := '0';

 	--Outputs
   signal S_AXI_ARREADY : std_logic;
   signal S_AXI_RDATA : std_logic_vector(31 downto 0);
   signal S_AXI_RRESP : std_logic_vector(1 downto 0);
   signal S_AXI_RVALID : std_logic;
   signal S_AXI_WREADY : std_logic;
   signal S_AXI_BRESP : std_logic_vector(1 downto 0);
   signal S_AXI_BVALID : std_logic;
   signal S_AXI_AWREADY : std_logic;
   signal Bus2IP_Clk : std_logic;
   signal Bus2IP_Resetn : std_logic;
   signal Bus2IP_Addr : std_logic_vector(31 downto 0);
   signal Bus2IP_BE : std_logic_vector(3 downto 0);
   signal Bus2IP_Wr : std_logic;
   signal Bus2IP_Rd : std_logic;
   signal Bus2IP_Data : std_logic_vector(31 downto 0);
   signal wb_data_out_tmp : std_logic_vector(31 downto 0);
   
   
	signal data_rdy_cnt	 	: unsigned(7 downto 0);
	signal data_rdy_frame  	: std_logic;
	signal data_rd_dff  	: std_logic;
	signal data_rdy_str		: std_logic;
	-- signal data_out_reg     : std_logic_vector(31 downto 0);

	signal CAN_RX		: std_logic;
	signal CAN_TX		: std_logic;
	signal CAN_IRQ		: std_logic;
	signal CAN_BOFF		: std_logic;
	signal CAN_CLK		: std_logic;
	
	signal wd_rw_str	: std_logic;
	signal wb_ack_tmp	: std_logic;
	

   -- Clock period definitions
   constant S_AXI_ACLK_period : time := 10 ns;
   constant Bus2IP_Clk_period : time := 10 ns;
   
	--stimulus procedures
	procedure write_axi(	 
		signal clock 	: in std_logic;
		wr_data : in UNSIGNED(31 downto 0); 
		wr_addr	: in UNSIGNED(31 downto 0); 
		--signals to module
		signal S_AXI_AWADDR		: out std_logic_vector(31 downto 0);
		signal S_AXI_AWVALID	: out std_logic;
		signal S_AXI_WDATA		: out std_logic_vector(31 downto 0);
		signal S_AXI_WSTRB		: out std_logic_vector(3 downto 0);--s_axi_be_i
		signal S_AXI_WVALID 	: out std_logic;--
		signal S_AXI_AWREADY	: in std_logic;--wr_done
		signal S_AXI_WREADY		: in std_logic;	--wr_done
		signal S_AXI_BVALID		: in std_logic;		--s_axi_bvalid_i
		signal S_AXI_BREADY		: out std_logic
		
	) 	is
	begin
		wait until rising_edge(clock);
		S_AXI_AWADDR <= std_logic_vector(wr_addr);
		S_AXI_WDATA <= std_logic_vector(wr_data);
		S_AXI_WSTRB	<= (others => '1');
		wait until rising_edge(clock);
		S_AXI_AWVALID	<= '1';
		S_AXI_WVALID	<= '1';
		wait until (rising_edge(clock) and S_AXI_BVALID = '1');		
		S_AXI_BREADY <= '1';
		wait until rising_edge(clock);
		S_AXI_AWADDR	<= (others => '0');
		S_AXI_WDATA		<= (others => '0');
		S_AXI_WSTRB		<= (others => '0');
		S_AXI_AWVALID	<= '0';
		S_AXI_WVALID	<= '0';
		S_AXI_BREADY 	<= '0';
	end;   
	
	--stimulus procedures
	procedure read_axi(	 
		signal clock 	: in std_logic;
		rd_addr	: in UNSIGNED(31 downto 0); 
		--signals to module
		signal S_AXI_ARADDR		: out std_logic_vector(31 downto 0);
		signal S_AXI_ARVALID	: out std_logic;
		signal S_AXI_RVALID		: in std_logic;
		signal S_AXI_ARREADY	: in std_logic;
		signal S_AXI_RREADY		: out std_logic
		
	) 	is
	begin
		wait until rising_edge(clock);
		S_AXI_ARADDR <= std_logic_vector(rd_addr);
		wait until rising_edge(clock);
		S_AXI_ARVALID	<= '1';
		wait until (rising_edge(clock) and S_AXI_RVALID = '1');		
		S_AXI_RREADY <= '1';
		wait until rising_edge(clock);
		S_AXI_ARADDR	<= (others => '0');
		S_AXI_ARVALID	<= '0';
		S_AXI_RREADY 	<= '0';
	end;   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: axi4lite_slave_v3 PORT MAP (
          S_AXI_ACLK => S_AXI_ACLK,
          S_AXI_ARESETN => S_AXI_ARESETN,
          S_AXI_AWADDR => S_AXI_AWADDR,
          S_AXI_AWVALID => S_AXI_AWVALID,
          S_AXI_WDATA => S_AXI_WDATA,
          S_AXI_WSTRB => S_AXI_WSTRB,
          S_AXI_WVALID => S_AXI_WVALID,
          S_AXI_BREADY => S_AXI_BREADY,
          S_AXI_ARADDR => S_AXI_ARADDR,
          S_AXI_ARVALID => S_AXI_ARVALID,
          S_AXI_RREADY => S_AXI_RREADY,
          S_AXI_ARREADY => S_AXI_ARREADY,
          S_AXI_RDATA => S_AXI_RDATA,
          S_AXI_RRESP => S_AXI_RRESP,
          S_AXI_RVALID => S_AXI_RVALID,
          S_AXI_WREADY => S_AXI_WREADY,
          S_AXI_BRESP => S_AXI_BRESP,
          S_AXI_BVALID => S_AXI_BVALID,
          S_AXI_AWREADY => S_AXI_AWREADY,
          Bus2IP_Clk => Bus2IP_Clk,
          Bus2IP_Resetn => Bus2IP_Resetn,
          Bus2IP_Addr => Bus2IP_Addr,
          Bus2IP_BE => Bus2IP_BE,
          Bus2IP_Wr => Bus2IP_Wr,
          Bus2IP_Rd => Bus2IP_Rd,
          Bus2IP_Data => Bus2IP_Data,
          IP2Bus_Data => IP2Bus_Data,
          IP2Bus_rdAck => IP2Bus_rdAck,
          IP2Bus_wrAck => IP2Bus_wrAck
        );

	wd_rw_str <= Bus2IP_Wr or Bus2IP_Rd;
		
	i_can_top : component can_top port map
	( 
		--Common Wishbone Signals
		  wb_clk_i	=> Bus2IP_Clk,
		  wb_rst_i	=> (not Bus2IP_Resetn),
		--Data Bus Signals  
		  wb_dat_i	=> Bus2IP_Data,
		  wb_dat_o	=> IP2Bus_Data,
		--Bus Cycle Signals
		  wb_cyc_i	=> '1',--(1'b1), //if 1 is here, SLAVE DAT_O should be selected
		  wb_stb_i 	=> wd_rw_str,--(slv_write_ack | slv_read_ack), //kind of chip select
		  wb_we_i	=> Bus2IP_Wr,--(slv_write_ack),	//Active High Write Enable
		  wb_adr_i	=> Bus2IP_Addr(9 downto 2),--(axi_addr),	//Address
		  wb_ack_o	=> wb_ack_tmp,--(wb_ack_tmp), //Active High Acknowledge
		  
		  clk_i			=> Bus2IP_Clk,
		  rx_i			=> CAN_RX,
		  tx_o			=> CAN_TX,
		  bus_off_on	=> CAN_BOFF,
		  irq_on		=> CAN_IRQ
		--  .clkout_o()
	);
		
   -- Clock process definitions
   S_AXI_ACLK_process :process
   begin
		S_AXI_ACLK <= '0';
		wait for S_AXI_ACLK_period/2;
		S_AXI_ACLK <= '1';
		wait for S_AXI_ACLK_period/2;
   end process;

   -- Bus2IP_Clk_process :process
   -- begin
		-- Bus2IP_Clk <= '0';
		-- wait for Bus2IP_Clk_period/2;
		-- Bus2IP_Clk <= '1';
		-- wait for Bus2IP_Clk_period/2;
   -- end process;
   
   -- Bus2IP_Clk_process :process
   -- begin
		-- Bus2IP_Clk <= '0';
		-- wait for Bus2IP_Clk_period/2;
		-- Bus2IP_Clk <= '1';
		-- wait for Bus2IP_Clk_period/2;
   -- end process;
 

   -- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;	
		
		wait for S_AXI_ACLK_period*10;
		S_AXI_ARESETN	<= '1';
		-- insert stimulus here 
		wait for S_AXI_ACLK_period*10;
		--
		write_axi(
			clock 	=> S_AXI_ACLK,
			wr_data => to_unsigned(16#1ABC4123#, 32),
			wr_addr	=> to_unsigned(16#A1#, 30) & "00",
			--signals to module
			S_AXI_AWADDR	=> S_AXI_AWADDR,
			S_AXI_AWVALID	=> S_AXI_AWVALID,	
			S_AXI_WDATA		=> S_AXI_WDATA,	
			S_AXI_WSTRB		=> S_AXI_WSTRB,	
			S_AXI_WVALID 	=> S_AXI_WVALID,	
			S_AXI_AWREADY	=> S_AXI_AWREADY,	
			S_AXI_WREADY	=> S_AXI_WREADY,
			S_AXI_BVALID	=> S_AXI_BVALID,
			S_AXI_BREADY	=> S_AXI_BREADY
		);
		wait for S_AXI_ACLK_period*10;
		read_axi(
			clock 			=> S_AXI_ACLK,
			rd_addr			=> to_unsigned(20, 30) & "00",
			--signals to module
			S_AXI_ARADDR	=> S_AXI_ARADDR,
			S_AXI_ARVALID	=> S_AXI_ARVALID,
			S_AXI_RVALID	=> S_AXI_RVALID,
			S_AXI_ARREADY	=> S_AXI_ARREADY,
			S_AXI_RREADY	=> S_AXI_RREADY
		);
		wait for S_AXI_ACLK_period*10;
		read_axi(
			clock 			=> S_AXI_ACLK,
			rd_addr			=> to_unsigned(24, 30) & "00",
			--signals to module
			S_AXI_ARADDR	=> S_AXI_ARADDR,
			S_AXI_ARVALID	=> S_AXI_ARVALID,
			S_AXI_RVALID	=> S_AXI_RVALID,
			S_AXI_ARREADY	=> S_AXI_ARREADY,
			S_AXI_RREADY	=> S_AXI_RREADY
		);
		
		
		wait;
	end process;

	
	
	ACK_TIMEOUT_PROC: process( S_AXI_ACLK ) is
	begin
		if ( S_AXI_ACLK'event and S_AXI_ACLK = '1' ) then
			--
			data_rd_dff <= Bus2IP_Rd;
			--
			if (data_rdy_cnt = to_unsigned(20, data_rdy_cnt'length)) then
				data_rdy_frame <= '0';
			elsif (data_rd_dff = '0') and (Bus2IP_Rd = '1') then
				data_rdy_frame <= '1';
			else
				data_rdy_frame <= data_rdy_frame;
			end if;
			--
			if data_rdy_frame = '1' then
				data_rdy_cnt <= data_rdy_cnt + 1;
			else
				data_rdy_cnt <= (others => '0');
			end if;
			--
			data_rdy_str <= '0';
			-- data_out_reg <= (others => '0');
			if (data_rdy_cnt = to_unsigned(20, data_rdy_cnt'length)) then
				data_rdy_str <= '1';
				-- data_out_reg <= wb_data_out_tmp;
			end if;
			--
		end if;

	end process ACK_TIMEOUT_PROC;

	IP2Bus_wrAck <= Bus2IP_Wr and wb_ack_tmp;--Bus2IP_Wr;
	IP2Bus_rdAck <= Bus2IP_Rd and wb_ack_tmp;--data_rdy_str;
	
END;
