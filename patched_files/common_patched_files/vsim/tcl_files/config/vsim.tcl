source tcl_files/config/vsim_ips.tcl

set cmd "vsim -quiet $TB \
   -vopt \
  -L pulpino_lib \
  -L simprims_ver \
  $VSIM_IP_LIBS \
  +nowarnTRAN \
  +nowarnTSCALE \
  +nowarnTFMPC \
  +MEMLOAD=$MEMLOAD \
  -gUSE_KLESSYDRA_T0_2TH=$env(USE_KLESSYDRA_T0_2TH) \
  -gUSE_KLESSYDRA_T0_3TH=$env(USE_KLESSYDRA_T0_3TH) \
  -gUSE_KLESSYDRA_T1_3TH=$env(USE_KLESSYDRA_T1_3TH) \
  -gUSE_KLESSYDRA_T2_M=$env(USE_KLESSYDRA_T2_M) \
  -gUSE_KLESSYDRA_S1=$env(USE_KLESSYDRA_S1) \
  -gUSE_KLESSYDRA_OoO=$env(USE_KLESSYDRA_OoO) \
  -gUSE_KLESSYDRA_F0_3TH=$env(USE_KLESSYDRA_F0_3TH) \
  -gUSE_KLESSYDRA_T13X_NETLIST=$env(USE_KLESSYDRA_T13X_NETLIST) \
  -gUSE_ZERO_RISCY=$env(USE_ZERO_RISCY) \
  -gRISCY_RV32F=$env(RISCY_RV32F) \
  -gKLESS_LUTRAM_RF=$env(KLESS_LUTRAM_RF) \
  -gZERO_RV32M=$env(ZERO_RV32M) \
  -gZERO_RV32E=$env(ZERO_RV32E) \
  -gKLESS_THREAD_POOL_SIZE=$env(KLESS_THREAD_POOL_SIZE) \
  -gKLESS_RV32E=$env(KLESS_RV32E) \
  -gKLESS_RV32M=$env(KLESS_RV32M) \
  -gKLESS_superscalar_exec_en=$env(KLESS_superscalar_exec_en) \
  -gKLESS_accl_en=$env(KLESS_accl_en) \
  -gKLESS_replicate_accl_en=$env(KLESS_replicate_accl_en) \
  -gKLESS_multithreaded_accl_en=$env(KLESS_multithreaded_accl_en) \
  -gKLESS_SPM_NUM=$env(KLESS_SPM_NUM) \
  -gKLESS_Addr_Width=$env(KLESS_Addr_Width) \
  -gKLESS_SIMD=$env(KLESS_SIMD) \
  -gKLESS_MCYCLE_EN=$env(KLESS_MCYCLE_EN) \
  -gKLESS_MINSTRET_EN=$env(KLESS_MINSTRET_EN) \
  -gKLESS_MHPMCOUNTER_EN=$env(KLESS_MHPMCOUNTER_EN) \
  -gKLESS_count_all=$env(KLESS_count_all) \
  -gKLESS_debug_en=$env(KLESS_debug_en) \
  -gKLESS_tracer_en=$env(KLESS_tracer_en) \
  -t ps \
  -voptargs=\"+acc -suppress 2103\" \
  $VSIM_FLAGS"

# set cmd "$cmd -sv_lib ./work/libri5cyv2sim"
eval $cmd

# check exit status in tb and quit the simulation accordingly
proc run_and_exit {} {
  run -all
  quit -code [examine -radix decimal sim:/tb/exit_status]
}
