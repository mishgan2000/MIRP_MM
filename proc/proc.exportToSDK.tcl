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

set sExportDir [ xget sdk_export_dir ]
set sExportDir [ file join "C:/Work/XILINX/Projects/New_25/proc" "$sExportDir" "hw" ] 
if { [ file exists C:/Work/XILINX/Projects/New_25/edkBmmFile_bd.bmm ] } {
   puts "Copying placed bmm file C:/Work/XILINX/Projects/New_25/edkBmmFile_bd.bmm to $sExportDir" 
   file copy -force "C:/Work/XILINX/Projects/New_25/edkBmmFile_bd.bmm" $sExportDir
}
if { [ file exists C:/Work/XILINX/Projects/New_25/top.bit ] } {
   puts "Copying bit file C:/Work/XILINX/Projects/New_25/top.bit to $sExportDir" 
   file copy -force "C:/Work/XILINX/Projects/New_25/top.bit" $sExportDir
}
exit $result
