#configure wave -namecolwidth  250
#configure wave -valuecolwidth 100
#configure wave -justifyvalue left
#configure wave -signalnamewidth 1
#configure wave -timelineunits ns

#add wave sim:/tb/top_i/core_region_i/instr_mem/mem_gen_net/sp_ram_wrap_i/*
#add wave sim:/tb/top_i/core_region_i/mem_gen_net/data_mem/*
#add wave sim:/tb/top_i/core_region_i/CORE/RISCV_CORE/*

#Time needed to preload the netlist Data and Program Memories
run 100420 ns


power add -in -inout -internal -out -ports -r /tb/top_i/core_region_i/CORE/RISCV_CORE/*
#power add -in -inout -internal -out -ports -r /tb/top_i/core_region_i/mem_gen_net/data_mem/*
#power add -in -inout -internal -out -ports -r /tb/top_i/core_region_i/instr_mem/mem_gen_net/sp_ram_wrap_i/*

run -all

set saif_file $::env(NETLIST_FILE)

power report -all -bsaif ${saif_file}.saif
