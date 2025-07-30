# Dr. Kaputa
# Quartus II compile script for DE1-SoC board

# 1] name your project here
set project_name "Lab_7_TLDE"

file delete -force ../project
file delete -force ../output_files
file mkdir ../project
cd ../project
load_package flow
project_new $project_name
set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6 
set_global_assignment -name TOP_LEVEL_ENTITY tlde
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY ../output_files

# 2] include your relative path files here
set_global_assignment -name VHDL_FILE ../src/synchronizers/rising_edge_synchronizer.vhd
set_global_assignment -name VHDL_FILE ../src/synchronizers/clock_synchronizer.vhd
set_global_assignment -name VHDL_FILE ../src/synchronizers/package_def.vhd
set_global_assignment -name VHDL_FILE ../src/alu.vhd
set_global_assignment -name VHDL_FILE ../src/memory.vhd
set_global_assignment -name VHDL_FILE ../src/fsm.vhd
set_global_assignment -name VHDL_FILE ../src/ssd_d3.vhd
set_global_assignment -name VHDL_FILE ../src/tlde.vhd

set_location_assignment PIN_AF14 -to clk

set_location_assignment PIN_AA14 -to reset
set_location_assignment PIN_AA15 -to mr
set_location_assignment PIN_W15  -to ms
set_location_assignment PIN_Y16  -to exec
 
set_location_assignment PIN_AB12 -to number[0]
set_location_assignment PIN_AC12 -to number[1]
set_location_assignment PIN_AF9  -to number[2]
set_location_assignment PIN_AF10 -to number[3]
set_location_assignment PIN_AD11 -to number[4]
set_location_assignment PIN_AD12 -to number[5]
set_location_assignment PIN_AE11 -to number[6]
set_location_assignment PIN_AC9  -to number[7]

set_location_assignment PIN_AD10 -to op[0]
set_location_assignment PIN_AE12 -to op[1]

set_location_assignment PIN_AE26 -to hex0[0]
set_location_assignment PIN_AE27 -to hex0[1]
set_location_assignment PIN_AE28 -to hex0[2]
set_location_assignment PIN_AG27 -to hex0[3]
set_location_assignment PIN_AF28 -to hex0[4]
set_location_assignment PIN_AG28 -to hex0[5]
set_location_assignment PIN_AH28 -to hex0[6]

set_location_assignment PIN_AJ29 -to hex1[0]
set_location_assignment PIN_AH29 -to hex1[1]
set_location_assignment PIN_AH30 -to hex1[2]
set_location_assignment PIN_AG30 -to hex1[3]
set_location_assignment PIN_AF29 -to hex1[4]
set_location_assignment PIN_AF30 -to hex1[5]
set_location_assignment PIN_AD27 -to hex1[6]

set_location_assignment PIN_AB23 -to hex2[0]
set_location_assignment PIN_AE29 -to hex2[1]
set_location_assignment PIN_AD29 -to hex2[2]
set_location_assignment PIN_AC28 -to hex2[3]
set_location_assignment PIN_AD30 -to hex2[4]
set_location_assignment PIN_AC29 -to hex2[5]
set_location_assignment PIN_AC30 -to hex2[6]

set_location_assignment PIN_V16  -to state[0]
set_location_assignment PIN_W16  -to state[1]
set_location_assignment PIN_V17  -to state[2]

execute_flow -compile
project_close