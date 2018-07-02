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
echo "${Green}--> Compiling klessydra-t0-3th core... ${NC}"

source ${PULP_PATH}/vsim/vcompile/ips/vcompile_klessydra-t0-3th.csh || exit 1

echo "${Green}--> klessydra-t0-3th core compilation Complete! ${NC}"
echo ""
