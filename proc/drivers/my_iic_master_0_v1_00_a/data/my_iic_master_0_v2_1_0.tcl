##############################################################################
## Filename:          C:\Work\XILINX\Projects\New_25\proc/drivers/my_iic_master_0_v1_00_a/data/my_iic_master_0_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Fri Feb 16 14:52:54 2024 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "my_iic_master_0" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
