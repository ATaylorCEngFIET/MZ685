# build.tcl - non-project build of iob_demo. NOT YET RUN.
#   vivado -mode batch -source build.tcl
set part xc7a35ticsg324-1L
read_vhdl -vhdl2008 iob_demo.vhd
read_xdc iob_demo.xdc
synth_design -top iob_demo -part $part
opt_design
place_design
route_design
write_checkpoint -force iob_demo_routed.dcp
source iob_check.tcl
