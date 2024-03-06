##############################################################################
## Filename:          C:\Work\XILINX\Projects\New_25\proc/drivers/mike_ip_v1_00_a/data/mike_ip_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Wed Jan 24 14:23:26 2024 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "mike_ip" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
