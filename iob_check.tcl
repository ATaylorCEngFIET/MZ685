# iob_check.tcl - where did each I/O register land, and what did it buy?
# NOT YET RUN. Run on the routed design (build.tcl sources this file), or:
#   open_checkpoint iob_demo_routed.dcp ; source iob_check.tcl

set fh [open iob_placement.rpt w]
foreach grp {ra rb rc rd re_pad re_int ri} {
  foreach c [lsort -dictionary [get_cells -hier -filter "NAME =~ *${grp}_reg\[*\]"]] {
    set line [format "%-20s IOB=%-6s SITE=%-16s BEL=%s" $c \
                [get_property IOB $c] [get_property SITE $c] [get_property BEL $c]]
    puts $line
    puts $fh $line
  }
}
close $fh

# A register in the I/O logic reports an OLOGIC or ILOGIC BEL (OUTFF / IFF on
# 7 series). A fabric register reports a slice BEL such as SLICEL.AFF.

report_io        -file io.rpt
report_datasheet -file datasheet.rpt

# Clock-to-pad for bit 0 of each output bus, setup and hold for the input bus.
foreach p {pad_a pad_b pad_c pad_d pad_e} {
  report_timing -to [get_ports "${p}\[0\]"] -delay_type max -file ${p}0_max.rpt
}
report_timing -from [get_ports {din_pad[0]}] -delay_type min_max -file din_pad0.rpt

# Spread of clock-to-pad across each bus, which is what a scope shows as skew.
foreach p {pad_a pad_b pad_c pad_d pad_e} {
  set d {}
  foreach port [get_ports "${p}\[*\]"] {
    lappend d [get_property DATAPATH_DELAY [get_timing_paths -to $port -delay_type max]]
  }
  set d [lsort -real $d]
  puts [format "%-6s clock-to-pad datapath min %.3f ns  max %.3f ns  spread %.3f ns" \
          $p [lindex $d 0] [lindex $d end] [expr {[lindex $d end] - [lindex $d 0]}]]
}
