//----------------------------------------------------------------------------
// user_logic.v - module
//----------------------------------------------------------------------------
//
// ***************************************************************************
// ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** Xilinx, Inc.                                                          **
// ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
// ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
// ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
// ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
// ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
// ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
// ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
// ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
// ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
// ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
// ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
// ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
// ** FOR A PARTICULAR PURPOSE.                                             **
// **                                                                       **
// ***************************************************************************
//
//----------------------------------------------------------------------------
// Filename:          user_logic.v
// Version:           1.00.a
// Description:       User logic module.
// Date:              Tue Mar 28 08:29:14 2017 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

`uselib lib=unisims_ver
`uselib lib=proc_common_v3_00_a

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  CAN_RX,
  CAN_TX,
  CAN_IRQ,
  CAN_BOFF,
  CAN_CLK, 
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Resetn,                  // Bus to IP reset
  Bus2IP_Addr,                    // Bus to IP address bus
  Bus2IP_CS,                      // Bus to IP chip select
  Bus2IP_RNW,                     // Bus to IP read/not write
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_BE,                      // Bus to IP byte enables
  Bus2IP_RdCE,                    // Bus to IP read chip enable
  Bus2IP_WrCE,                    // Bus to IP write chip enable
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error                    // IP to Bus error response
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
parameter S_ADDR_BASE						 = 5;
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_NUM_REG                      = 32;
parameter C_SLV_DWIDTH                   = 32;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
input   	CAN_RX;
output  	CAN_TX;
output  	CAN_IRQ;
output  	CAN_BOFF;
input 	CAN_CLK; 
// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input                                     Bus2IP_Clk;
input                                     Bus2IP_Resetn;
input      [31 : 0]                       Bus2IP_Addr;
input                                     Bus2IP_CS;
input                                     Bus2IP_RNW;
input      [C_SLV_DWIDTH-1 : 0]           Bus2IP_Data;
input      [C_SLV_DWIDTH/8-1 : 0]         Bus2IP_BE;
input      [C_NUM_REG-1 : 0]              Bus2IP_RdCE;
input      [C_NUM_REG-1 : 0]              Bus2IP_WrCE;
output     [C_SLV_DWIDTH-1 : 0]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

 
  reg        [C_SLV_DWIDTH-1 : 0]           slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index;


  // USER logic implementation added here
	reg [(C_SLV_DWIDTH-1):0] ram [(C_NUM_REG-1):0];
	integer i;
	wire		  [(S_ADDR_BASE-1):0]		axi_addr;
 
	wire [31 : 0]	wb_data_out_tmp;
	wire				wb_ack_tmp;
 

  assign slv_write_ack	= | Bus2IP_WrCE; //Bus2IP_CS & (~Bus2IP_RNW);
  assign slv_read_ack 	= | Bus2IP_RdCE; //Bus2IP_CS & ( Bus2IP_RNW);
  assign axi_addr			= Bus2IP_Addr[(S_ADDR_BASE+1):2];
  
	can_top i_can_top
	( 
		//Common Wishbone Signals
		  .wb_clk_i(Bus2IP_Clk),
		  .wb_rst_i(~Bus2IP_Resetn),
		//Data Bus Signals  
		  .wb_dat_i(Bus2IP_Data),
		  .wb_dat_o(wb_data_out_tmp),
		//Bus Cycle Signals
		  .wb_cyc_i(1'b1), //if 1 is here, SLAVE DAT_O should be selected
		  .wb_stb_i(slv_write_ack | slv_read_ack), //kind of chip select
		  .wb_we_i(slv_write_ack),	//Active High Write Enable
		  .wb_adr_i(axi_addr),	//Address
		  .wb_ack_o(wb_ack_tmp), //Active High Acknowledge
		  
		  .clk_i(CAN_CLK),
		  .rx_i(CAN_RX),
		  .tx_o(CAN_TX),
		  .bus_off_on(CAN_BOFF),
		  .irq_on(CAN_IRQ)
		//  .clkout_o()
	);

	// assign IP2Bus_Data[7:0] = (slv_read_ack == 1'b1) ? wb_data_out_tmp :  0 ;
	// assign IP2Bus_Data[31:8] = 24'b0;	
	assign IP2Bus_Data = (slv_read_ack == 1'b1) ? wb_data_out_tmp :  0 ;
	
	assign IP2Bus_WrAck = slv_write_ack & wb_ack_tmp;
	assign IP2Bus_RdAck = slv_read_ack & wb_ack_tmp;
	assign IP2Bus_Error = 0;

endmodule
