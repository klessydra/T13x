#!/bin/bash

#export PATH=/compilerpath/:${PATH}

# Set this to one if you want to run klessydra tests
USE_KLESSYDRA_TEST=0

# Set this to one if you are using a klessydra core
USE_KLESSYDRA=0

# if you are using klessydra-t0-2th (The three pipeline version of klessydra t0), set this to 1
USE_KLESSYDRA_T0_2TH=0

# if you are using klessydra-t0-3th (The four pipeline version of klessydra t0), set this to 1
USE_KLESSYDRA_T0_3TH=0

# if you are using klessydra-t1-3th (The four pipeline version of klessydra t1), set this to 1
USE_KLESSYDRA_T1_3TH=0

# if you are using klessydra-f0-3th (The four pipeline version of klessydra f0), set this to 1
USE_KLESSYDRA_F0_3TH=0


if [ $USE_KLESSYDRA_TEST -eq 0 ]
then
	OBJDUMP=`which riscv32-unknown-elf-objdump`
	OBJCOPY=`which riscv32-unknown-elf-objcopy`
	COMPILER=`which riscv32-unknown-elf-gcc`
	RANLIB=`which riscv32-unknown-elf-ranlib`
	TARGET_C_FLAGS="-O3 -m32 -g"
	#TARGET_C_FLAGS="-O2 -g -falign-functions=16  -funroll-all-loops"
	# riscy with PULPextensions, it is assumed you use the ETH GCC Compiler
	GCC_MARCH="IMXpulpv2"
else
	OBJDUMP=`which klessydra-unknown-elf-objdump`
	OBJCOPY=`which klessydra-unknown-elf-objcopy`
	COMPILER=`which klessydra-unknown-elf-gcc`
	RANLIB=`which klessydra-unknown-elf-ranlib`
	TARGET_C_FLAGS="-O3 -g"
	GCC_MARCH="rv32ia"
fi

KLESS_VSIZE=$VSIZE
KLESS_TIME=$TIME

VSIM=`which vsim`

# if you want to have compressed instructions, set this to 1
RVC=0

# if you are using zero-riscy, set this to 1
USE_ZERO_RISCY=0

# set this to 1 if you are using the Floating Point extensions for riscy only
RISCY_RV32F=0

# zeroriscy with the multiplier
ZERO_RV32M=0
# zeroriscy with only 16 registers
ZERO_RV32E=0

#compile arduino lib
ARDUINO_LIB=1

PULP_GIT_DIRECTORY=../../
SIM_DIRECTORY="$PULP_GIT_DIRECTORY/vsim"
#insert here your post-layout netlist if you are using IMPERIO
PL_NETLIST=""

cmake "$PULP_GIT_DIRECTORY"/sw/ \
	-DNUMOFELEMENTS="$KLESS_VSIZE" \
	-DTIME="$KLESS_TIME" \
    -DPULP_MODELSIM_DIRECTORY="$SIM_DIRECTORY" \
    -DCMAKE_C_COMPILER="$COMPILER" \
    -DVSIM="$VSIM" \
    -DRVC="$RVC" \
    -DRISCY_RV32F="$RISCY_RV32F" \
    -DUSE_KLESSYDRA="$USE_KLESSYDRA" \
    -DUSE_KLESSYDRA_TEST="$USE_KLESSYDRA_TEST" \
    -DUSE_KLESSYDRA_T0_2TH="$USE_KLESSYDRA_T0_2TH" \
    -DUSE_KLESSYDRA_T0_3TH="$USE_KLESSYDRA_T0_3TH" \
    -DUSE_KLESSYDRA_T1_3TH="$USE_KLESSYDRA_T1_3TH" \
    -DUSE_KLESSYDRA_F0_3TH="$USE_KLESSYDRA_F0_3TH" \
    -DUSE_ZERO_RISCY="$USE_ZERO_RISCY" \
    -DZERO_RV32M="$ZERO_RV32M" \
    -DZERO_RV32E="$ZERO_RV32E" \
    -DGCC_MARCH="$GCC_MARCH" \
    -DARDUINO_LIB="$ARDUINO_LIB" \
    -DPL_NETLIST="$PL_NETLIST" \
    -DCMAKE_C_FLAGS="$TARGET_C_FLAGS" \
    -DCMAKE_OBJCOPY="$OBJCOPY" \
    -DCMAKE_OBJDUMP="$OBJDUMP"

# Add -G "Ninja" to the cmake call above to use ninja instead of make
