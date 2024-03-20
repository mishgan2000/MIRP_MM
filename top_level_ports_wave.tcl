#  Simulation Model Generator
#  Xilinx EDK 14.7 EDK_P.20131013
#  Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
#
#  File     top_level_ports_wave.tcl (Wed Mar 20 11:22:09 2024)
#
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists tbpath] } { set tbpath "${ps}proc_tb${ps}dut" }

wave add $tbpath${ps}RESET -into $id 
wave add $tbpath${ps}CLK_PRC -into $id 
wave add $tbpath${ps}MCB_DDR2_uo_done_cal_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_addr_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_ba_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_ras_n_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_cas_n_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_we_n_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_cke_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_clk_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_clk_n_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_dq -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_dqs -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_dqs_n -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_udqs -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_udqs_n -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_udm_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_ldm_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_mcbx_dram_odt_pin -into $id 
wave add $tbpath${ps}MCB_DDR2_rzq -into $id 
wave add $tbpath${ps}MCB_DDR2_zio -into $id 
wave add $tbpath${ps}CAN_dbg_out -into $id 
wave add $tbpath${ps}CAN_TX -into $id 
wave add $tbpath${ps}CAN_RX -into $id 
wave add $tbpath${ps}CAN_BOFF -into $id 
wave add $tbpath${ps}GPIO -into $id 
wave add $tbpath${ps}axi_uart16550_0_Sin_pin -into $id 
wave add $tbpath${ps}axi_uart16550_0_Sout_pin -into $id 
wave add $tbpath${ps}axi_spi_0_SPISEL_pin -into $id 
wave add $tbpath${ps}axi_spi_0_SCK_pin -into $id 
wave add $tbpath${ps}axi_spi_0_MISO_pin -into $id 
wave add $tbpath${ps}axi_spi_0_MOSI_pin -into $id 
wave add $tbpath${ps}axi_spi_0_SS_pin -into $id 
wave add $tbpath${ps}to_fpga -into $id 
wave add $tbpath${ps}from_fpga -into $id 
wave add $tbpath${ps}axi_iic_0_Gpo_pin -into $id 
wave add $tbpath${ps}axi_iic_0_Sda_pin -into $id 
wave add $tbpath${ps}axi_iic_0_Scl_pin -into $id 

