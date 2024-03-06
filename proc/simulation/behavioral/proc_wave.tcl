#  Simulation Model Generator
#  Xilinx EDK 14.7 EDK_P.20131013
#  Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
#
#  File     proc_wave.tcl (Fri Feb 02 16:02:53 2024)
#
#  ISE Simulator Trace Script File
#
#  Trace script files specify signals to save for later
#  display when viewing results of the simulation a graphic
#  format. Comment or uncomment commands to change the set of
#  signals viewed.
#
puts  "Setting up signal tracing ..."

if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists tbpath] } { set tbpath "${ps}proc_tb${ps}dut" }

#
#  Trace top-level ports
#
set id [group add "Top level ports"]
source top_level_ports_wave.tcl


#
#  Trace Bus signal ports
#
set id [group add "Bus signal ports" ]
source microblaze_0_ilmb_wave.tcl

source microblaze_0_dlmb_wave.tcl

source axi4lite_0_wave.tcl

source axi_ddr_wave.tcl

#
#  Trace Processor ports
#
set id [group add "Processor ports" ]
source microblaze_0_wave.tcl

#
#  Trace processor registers
#

set id [group add "Processor registers"]
#  Processor registers cannot be displayed for:
#  Module   proc_microblaze_0_wrapper
#  Instance microblaze_0
#
#  Trace IP and peripheral ports
#
set id [group add "IP and peripheral ports" ]
source proc_sys_reset_0_wave.tcl

source microblaze_0_i_bram_ctrl_wave.tcl

source microblaze_0_d_bram_ctrl_wave.tcl

source microblaze_0_bram_block_wave.tcl

source debug_module_wave.tcl

source clock_generator_0_wave.tcl

source axi_intc_0_wave.tcl

source axi_1ms_timer_wave.tcl

source MCB_DDR2_wave.tcl

source axi_timer_1_wave.tcl

source my_can_lite_0_wave.tcl

source axi_gpio_0_wave.tcl

source axi_pwm_0_wave.tcl

#
#  Trace setup complete. Start tracing the signals.
#

puts  "Signal tracing setup completed."

puts  "Simulate the design with the 'run' command."
