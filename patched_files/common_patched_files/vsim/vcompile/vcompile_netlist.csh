#!/bin/tcsh

if (! $?VSIM_PATH ) then
  setenv VSIM_PATH      `pwd`
endif

if (! $?PULP_PATH ) then
  setenv PULP_PATH      `pwd`/..
endif

setenv MSIM_LIBS_PATH ${VSIM_PATH}/modelsim_libs

setenv IPS_PATH ${PULP_PATH}/ips

source ${PULP_PATH}/vsim/vcompile/colors.csh

echo ""
echo "${Green}--> Compiling Vivado Netlist core... ${NC}"

source ${PULP_PATH}/vsim/vcompile/netlist/vcompile_klessydra_t13_netlists.csh || exit 1

echo "${Green}--> Vivado Netlist core compilation Complete! ${NC}"
echo ""
