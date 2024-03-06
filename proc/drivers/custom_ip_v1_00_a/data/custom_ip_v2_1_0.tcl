##############################################################################
## Filename:          C:\Work\XILINX\Projects\New_25\proc/drivers/custom_ip_v1_00_a/data/custom_ip_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Wed Jan 24 12:34:07 2024 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "custom_ip" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
