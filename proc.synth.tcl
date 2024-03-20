proc pnsynth {} {
  cd C:/Work/XILINX/Projects/TEST_MIRP/proc
  if { [ catch { xload xmp proc.xmp } result ] } {
    exit 10
  }
  if { [catch {run netlist} result] } {
    return -1
  }
  return $result
}
if { [catch {pnsynth} result] } {
  exit -1
}
exit $result
