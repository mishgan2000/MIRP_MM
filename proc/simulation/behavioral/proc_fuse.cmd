@echo off
REM  Simulation Model Generator
REM  Xilinx EDK 14.7 EDK_P.20131013
REM  Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
REM
REM  File     proc_fuse.cmd (Wed Mar 20 11:22:09 2024)
REM
REM  ISE Simulator Fuse Script File
REM
REM  The Fuse script compiles and generates an ISE simulator
REM  executable named isim_proc.exe that is used to run your
REM  simulation. To run a simulation in command line mode,
REM  perform the following steps:
REM
REM  1. Run the ISE Simulator Fuse script file
REM     CMD /K proc_fuse.cmd
REM  2. Use a text editor to modify the signal wave files,
REM     which have the file name <module>_wave.tcl
REM  3. Launch the simulator using the following command:
REM     isim_proc.exe -gui -tclbatch proc_setup.tcl
REM
fuse -incremental work.proc_tb work.glbl  -prj proc.prj -L xilinxcorelib_ver -L secureip -L unisims_ver -L unimacro_ver  -o isim_proc.exe
