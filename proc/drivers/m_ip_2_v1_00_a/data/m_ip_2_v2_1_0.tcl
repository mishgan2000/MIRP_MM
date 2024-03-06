##############################################################################
## Filename:          C:\Work\XILINX\Projects\New_25\proc/drivers/m_ip_2_v1_00_a/data/m_ip_2_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Thu Jan 25 15:00:41 2024 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "m_ip_2" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
