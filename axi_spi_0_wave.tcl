#  Simulation Model Generator
#  Xilinx EDK 14.7 EDK_P.20131013
#  Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
#
#  File     axi_spi_0_wave.tcl (Tue Mar 19 11:30:30 2024)
#
#  Module   proc_axi_spi_0_wrapper
#  Instance axi_spi_0
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists tbpath] } { set tbpath "${ps}proc_tb${ps}dut" }

# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_ACLK -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_ARESETN -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_AWADDR -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_AWVALID -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_AWREADY -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_WDATA -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_WSTRB -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_WVALID -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_WREADY -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_BRESP -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_BVALID -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_BREADY -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_ARADDR -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_ARVALID -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_ARREADY -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_RDATA -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_RRESP -into $id
  wave add $tbpath${ps}axi_spi_0${ps}S_AXI_RVALID -into $id
# wave add $tbpath${ps}axi_spi_0${ps}S_AXI_RREADY -into $id
  wave add $tbpath${ps}axi_spi_0${ps}SCK_I -into $id
  wave add $tbpath${ps}axi_spi_0${ps}SCK_O -into $id
  wave add $tbpath${ps}axi_spi_0${ps}SCK_T -into $id
  wave add $tbpath${ps}axi_spi_0${ps}MISO_I -into $id
  wave add $tbpath${ps}axi_spi_0${ps}MISO_O -into $id
  wave add $tbpath${ps}axi_spi_0${ps}MISO_T -into $id
  wave add $tbpath${ps}axi_spi_0${ps}MOSI_I -into $id
  wave add $tbpath${ps}axi_spi_0${ps}MOSI_O -into $id
  wave add $tbpath${ps}axi_spi_0${ps}MOSI_T -into $id
  wave add $tbpath${ps}axi_spi_0${ps}SPISEL -into $id
  wave add $tbpath${ps}axi_spi_0${ps}SS_I -into $id
  wave add $tbpath${ps}axi_spi_0${ps}SS_O -into $id
  wave add $tbpath${ps}axi_spi_0${ps}SS_T -into $id
  wave add $tbpath${ps}axi_spi_0${ps}IP2INTC_Irpt -into $id

