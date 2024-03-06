
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name New_25 -dir "C:/Work/XILINX/Projects/New_25/planAhead_run_2" -part xc6slx25ftg256-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Work/XILINX/Projects/New_25/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Work/XILINX/Projects/New_25} {ipcore_dir} }
add_files [list {C:/Work/XILINX/Projects/New_25/proc.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_axi4lite_0_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_axi_ddr_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_axi_intc_0_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_clock_generator_0_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_mcb_ddr2_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_microblaze_0_dlmb_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_microblaze_0_ilmb_wrapper.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Work/XILINX/Projects/New_25/proc_microblaze_0_wrapper.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "top.ucf" [current_fileset -constrset]
add_files [list {top.ucf}] -fileset [get_property constrset [current_run]]
link_design
