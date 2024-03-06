proc pngeninsttemplate {} {
  cd C:/Work/XILINX/Projects/New_25/proc
  if { [ catch { xload xmp proc.xmp } result ] } {
    exit 10
  }
  if { [catch {run mhs2hdl} result] } {
    return -1
  }
  return 0
}
if { [catch {pngeninsttemplate} result] } {
  exit -1
}
exit $result
