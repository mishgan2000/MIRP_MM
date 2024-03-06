proc exportToSDK {} {
  cd C:/Work/XILINX/Projects/New_25/proc
  if { [ catch { xload xmp proc.xmp } result ] } {
    exit 10
  }
  if { [run exporttosdk] != 0 } {
    return -1
  }
  return 0
}

if { [catch {exportToSDK} result] } {
  exit -1
}

exit $result
