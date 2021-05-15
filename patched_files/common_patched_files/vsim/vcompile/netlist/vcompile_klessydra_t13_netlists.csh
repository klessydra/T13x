#!/bin/tcsh
source ${PULP_PATH}/vsim/vcompile/colors.csh

##############################################################################
# Settings
##############################################################################

set IP=kless_t13_netlist_functional
set IP_NAME="Klessydra_T13_Netlist_Functional"


##############################################################################
# Check settings
##############################################################################

# check if environment variables are defined
if (! $?MSIM_LIBS_PATH ) then
  echo "${Red} MSIM_LIBS_PATH is not defined ${NC}"
  exit 1
endif

set LIB_NAME="${IP}_lib"
set LIB_PATH="${MSIM_LIBS_PATH}/${LIB_NAME}"

##############################################################################
# Preparing library
##############################################################################

echo "${Green}--> Compiling ${IP_NAME}... ${NC}"

rm -rf $LIB_PATH

vlib $LIB_PATH
vmap $LIB_NAME $LIB_PATH
vmap /opt/Xilinx_Libs/simprims_ver
#vmap /opt/Xilinx_Libs/unisim_ver
#vmap unisim /home/aes/Desktop/antonio/unisim

echo "${Green}Compiling component: ${Brown} ${IP_NAME} ${NC}"
echo "${Red}"

##############################################################################
# Compiling RTL
##############################################################################

# decide if we want to build for riscv or or1k
if ( ! $?PULP_CORE) then
  set PULP_CORE="riscv"
endif

# decide if we want to build for riscv or or1k
if ( ! $?ASIC_DEFINES) then
  set ASIC_DEFINES=""
endif

# Source
vlog -quiet -work ${LIB_PATH} ${IPS_PATH}/klessydra_netlists/*.v   || goto error
#vcom -quiet -work ${LIB_PATH} "+incdir+/opt/Xilinx_Libs/unisim" ${IPS_PATH}/klessydra-t1-3th/SPM_SIMD1_Replicated_accl.vhd || goto error
#vcom -quiet -work ${LIB_PATH}  ${IPS_PATH}/klessydra-t1-3th/SPM_SIMD1_Replicated_accl.vhd || goto error


echo "${Cyan}--> ${IP_NAME} compilation complete! ${NC}"
exit 0

##############################################################################
# Error handler
##############################################################################

error:
echo "${NC}"
exit 1
