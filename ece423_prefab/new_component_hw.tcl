# TCL File Generated by Component Editor 15.1
# Tue Mar 05 20:01:39 EST 2019
# DO NOT MODIFY


# 
# idct_2d "idct_2d" v1.0
# Paul George 2019.03.05.20:01:39
# for ece423 lab 2
# 

# 
# request TCL package from ACDS 15.1
# 
package require -exact qsys 15.1


# 
# module idct_2d
# 
set_module_property DESCRIPTION "for ece423 lab 2"
set_module_property NAME idct_2d
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Paul George"
set_module_property DISPLAY_NAME idct_2d
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL IDCT_2D_hw
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file idct_1d.vhd VHDL PATH idct_1d.vhd
add_fileset_file idct_2d.vhd VHDL PATH idct_2d.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point src
# 
add_interface src avalon_streaming end
set_interface_property src associatedClock clock
set_interface_property src associatedReset reset
set_interface_property src dataBitsPerSymbol 8
set_interface_property src errorDescriptor ""
set_interface_property src firstSymbolInHighOrderBits true
set_interface_property src maxChannel 0
set_interface_property src readyLatency 0
set_interface_property src ENABLED true
set_interface_property src EXPORT_OF ""
set_interface_property src PORT_NAME_MAP ""
set_interface_property src CMSIS_SVD_VARIABLES ""
set_interface_property src SVD_ADDRESS_GROUP ""

add_interface_port src src_data data Input 1024
add_interface_port src src_valid valid Input 1
add_interface_port src src_ready ready Output 1


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point dst
# 
add_interface dst avalon_streaming start
set_interface_property dst associatedClock clock
set_interface_property dst associatedReset reset
set_interface_property dst dataBitsPerSymbol 8
set_interface_property dst errorDescriptor ""
set_interface_property dst firstSymbolInHighOrderBits true
set_interface_property dst maxChannel 0
set_interface_property dst readyLatency 0
set_interface_property dst ENABLED true
set_interface_property dst EXPORT_OF ""
set_interface_property dst PORT_NAME_MAP ""
set_interface_property dst CMSIS_SVD_VARIABLES ""
set_interface_property dst SVD_ADDRESS_GROUP ""

add_interface_port dst dst_data data Output 512
add_interface_port dst dst_ready ready Input 1
add_interface_port dst dst_valid valid Output 1
