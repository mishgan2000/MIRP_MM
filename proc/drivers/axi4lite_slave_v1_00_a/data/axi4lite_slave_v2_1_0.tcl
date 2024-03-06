##############################################################################
## Filename:          C:\Work\XILINX\Projects\New_25\proc/drivers/axi4lite_slave_v1_00_a/data/axi4lite_slave_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Wed Jan 17 15:45:32 2024 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "axi4lite_slave" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
