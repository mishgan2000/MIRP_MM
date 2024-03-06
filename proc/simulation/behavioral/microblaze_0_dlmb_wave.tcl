#  Simulation Model Generator
#  Xilinx EDK 14.7 EDK_P.20131013
#  Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
#
#  File     microblaze_0_dlmb_wave.tcl (Fri Feb 02 16:02:53 2024)
#
#  Module   proc_microblaze_0_dlmb_wrapper
#  Instance microblaze_0_dlmb
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists tbpath] } { set tbpath "${ps}proc_tb${ps}dut" }

# wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_Clk -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}SYS_Rst -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_Rst -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}M_ABus -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}M_ReadStrobe -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}M_WriteStrobe -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}M_AddrStrobe -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}M_DBus -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}M_BE -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}Sl_DBus -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}Sl_Ready -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}Sl_Wait -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}Sl_UE -into $id
# wave add $tbpath${ps}microblaze_0_dlmb${ps}Sl_CE -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_ABus -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_ReadStrobe -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_WriteStrobe -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_AddrStrobe -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_ReadDBus -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_WriteDBus -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_Ready -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_Wait -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_UE -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_CE -into $id
  wave add $tbpath${ps}microblaze_0_dlmb${ps}LMB_BE -into $id

