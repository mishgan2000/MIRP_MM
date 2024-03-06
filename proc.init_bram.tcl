cd C:/Work/XILINX/Projects/New_25/proc
if { [ catch { xload xmp proc.xmp } result ] } {
  exit 10
}

if { [catch {run init_bram} result] } {
  exit -1
}

exit 0
