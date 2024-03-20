#  Simulation Model Generator
#  Xilinx EDK 14.7 EDK_P.20131013
#  Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
#
#  File     my_can_lite_0_wave.tcl (Wed Mar 20 11:22:09 2024)
#
#  Module   proc_my_can_lite_0_wrapper
#  Instance my_can_lite_0
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists tbpath] } { set tbpath "${ps}proc_tb${ps}dut" }

# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_ACLK -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_ARESETN -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_AWADDR -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_AWVALID -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_WDATA -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_WSTRB -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_WVALID -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_BREADY -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_ARADDR -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_ARVALID -into $id
# wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_RREADY -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_ARREADY -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_RDATA -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_RRESP -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_RVALID -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_WREADY -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_BRESP -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_BVALID -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}S_AXI_AWREADY -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}CAN_IRQ -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}CAN_BOFF -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}CAN_RX -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}CAN_TX -into $id
  wave add $tbpath${ps}my_can_lite_0${ps}CAN_dbg_output -into $id

