project new D:/_OLD_D/_work/PLT_A2/PLD/plt_a2/mb_system/pcores/my_can_lite_v1_00_a/devl/projnav/my_can_lite.xise;
project set family spartan6;
project set device xc6slx25;
project set package ftg256;
project set speed -2;
project set top_level_module_type HDL;
project set synthesis_tool "XST (VHDL/Verilog)";
lib_vhdl new my_can_lite_v1_00_a;
xfile add D:/_OLD_D/_work/PLT_A2/PLD/plt_a2/mb_system/pcores/my_can_lite_v1_00_a/hdl/vhdl/my_can_lite.vhd;
xfile add D:/_OLD_D/_work/PLT_A2/PLD/plt_a2/mb_system/pcores/my_can_lite_v1_00_a/hdl/verilog/user_logic.v;
lib_vhdl new proc_common_v3_00_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/hdl/vhdl/proc_common_pkg.vhd -lib_vhdl proc_common_v3_00_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/hdl/vhdl/ipif_pkg.vhd -lib_vhdl proc_common_v3_00_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/hdl/vhdl/or_muxcy.vhd -lib_vhdl proc_common_v3_00_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/hdl/vhdl/or_gate128.vhd -lib_vhdl proc_common_v3_00_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/hdl/vhdl/family_support.vhd -lib_vhdl proc_common_v3_00_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/hdl/vhdl/pselect_f.vhd -lib_vhdl proc_common_v3_00_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/hdl/vhdl/counter_f.vhd -lib_vhdl proc_common_v3_00_a;
lib_vhdl new axi_lite_ipif_v1_01_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/axi_lite_ipif_v1_01_a/hdl/vhdl/address_decoder.vhd -lib_vhdl axi_lite_ipif_v1_01_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/axi_lite_ipif_v1_01_a/hdl/vhdl/slave_attachment.vhd -lib_vhdl axi_lite_ipif_v1_01_a;
xfile add D:/Xilinx/14.7/ISE_DS/EDK/hw/XilinxProcessorIPLib/pcores/axi_lite_ipif_v1_01_a/hdl/vhdl/axi_lite_ipif.vhd -lib_vhdl axi_lite_ipif_v1_01_a;
project close;