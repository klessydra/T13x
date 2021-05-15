#!/usr/bin/tcsh

echo ""
echo "${Green}--> Compiling PULP IPs libraries... ${NC}"
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_axi_node.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_node.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_axi_mem_if_DP.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_axi_spi_slave.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_axi_spi_master.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_uart_sv.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_gpio.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_event_unit.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_spi_master.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_fpu.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_pulpino.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_fll_if.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_core2axi.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_timer.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_axi2apb.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_i2c.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_klessydra-t0-2th.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_klessydra-t0-3th.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_klessydra-t1-3th.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_klessydra-m.csh      || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_klessydra-s1.csh     || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_klessydra-OoO.csh    || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_klessydra-f0-3th.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/netlist/vcompile_glbl_netlists.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/netlist/vcompile_klessydra_t13_netlists.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_zero-riscy.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_axi_slice_dc.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_riscv.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb_uart.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_axi_slice.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_adv_dbg_if.csh || exit 1
tcsh ${PULP_PATH}/./vsim/vcompile/ips/vcompile_apb2per.csh || exit 1
