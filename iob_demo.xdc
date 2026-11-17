# iob_demo.xdc - Arty A7-35T (xc7a35ticsg324-1L). NOT YET RUN IN VIVADO.
# Only the clock and the eight scope pins are located. The remaining ports are
# left for Vivado to place, which is fine for a routed checkpoint and timing
# reports. Locate every port before generating a bitstream.

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -name clk -period 10.000 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports -filter {NAME != clk}]

# Pmod JA, top row: packed bus pad_a[3:0]
set_property PACKAGE_PIN G13 [get_ports {pad_a[0]}]
set_property PACKAGE_PIN B11 [get_ports {pad_a[1]}]
set_property PACKAGE_PIN A11 [get_ports {pad_a[2]}]
set_property PACKAGE_PIN D12 [get_ports {pad_a[3]}]
# Pmod JA, bottom row: fabric registered bus pad_b[3:0]
set_property PACKAGE_PIN D13 [get_ports {pad_b[0]}]
set_property PACKAGE_PIN B18 [get_ports {pad_b[1]}]
set_property PACKAGE_PIN A18 [get_ports {pad_b[2]}]
set_property PACKAGE_PIN K16 [get_ports {pad_b[3]}]

# Zero I/O delays so that every pad path is timed and appears in report_timing.
set_input_delay  -clock clk 0.000 [get_ports {d_in[*] din_pad[*] oe_n}]
set_output_delay -clock clk 0.000 [get_ports {pad_*[*] parity_* din_q[*]}]

# The same packing request made from the constraint side instead of the RTL:
# set_property IOB TRUE [get_ports {pad_a[*] din_pad[*]}]
# set_property IOB TRUE [get_cells {ra_reg[*]}]
