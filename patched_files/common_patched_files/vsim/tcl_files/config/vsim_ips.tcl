if {$env(USE_KLESSYDRA_T13X_NETLIST) == 1} {
    set VSIM_IP_LIBS " \
    -L axi_node_lib \
    -L apb_node_lib \
    -L axi_mem_if_DP_lib \
    -L axi_spi_slave_lib \
    -L axi_spi_master_lib \
    -L apb_uart_sv_lib \
    -L apb_gpio_lib \
    -L apb_event_unit_lib \
    -L apb_spi_master_lib \
    -L fpu_lib \
    -L apb_pulpino_lib \
    -L apb_fll_if_lib \
    -L core2axi_lib \
    -L apb_timer_lib \
    -L axi2apb_lib \
    -L apb_i2c_lib \
    -L kless_t13_netlist_functional_lib \
    -L zero_riscy_lib \
    -L axi_slice_dc_lib \
    -L riscv_lib \
    -L apb_uart_lib \
    -L axi_slice_lib \
    -L adv_dbg_if_lib \
    -L apb2per_lib \
    work.glbl \
    "
} else {
    set VSIM_IP_LIBS " \
    -L axi_node_lib \
    -L apb_node_lib \
    -L axi_mem_if_DP_lib \
    -L axi_spi_slave_lib \
    -L axi_spi_master_lib \
    -L apb_uart_sv_lib \
    -L apb_gpio_lib \
    -L apb_event_unit_lib \
    -L apb_spi_master_lib \
    -L fpu_lib \
    -L apb_pulpino_lib \
    -L apb_fll_if_lib \
    -L core2axi_lib \
    -L apb_timer_lib \
    -L axi2apb_lib \
    -L apb_i2c_lib \
    -L klessydra-t0-2th_lib \
    -L klessydra-t0-3th_lib \
    -L klessydra-t1-3th_lib \
    -L klessydra-t2-m_lib \
    -L klessydra-s1_lib \
    -L klessydra-OoO_lib \
    -L klessydra-f0-3th_lib \
    -L zero_riscy_lib \
    -L axi_slice_dc_lib \
    -L riscv_lib \
    -L apb_uart_lib \
    -L axi_slice_lib \
    -L adv_dbg_if_lib \
    -L apb2per_lib \
    work.glbl \
    "
}
