//-----------------------------------------------------------------------------
// proc_my_can_lite_0_wrapper.v
//-----------------------------------------------------------------------------

`timescale 1 ps / 100 fs

`uselib lib=unisims_ver lib=proc_common_v3_00_a lib=axi_lite_ipif_v1_01_a lib=my_can_lite_v1_00_a

module proc_my_can_lite_0_wrapper
  (
    S_AXI_ACLK,
    S_AXI_ARESETN,
    S_AXI_AWADDR,
    S_AXI_AWVALID,
    S_AXI_WDATA,
    S_AXI_WSTRB,
    S_AXI_WVALID,
    S_AXI_BREADY,
    S_AXI_ARADDR,
    S_AXI_ARVALID,
    S_AXI_RREADY,
    S_AXI_ARREADY,
    S_AXI_RDATA,
    S_AXI_RRESP,
    S_AXI_RVALID,
    S_AXI_WREADY,
    S_AXI_BRESP,
    S_AXI_BVALID,
    S_AXI_AWREADY,
    CAN_IRQ,
    CAN_BOFF,
    CAN_RX,
    CAN_TX,
    CAN_dbg_output
  );
  input S_AXI_ACLK;
  input S_AXI_ARESETN;
  input [31:0] S_AXI_AWADDR;
  input S_AXI_AWVALID;
  input [31:0] S_AXI_WDATA;
  input [3:0] S_AXI_WSTRB;
  input S_AXI_WVALID;
  input S_AXI_BREADY;
  input [31:0] S_AXI_ARADDR;
  input S_AXI_ARVALID;
  input S_AXI_RREADY;
  output S_AXI_ARREADY;
  output [31:0] S_AXI_RDATA;
  output [1:0] S_AXI_RRESP;
  output S_AXI_RVALID;
  output S_AXI_WREADY;
  output [1:0] S_AXI_BRESP;
  output S_AXI_BVALID;
  output S_AXI_AWREADY;
  output CAN_IRQ;
  output CAN_BOFF;
  input CAN_RX;
  output CAN_TX;
  output [7:0] CAN_dbg_output;

  my_can_lite
    #(
      .C_S_AXI_DATA_WIDTH ( 32 ),
      .C_S_AXI_ADDR_WIDTH ( 32 ),
      .C_S_AXI_MIN_SIZE ( 32'h000003ff ),
      .C_USE_WSTRB ( 0 ),
      .C_DPHASE_TIMEOUT ( 8 ),
      .C_BASEADDR ( 32'h72400000 ),
      .C_HIGHADDR ( 32'h7240ffff ),
      .C_FAMILY ( "spartan6" ),
      .C_NUM_REG ( 1 ),
      .C_NUM_MEM ( 1 ),
      .C_SLV_AWIDTH ( 32 ),
      .C_SLV_DWIDTH ( 32 ),
      .RX_FIFO_BRAM_NUM ( 0 ),
      .TX_FIFO_BRAM_NUM ( 0 )
    )
    my_can_lite_0 (
      .S_AXI_ACLK ( S_AXI_ACLK ),
      .S_AXI_ARESETN ( S_AXI_ARESETN ),
      .S_AXI_AWADDR ( S_AXI_AWADDR ),
      .S_AXI_AWVALID ( S_AXI_AWVALID ),
      .S_AXI_WDATA ( S_AXI_WDATA ),
      .S_AXI_WSTRB ( S_AXI_WSTRB ),
      .S_AXI_WVALID ( S_AXI_WVALID ),
      .S_AXI_BREADY ( S_AXI_BREADY ),
      .S_AXI_ARADDR ( S_AXI_ARADDR ),
      .S_AXI_ARVALID ( S_AXI_ARVALID ),
      .S_AXI_RREADY ( S_AXI_RREADY ),
      .S_AXI_ARREADY ( S_AXI_ARREADY ),
      .S_AXI_RDATA ( S_AXI_RDATA ),
      .S_AXI_RRESP ( S_AXI_RRESP ),
      .S_AXI_RVALID ( S_AXI_RVALID ),
      .S_AXI_WREADY ( S_AXI_WREADY ),
      .S_AXI_BRESP ( S_AXI_BRESP ),
      .S_AXI_BVALID ( S_AXI_BVALID ),
      .S_AXI_AWREADY ( S_AXI_AWREADY ),
      .CAN_IRQ ( CAN_IRQ ),
      .CAN_BOFF ( CAN_BOFF ),
      .CAN_RX ( CAN_RX ),
      .CAN_TX ( CAN_TX ),
      .CAN_dbg_output ( CAN_dbg_output )
    );

endmodule

