read_file -autoread -top top {../src ../include ../src}
current_design top
link
uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

source ../script/DC.sdc

compile
remove_unconnected_ports -blast_buses [get_cells * -hier]
write_file -format verilog -hier -output ../syn/top_syn.v
write_sdf -version 2.1 -context verilog -load_delay net ../syn/top_syn.sdf
uplevel #0 { report_timing -path full -delay min -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group }
uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group }
report_timing
exit
