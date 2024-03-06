--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:37:07 04/14/2017
-- Design Name:   
-- Module Name:   D:/_OLD_D/_work/PLT_A2/PLD/plt_a2/mb_system/pcores/my_can_lite_v1_00_a/hdl/vhdl_tb/can_top_tb.vhd
-- Project Name:  my_can_lite
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: can_top
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
--use ieee.numeric_std.all;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_UNSIGNED.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY can_top_tb IS
END can_top_tb;
 
ARCHITECTURE behavior OF can_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
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
	
	COMPONENT ref_can_top
    PORT(
         wb_clk_i 	: IN 	std_logic;
			wb_rst_i 	: IN 	std_logic;
			wb_dat_i 	: IN 	std_logic_vector(7 downto 0);
			wb_dat_o 	: OUT std_logic_vector(7 downto 0);
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
    
	 
	type CAN_PLAYLOAD is array (0 to 7) of UNSIGNED(7 downto 0);
	type CAN_FILTER_TYPE is array (0 to 31) of UNSIGNED(31 downto 0);

   --Inputs
   signal wb_clk_i : std_logic := '0';
   signal wb_rst_i : std_logic := '1';
	signal wb_dat_i : std_logic_vector(7 downto 0) := (others => '0');
   signal wb_cyc_i : std_logic := '0';
   signal wb_stb_i : std_logic := '0';
   signal wb_we_i : std_logic := '0';
	signal wb_adr_i : std_logic_vector(7 downto 0) := (others => '0');
   signal clk_i : std_logic := '0';
   signal rx_and_tx : std_logic;
   signal tx : std_logic;
   signal tx_tmp1 : std_logic;
   signal tx_tmp2 : std_logic;

	--Outputs
	signal wb_dat_o : std_logic_vector(7 downto 0);
	signal wb_ack_o : std_logic;
   signal tx_o : std_logic;
   signal bus_off_on : std_logic;
   signal irq_on : std_logic;
   signal clkout_o : std_logic;
 
 --CAN1 Inputs
    signal can1_wb_clk_i : std_logic := '0';
	signal can1_wb_rst_i : std_logic := '1';
	signal can1_wb_dat_i : std_logic_vector(31 downto 0) := (others => '0');
	signal can1_wb_cyc_i : std_logic := '0';
	signal can1_wb_stb_i : std_logic := '0';
	signal can1_wb_we_i : std_logic := '0';
	signal can1_wb_adr_i : std_logic_vector(7 downto 0) := (others => '0');
	signal can1_clk_i : std_logic := '0';
	--Outputs
	signal can1_wb_dat_o : std_logic_vector(31 downto 0);
	signal can1_wb_ack_o : std_logic;
	signal can1_tx_o : std_logic;
	signal can1_bus_off_on : std_logic;
	signal can1_irq_on : std_logic;
	signal can1_clkout_o : std_logic;
   
 	
	--
	   --Custom Signals
   signal can_filter_wr_codes 	: CAN_FILTER_TYPE := (others => (others => '0'));
   signal can_mask_wr_codes 	: CAN_FILTER_TYPE := (others => (others => '0'));
   signal can_filter_rd_codes 	: CAN_FILTER_TYPE := (others => (others => '0'));
   signal can_mask_rd_codes 	: CAN_FILTER_TYPE := (others => (others => '0'));
	signal can_tx_data 	: CAN_PLAYLOAD := (others => (others => '0'));
	signal can_rx_data 	: CAN_PLAYLOAD := (others => (others => '0'));
	signal rd_dlc 		: UNSIGNED(3 downto 0);
	signal rd_arb_code 	: UNSIGNED(10 downto 0);
	signal filter_match_num : Unsigned(4 downto 0);
   -- Clock period definitions
   constant clk_i_period : time := 20 ns;
 
	--stimulus procedures
	procedure write_wishbone(	 
		signal clock 	: in std_logic;
		wr_data 	: in UNSIGNED(7 downto 0); 
		wr_addr	: in UNSIGNED(7 downto 0); 
		--signals to module
		signal wb_dat_i	: out std_logic_vector(7 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic
	) 	is
	begin
		wait until rising_edge(clock);
		wb_we_i <= '1';
		wb_adr_i <= std_logic_vector(wr_addr);
		wb_dat_i <= std_logic_vector(wr_data);
		wb_cyc_i <= '1';
		wb_stb_i <= '1';
		wait until (rising_edge(clock) and wb_ack_o = '1');		
		wb_we_i <= '0';
		wb_adr_i <= (others => '0');
		wb_dat_i <= (others => '0');
		wb_cyc_i <= '0';
		wb_stb_i <= '0';
	end;

	procedure read_wishbone(
		rd_addr	: in UNSIGNED(7 downto 0); 
		rd_data	: out UNSIGNED(7 downto 0); 
		--signals to module
		signal clock 	: in std_logic;
		signal wb_dat_i	: out std_logic_vector(7 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic;
		signal wb_dat_o : in std_logic_vector(7 downto 0)
	) is
	begin
		wait until rising_edge(clock);
		wb_we_i <= '0';
		wb_adr_i <= std_logic_vector(rd_addr);
		wb_cyc_i <= '1';
		wb_stb_i <= '1';
		wait until (rising_edge(clock) and wb_ack_o = '1');		
		wb_we_i <= '0';
		wb_adr_i <= (others => '0');
		rd_data := unsigned(wb_dat_o);
		wb_cyc_i <= '0';
		wb_stb_i <= '0';
	end;
	--
	procedure read_d32_wishbone(
		rd_addr	: in  UNSIGNED( 7 downto 0); 
		rd_data	: out UNSIGNED(31 downto 0); 
		--signals to module
		signal clock 	: in std_logic;
		signal wb_dat_i	: out std_logic_vector(31 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic;
		signal wb_dat_o : in std_logic_vector(31 downto 0)
	) is
	begin
		wait until rising_edge(clock);
		wb_we_i <= '0';
		wb_adr_i <= std_logic_vector(rd_addr);
		wb_cyc_i <= '1';
		wb_stb_i <= '1';
		wait until (rising_edge(clock) and wb_ack_o = '1');		
		wb_we_i <= '0';
		wb_adr_i <= (others => '0');
		rd_data := unsigned(wb_dat_o);
		wb_cyc_i <= '0';
		wb_stb_i <= '0';
	end;
	--
	procedure write_d32_wishbone(	 
		signal clock 	: in std_logic;
		wr_data 		: in UNSIGNED(31 downto 0); 
		wr_addr			: in UNSIGNED(7 downto 0); 
		--signals to module
		signal wb_dat_i	: out std_logic_vector(31 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic
	) 	is
	begin
		wait until rising_edge(clock);
		wb_we_i <= '1';
		wb_adr_i <= std_logic_vector(wr_addr);
		wb_dat_i <= std_logic_vector(wr_data);
		wb_cyc_i <= '1';
		wb_stb_i <= '1';
		wait until (rising_edge(clock) and wb_ack_o = '1');		
		wb_we_i <= '0';
		wb_adr_i <= (others => '0');
		wb_dat_i <= (others => '0');
		wb_cyc_i <= '0';
		wb_stb_i <= '0';
	end;	

	-- Test Filter Memory
	procedure write_can_filter(
		signal clk 	: in std_logic;
		wr_addr 	: in UNSIGNED(4 downto 0);
		wr_filter 	: in UNSIGNED(31 downto 0); 
		wr_mask 	: in UNSIGNED(31 downto 0);
		signal wb_dat_i	: out std_logic_vector(31 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic
	)	is
	begin
		write_d32_wishbone
		(
			clock => clk, 
			wr_data => to_unsigned(0, 26) & '0' & wr_addr, 
			wr_addr => to_unsigned(40, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		write_d32_wishbone
		(
			clock => clk, 
			wr_data => wr_filter, 
			wr_addr => to_unsigned(46, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		write_d32_wishbone
		(
			clock => clk, 
			wr_data => to_unsigned(0, 26) & '1' & wr_addr, 
			wr_addr => to_unsigned(40, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		write_d32_wishbone
		(
			clock => clk, 
			wr_data => wr_mask, 
			wr_addr => to_unsigned(46, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
	end;
	
	procedure read_can_filter(
		signal clk 	: in std_logic;
		rd_addr 	: in UNSIGNED(4 downto 0);
		rd_filter_data	: out UNSIGNED(31 downto 0);
		rd_mask_data	: out UNSIGNED(31 downto 0);
		signal wb_dat_i	: out std_logic_vector(31 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic;
		signal wb_dat_o : in std_logic_vector(31 downto 0)
	) is
	begin
		write_d32_wishbone
		(
			clock => clk, 
			wr_data => to_unsigned(0, 26) & '0' & rd_addr, 
			wr_addr => to_unsigned(40, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		read_d32_wishbone(
			rd_addr => to_unsigned(46, 8),
			rd_data => rd_filter_data,
			clock => clk, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o,
			wb_dat_o => wb_dat_o
		);
		write_d32_wishbone
		(
			clock => clk, 
			wr_data => to_unsigned(0, 26) & '1' & rd_addr, 
			wr_addr => to_unsigned(40, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		read_d32_wishbone(
			rd_addr => to_unsigned(46, 8),
			rd_data => rd_mask_data,
			clock => clk, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o,
			wb_dat_o => wb_dat_o
		);
	end;
	
	--init CAN core
 	procedure init_can_via_wishbone(	 
		signal clock 	: in std_logic;
		--signals to module
		signal wb_dat_i	: out std_logic_vector(7 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic
	) 	is
	begin
		
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(1, 8), 
			wr_addr => to_unsigned(0, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		); 
		wait for 10*clk_i_period;
		--set ClockDivideReg
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(16#80#, 8), 
			wr_addr => to_unsigned(31, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		); 
		--set acceptance filters
		for i in 16 to 19 loop
			wait for 10*clk_i_period;
			write_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(0, 8), 
				wr_addr => to_unsigned(i, 8),
				wb_dat_i => wb_dat_i,
				wb_adr_i => wb_adr_i,
				wb_cyc_i => wb_cyc_i,
				wb_stb_i => wb_stb_i,
				wb_we_i  => wb_we_i,
				wb_ack_o => wb_ack_o
			); 
			wait for 10*clk_i_period;
			write_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(16#FF#, 8), 
				wr_addr => to_unsigned(i+4, 8),
				wb_dat_i => wb_dat_i,
				wb_adr_i => wb_adr_i,
				wb_cyc_i => wb_cyc_i,
				wb_stb_i => wb_stb_i,
				wb_we_i  => wb_we_i,
				wb_ack_o => wb_ack_o
			); 
		end loop;
		--BusTiming0Reg
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(0, 8), 
			wr_addr => to_unsigned(6, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		); 
		--BusTiming1Reg
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(16#7F#, 8), 
			wr_addr => to_unsigned(7, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		); 
		--OutControlReg
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(16#1A#, 8), 
			wr_addr => to_unsigned(8, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		); 
		--InterruptEnReg
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(16#8F#, 8), 
			wr_addr => to_unsigned(4, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		); 
		--enter normal mode
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(0, 8), 
			wr_addr => to_unsigned(0, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		); 
	end;
	
--Can Send
	procedure can_send(	 
		arb_code	: in UNSIGNED(10 downto 0); 
		dlc		: in UNSIGNED(3 downto 0);
		bytes		: in CAN_PLAYLOAD;	
		--signals to module
		signal clock 	: in std_logic;
		signal wb_dat_i	: out std_logic_vector(7 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i		: out std_logic;
		signal wb_ack_o	: in  std_logic
	) 	is
	variable i : integer;
	begin
	--CAN SEND SOMETHING
		--	TxFrameInfo
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(0, 4) & dlc, 
			wr_addr => to_unsigned(16, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		-- TxBuffer1
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => arb_code(10 downto 3), 
			wr_addr => to_unsigned(17, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		-- TxBuffer2
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => arb_code(2 downto 0) & to_unsigned(0, 5), 
			wr_addr => to_unsigned(18, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		-- TxBuffer3
		for i in 0 to to_integer(dlc-1) loop
			wait for 10*clk_i_period;
			write_wishbone(
				clock => clk_i, 
				wr_data => bytes(i), 
				wr_addr => to_unsigned(19+i, 8),
				wb_dat_i => wb_dat_i,
				wb_adr_i => wb_adr_i,
				wb_cyc_i => wb_cyc_i,
				wb_stb_i => wb_stb_i,
				wb_we_i  => wb_we_i,
				wb_ack_o => wb_ack_o
			);
		end loop;
		--CommandReg
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(1, 8), 
			wr_addr => to_unsigned(1, 8),
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
	--END CAN SEND		
	end;
	
	procedure can_service_irq(	 
		arb_code	: out UNSIGNED(10 downto 0); 
		dlc			: out UNSIGNED(3 downto 0);
		bytes		: out CAN_PLAYLOAD;	
		--signals to module
		signal irq_n : in std_logic;
		signal clock 	: in std_logic;
		signal wb_dat_i	: out std_logic_vector(7 downto 0);
		signal wb_adr_i	: out std_logic_vector(7 downto 0);
		signal wb_cyc_i	: out std_logic;
		signal wb_stb_i	: out std_logic;
		signal wb_we_i	: out std_logic;
		signal wb_ack_o	: in  std_logic;
		signal wb_dat_o : in std_logic_vector(7 downto 0)
	) 	is
	variable isr_status : UNSIGNED(7 downto 0);
	variable data_tmp : UNSIGNED(7 downto 0);
	begin
		--Read State
		wait until rising_edge(clock) and irq_n = '0';
		read_wishbone(
			rd_addr => to_unsigned(3, 8),
			rd_data => isr_status,
			clock => clk_i, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o,
			wb_dat_o => wb_dat_o
		);
		
		-- if isr_status(0) then
			-- read_wishbone(
			-- rd_addr => to_unsigned(16, 8),
			-- rd_data => data_tmp,
			-- clock => clk_i, 
			-- wb_dat_i => wb_dat_i,
			-- wb_adr_i => wb_adr_i,
			-- wb_cyc_i => wb_cyc_i,
			-- wb_stb_i => wb_stb_i,
			-- wb_we_i  => wb_we_i,
			-- wb_ack_o => wb_ack_o,
			-- wb_dat_o => wb_dat_o
		-- );
		-- end if;
	end;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	can1: can_top PORT MAP (
         wb_clk_i => wb_clk_i,
			 wb_rst_i => wb_rst_i,
			 wb_dat_i => can1_wb_dat_i,
			 wb_dat_o => can1_wb_dat_o,
			 wb_cyc_i => can1_wb_cyc_i,
			 wb_stb_i => can1_wb_stb_i,
			 wb_we_i  => can1_wb_we_i,
			 wb_adr_i => can1_wb_adr_i,
			 wb_ack_o => can1_wb_ack_o,
         clk_i    => clk_i,
         rx_i 	 => rx_and_tx,
         tx_o 	 => can1_tx_o,
         bus_off_on => can1_bus_off_on,
         irq_on 	 => can1_irq_on,
         clkout_o => can1_clkout_o
       );
	
   uut: ref_can_top PORT MAP (
          wb_clk_i => wb_clk_i,
			 wb_rst_i => wb_rst_i,
			 wb_dat_i => wb_dat_i,
			 wb_dat_o => wb_dat_o,
			 wb_cyc_i => wb_cyc_i,
			 wb_stb_i => wb_stb_i,
			 wb_we_i  => wb_we_i,
			 wb_adr_i => wb_adr_i,
			 wb_ack_o => wb_ack_o,
          clk_i    => clk_i,
          rx_i 	 => rx_and_tx,
          tx_o 	 => tx_o,
          bus_off_on => bus_off_on,
          irq_on 	 => irq_on,
          clkout_o => clkout_o
        );
	
	tx_tmp1 <= tx_o when (bus_off_on = '1') else '1';
	tx_tmp2 <= can1_tx_o when (can1_bus_off_on = '1') else '1';
	--tx 			<= tx_tmp1;
	tx 			<= tx_tmp1 and tx_tmp2;
	rx_and_tx 	<= tx;
	
    -- Clock process definitions
   clk_i_process :process
   begin
		wb_clk_i <= '0';
		clk_i <= '0';
		wait for clk_i_period/2;
		wb_clk_i <= '1';
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
		--Variables
	variable i : integer := 0;
	variable j : integer := 0;
	variable isr_status 	: UNSIGNED(7 downto 0);
	variable isr_data_tmp 	: UNSIGNED(7 downto 0);
	variable isr_data_d32_tmp : UNSIGNED(31 downto 0);
	variable wr_d32_tmp 	: UNSIGNED(31 downto 0);
	variable rd_filter_tmp : UNSIGNED(31 downto 0);
	variable rd_mask_tmp : UNSIGNED(31 downto 0);
	
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		wb_rst_i <= '0';
      wait for clk_i_period*10;

		init_can_via_wishbone(
			clock => clk_i, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		
		init_can_via_wishbone(
			clock => clk_i, 
			wb_dat_i => can1_wb_dat_i(7 downto 0),
			wb_adr_i => can1_wb_adr_i,
			wb_cyc_i => can1_wb_cyc_i,
			wb_stb_i => can1_wb_stb_i,
			wb_we_i  => can1_wb_we_i,
			wb_ack_o => can1_wb_ack_o
		);

--Test Filter Memory
		--fill can_filter_values
		for i in 0 to 7 loop
			for j in 0 to 3 loop
				can_filter_wr_codes(j+4*i) <= '1' & to_unsigned(64 * i + j, 31);
				--can_mask_wr_codes(j+4*i)   <= to_unsigned(16#7FF#, 32);
				can_mask_wr_codes(j+4*i)   <= to_unsigned(0, 32);
			end loop;		
		end loop;
		
-- Write can_filter_values into memory
	--Enter Reset Mode
		wait until rising_edge(clk_i);
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(1, 8), 
			wr_addr => to_unsigned(0, 8),
			wb_dat_i => can1_wb_dat_i(7 downto 0),
			wb_adr_i => can1_wb_adr_i,
			wb_cyc_i => can1_wb_cyc_i,
			wb_stb_i => can1_wb_stb_i,
			wb_we_i  => can1_wb_we_i,
			wb_ack_o => can1_wb_ack_o
		);
	--Write Filter Memory
		for i in 0 to 31 loop
--			wait until rising_edge(clk);
			write_can_filter(
				clk 			=> clk_i,
				wr_addr 		=> to_unsigned(i, 5),
				wr_filter 	=> can_filter_wr_codes(i),
				wr_mask 		=> can_mask_wr_codes(i),
				
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o
			);
		end loop;	
	
		for i in 0 to 31 loop
			read_can_filter(
				clk 			=> clk_i,
				rd_addr 		=> to_unsigned(i, 5),
				rd_filter_data	=> rd_filter_tmp,
				rd_mask_data	=> rd_mask_tmp, 
					
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o,
				wb_dat_o => can1_wb_dat_o
			);
			can_filter_rd_codes(i) <= rd_filter_tmp;
			can_mask_rd_codes(i) <= rd_mask_tmp;
		end loop;
		
		wait until rising_edge(clk_i);
-- Compare Writed and Readed data		
		for i in 0 to 31 loop
			assert (can_filter_rd_codes(i) = can_filter_wr_codes(i))
			report "(can_filter_rd_codes != can_filter_wr_codes)"
			severity error;
			
			assert (can_mask_rd_codes(i) = can_mask_wr_codes(i))
			report "(can_filter_rd_codes != can_filter_wr_codes)"
			severity error;
			
		end loop;
		
		--Enter normal mode
		wait until rising_edge(clk_i);
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(0, 8), 
			wr_addr => to_unsigned(0, 8),
			wb_dat_i => can1_wb_dat_i(7 downto 0),
			wb_adr_i => can1_wb_adr_i,
			wb_cyc_i => can1_wb_cyc_i,
			wb_stb_i => can1_wb_stb_i,
			wb_we_i  => can1_wb_we_i,
			wb_ack_o => can1_wb_ack_o
		);
--End of Filter Memory Test
		
		can_tx_data(0) <= to_unsigned(16#5A#, 8);
		can_tx_data(1) <= to_unsigned(16#A5#, 8);
		can_tx_data(2) <= to_unsigned(16#00#, 8);
		can_tx_data(3) <= to_unsigned(16#FF#, 8);
		can_tx_data(4) <= to_unsigned(16#12#, 8);
		can_tx_data(5) <= to_unsigned(16#34#, 8);
		can_tx_data(6) <= to_unsigned(16#56#, 8);
		can_tx_data(7) <= to_unsigned(16#78#, 8);
		wait for 2000*clk_i_period;
		can_send(
			arb_code => to_unsigned(64 * 7 + 3, 11),
			dlc => to_unsigned(8, 4),
			bytes => can_tx_data,
			clock => clk_i, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		
		wait until rising_edge(clk_i) and irq_on = '0';
		wait for 10*clk_i_period;
		
		wait until rising_edge(clk_i) and irq_on = '0';
		read_wishbone(
			rd_addr => to_unsigned(3, 8),
			rd_data => isr_status,
			clock => clk_i, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o,
			wb_dat_o => wb_dat_o
		);
		
		can_tx_data(0) <= to_unsigned(16#11#, 8);
		can_tx_data(1) <= to_unsigned(16#22#, 8);
		can_tx_data(2) <= to_unsigned(16#33#, 8);
		can_tx_data(3) <= to_unsigned(16#44#, 8);
		can_tx_data(4) <= to_unsigned(16#55#, 8);
		can_tx_data(5) <= to_unsigned(16#66#, 8);
		can_tx_data(6) <= to_unsigned(16#77#, 8);
		can_tx_data(7) <= to_unsigned(16#88#, 8);
		wait for 200*clk_i_period;
		can_send(
			arb_code => to_unsigned(64 * 5 + 1, 11),
			dlc => to_unsigned(8, 4),
			bytes => can_tx_data,
			clock => clk_i, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o
		);
		
		wait until rising_edge(clk_i) and irq_on = '0';
		wait for 10*clk_i_period;
		
		wait until rising_edge(clk_i) and irq_on = '0';
		read_wishbone(
			rd_addr => to_unsigned(3, 8),
			rd_data => isr_status,
			clock => clk_i, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o,
			wb_dat_o => wb_dat_o
		);
		
		--
		-- CAN1 ISR routing
		--
		wait until rising_edge(clk_i) and can1_irq_on = '0';
		wait for 10*clk_i_period;
		
		wait until rising_edge(clk_i) and can1_irq_on = '0';
		read_wishbone(
			rd_addr => to_unsigned(3, 8),
			rd_data => isr_status,
			clock => clk_i, 
			wb_dat_i => can1_wb_dat_i(7 downto 0),
			wb_adr_i => can1_wb_adr_i,
			wb_cyc_i => can1_wb_cyc_i,
			wb_stb_i => can1_wb_stb_i,
			wb_we_i  => can1_wb_we_i,
			wb_ack_o => can1_wb_ack_o,
			wb_dat_o => can1_wb_dat_o(7 downto 0)
		);
		
		if isr_status(0) = '1' then
			--
			--
			--D32 test readings
			wait until rising_edge(clk_i);
			read_d32_wishbone(
				rd_addr => to_unsigned(16, 8),
				rd_data => isr_data_d32_tmp,
				clock => clk_i, 
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o,
				wb_dat_o => can1_wb_dat_o
			);
			wait until rising_edge(clk_i);
			rd_dlc 						<= isr_data_d32_tmp(3 downto 0);
			rd_arb_code(10 downto 3) 	<= isr_data_d32_tmp(15 downto 8);
			rd_arb_code(2 downto 0) 	<= isr_data_d32_tmp(23 downto 21);
			filter_match_num			<= isr_data_d32_tmp(28 downto 24);
			--
			wait until rising_edge(clk_i);
			read_d32_wishbone(
				rd_addr => to_unsigned(20, 8),
				rd_data => isr_data_d32_tmp,
				clock => clk_i, 
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o,
				wb_dat_o => can1_wb_dat_o
			);
			wait until rising_edge(clk_i);
			can_rx_data(0) 				<= isr_data_d32_tmp( 7 downto  0);
			can_rx_data(1) 				<= isr_data_d32_tmp(15 downto  8);
			can_rx_data(2) 				<= isr_data_d32_tmp(23 downto 16);
			can_rx_data(3) 				<= isr_data_d32_tmp(31 downto 24);
			--
			wait until rising_edge(clk_i);
			read_d32_wishbone(
				rd_addr => to_unsigned(24, 8),
				rd_data => isr_data_d32_tmp,
				clock => clk_i, 
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o,
				wb_dat_o => can1_wb_dat_o
			);
			wait until rising_edge(clk_i);
			can_rx_data(4) 				<= isr_data_d32_tmp( 7 downto  0);
			can_rx_data(5) 				<= isr_data_d32_tmp(15 downto  8);
			can_rx_data(6) 				<= isr_data_d32_tmp(23 downto 16);
			can_rx_data(7) 				<= isr_data_d32_tmp(31 downto 24);
			--Test At D8
			can_tx_data(0) <= to_unsigned(16#5A#, 8);
			can_tx_data(1) <= to_unsigned(16#A5#, 8);
			can_tx_data(2) <= to_unsigned(16#00#, 8);
			can_tx_data(3) <= to_unsigned(16#FF#, 8);
			can_tx_data(4) <= to_unsigned(16#12#, 8);
			can_tx_data(5) <= to_unsigned(16#34#, 8);
			can_tx_data(6) <= to_unsigned(16#56#, 8);
			can_tx_data(7) <= to_unsigned(16#78#, 8);
			--
			wait until rising_edge(clk_i);
			
			assert (rd_dlc = to_unsigned(8, 4))
			report "(rd_dlc != to_unsigned(8, 4))"
			severity error;
			--
			assert (rd_arb_code = to_unsigned(64 * 7 + 3, 11))
			report "(rd_arb_code != to_unsigned(8, 4))"
			severity error;
			--
			for i in 0 to to_integer(rd_dlc-1) loop
				assert (can_rx_data(i) = can_tx_data(i))
				report "(can data is wrong)"
				severity error;
			end loop;
			--
			
			--release buffer
			wait until rising_edge(clk_i);
			--
			write_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(4, 8), 
				wr_addr => to_unsigned(1, 8),
				wb_dat_i => can1_wb_dat_i(7 downto 0),
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o
			);
			
			--Read Frame Info
			wait until rising_edge(clk_i);
			read_wishbone(
				rd_addr => to_unsigned(16, 8),
				rd_data => isr_data_tmp,
				clock => clk_i, 
				wb_dat_i => can1_wb_dat_i(7 downto 0),
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o,
				wb_dat_o => can1_wb_dat_o(7 downto 0)
			);
			--
			wait until rising_edge(clk_i);
			--
			rd_dlc <= isr_data_tmp(3 downto 0);
			--
			--Read CAN ID Byte0
			wait until rising_edge(clk_i);
			read_wishbone(
				rd_addr => to_unsigned(17, 8),
				rd_data => isr_data_tmp,
				clock => clk_i, 
				wb_dat_i => can1_wb_dat_i(7 downto 0),
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o,
				wb_dat_o => can1_wb_dat_o(7 downto 0)
			);
			--
			wait until rising_edge(clk_i);
			--
			rd_arb_code(10 downto 3) <= isr_data_tmp;
			--
			--Read CAN ID Byte1
			wait until rising_edge(clk_i);
			read_wishbone(
				rd_addr => to_unsigned(18, 8),
				rd_data => isr_data_tmp,
				clock => clk_i, 
				wb_dat_i => can1_wb_dat_i(7 downto 0),
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o,
				wb_dat_o => can1_wb_dat_o(7 downto 0)
			);
			--
			wait until rising_edge(clk_i);
			--
			rd_arb_code(2 downto 0) <= isr_data_tmp(7 downto 5);
			--data reading loop
			for i in 0 to to_integer(rd_dlc-1) loop
				wait until rising_edge(clk_i);
				read_wishbone(
					rd_addr => to_unsigned(20+i, 8),
					rd_data => isr_data_tmp,
					clock => clk_i, 
					wb_dat_i => can1_wb_dat_i(7 downto 0),
					wb_adr_i => can1_wb_adr_i,
					wb_cyc_i => can1_wb_cyc_i,
					wb_stb_i => can1_wb_stb_i,
					wb_we_i  => can1_wb_we_i,
					wb_ack_o => can1_wb_ack_o,
					wb_dat_o => can1_wb_dat_o(7 downto 0)
				);
				wait until rising_edge(clk_i);
				can_rx_data(i) <= isr_data_tmp;
			end loop;
			--release buffer
			wait until rising_edge(clk_i);
			--
			write_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(4, 8), 
				wr_addr => to_unsigned(1, 8),
				wb_dat_i => can1_wb_dat_i(7 downto 0),
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o
			);
		end if;


		
		--Send from CAN1 to CAN0 using D32 access
		--
		wait for 10*clk_i_period;
		write_d32_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(16#11A04C08#, 32), 
				wr_addr => to_unsigned(16 , 8),
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o
			);
		write_d32_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(16#55443322#, 32), 
				wr_addr => to_unsigned(20 , 8),
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o
			);
		write_d32_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(16#00887766#, 32), 
				wr_addr => to_unsigned(24 , 8),
				wb_dat_i => can1_wb_dat_i,
				wb_adr_i => can1_wb_adr_i,
				wb_cyc_i => can1_wb_cyc_i,
				wb_stb_i => can1_wb_stb_i,
				wb_we_i  => can1_wb_we_i,
				wb_ack_o => can1_wb_ack_o
			);
		--
		wait for 10*clk_i_period;
		write_wishbone(
			clock => clk_i, 
			wr_data => to_unsigned(1, 8), 
			wr_addr => to_unsigned(1, 8),
			wb_dat_i => can1_wb_dat_i(7 downto 0),
			wb_adr_i => can1_wb_adr_i,
			wb_cyc_i => can1_wb_cyc_i,
			wb_stb_i => can1_wb_stb_i,
			wb_we_i  => can1_wb_we_i,
			wb_ack_o => can1_wb_ack_o
		);
		--
		--
		-- CAN0 ISR routing
		--
		wait until rising_edge(clk_i) and irq_on = '0';
		wait for 10*clk_i_period;
		
		wait until rising_edge(clk_i) and irq_on = '0';
		read_wishbone(
			rd_addr => to_unsigned(3, 8),
			rd_data => isr_status,
			clock => clk_i, 
			wb_dat_i => wb_dat_i,
			wb_adr_i => wb_adr_i,
			wb_cyc_i => wb_cyc_i,
			wb_stb_i => wb_stb_i,
			wb_we_i  => wb_we_i,
			wb_ack_o => wb_ack_o,
			wb_dat_o => wb_dat_o
		);
		
		if isr_status(0) = '1' then
					--
			--Read Frame Info
			wait until rising_edge(clk_i);
			read_wishbone(
				rd_addr => to_unsigned(16, 8),
				rd_data => isr_data_tmp,
				clock => clk_i, 
				wb_dat_i => wb_dat_i(7 downto 0),
				wb_adr_i => wb_adr_i,
				wb_cyc_i => wb_cyc_i,
				wb_stb_i => wb_stb_i,
				wb_we_i  => wb_we_i,
				wb_ack_o => wb_ack_o,
				wb_dat_o => wb_dat_o(7 downto 0)
			);
			--
			wait until rising_edge(clk_i);
			--
			rd_dlc <= isr_data_tmp(3 downto 0);
			--
			--Read CAN ID Byte0
			wait until rising_edge(clk_i);
			read_wishbone(
				rd_addr => to_unsigned(17, 8),
				rd_data => isr_data_tmp,
				clock => clk_i, 
				wb_dat_i => wb_dat_i(7 downto 0),
				wb_adr_i => wb_adr_i,
				wb_cyc_i => wb_cyc_i,
				wb_stb_i => wb_stb_i,
				wb_we_i  => wb_we_i,
				wb_ack_o => wb_ack_o,
				wb_dat_o => wb_dat_o(7 downto 0)
			);
			--
			wait until rising_edge(clk_i);
			--
			rd_arb_code(10 downto 3) <= isr_data_tmp;
			--
			--Read CAN ID Byte1
			wait until rising_edge(clk_i);
			read_wishbone(
				rd_addr => to_unsigned(18, 8),
				rd_data => isr_data_tmp,
				clock => clk_i, 
				wb_dat_i => wb_dat_i(7 downto 0),
				wb_adr_i => wb_adr_i,
				wb_cyc_i => wb_cyc_i,
				wb_stb_i => wb_stb_i,
				wb_we_i  => wb_we_i,
				wb_ack_o => wb_ack_o,
				wb_dat_o => wb_dat_o(7 downto 0)
			);
			--
			wait until rising_edge(clk_i);
			--
			rd_arb_code(2 downto 0) <= isr_data_tmp(7 downto 5);
			--data reading loop
			for i in 0 to to_integer(rd_dlc-1) loop
				wait until rising_edge(clk_i);
				read_wishbone(
					rd_addr => to_unsigned(19+i, 8),
					rd_data => isr_data_tmp,
					clock => clk_i, 
					wb_dat_i => wb_dat_i(7 downto 0),
					wb_adr_i => wb_adr_i,
					wb_cyc_i => wb_cyc_i,
					wb_stb_i => wb_stb_i,
					wb_we_i  => wb_we_i,
					wb_ack_o => wb_ack_o,
					wb_dat_o => wb_dat_o(7 downto 0)
				);
				wait until rising_edge(clk_i);
				can_rx_data(i) <= isr_data_tmp;
			end loop;
			--release buffer
			wait until rising_edge(clk_i);
			--
			write_wishbone(
				clock => clk_i, 
				wr_data => to_unsigned(4, 8), 
				wr_addr => to_unsigned(1, 8),
				wb_dat_i => wb_dat_i(7 downto 0),
				wb_adr_i => wb_adr_i,
				wb_cyc_i => wb_cyc_i,
				wb_stb_i => wb_stb_i,
				wb_we_i  => wb_we_i,
				wb_ack_o => wb_ack_o
			);
		end if;
      wait;
   end process;

END;
