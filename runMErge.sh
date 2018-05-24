#!/bin/bash

printERROR(){
	echo -e "\e[31mError\e[0m: Incorrect path"
	echo Usage Example:
	echo -e "\t\e[32m$0 <pulpino path>\e[0m"
}

PATHOK=0
if (( $# == 1  ))
then

	if [ -e $1 ]
	then
		if [ -e "$1/update-ips.py" ]
		then 
			echo OK!!!
			KLESS_PATH=$(pwd)
			cd $1
			PULP_PATH=$(pwd)
			cd $KLESS_PATH

			echo "Pulpino: $PULP_PATH"
			echo "Klessydra: $(pwd)"
			PATHOK=1
		else
			printERROR
		fi
	else
		printERROR
	fi
else
	printERROR
fi


if ((PATHOK==1))
then

	export KLESS_PATH
	export PULP_PATH
	

	# COPY VHDL FILES
	cp -r $KLESS_PATH/klessydra-t1-3th $PULP_PATH/ips

	# COPY CMAKE SHELL SCRIPTS
	cp $KLESS_PATH/patched_files/t13x_patched_files/cmake_configure.klessydra-t1-3th.gcc.sh $PULP_PATH/sw
	cp $KLESS_PATH/patched_files/common_patched_files/cmake_configure.microriscy.gcc.sh $PULP_PATH/sw
	cp $KLESS_PATH/patched_files/common_patched_files/cmake_configure.riscv.gcc.sh $PULP_PATH/sw
	cp $KLESS_PATH/patched_files/common_patched_files/cmake_configure.riscvfloat.gcc.sh $PULP_PATH/sw
	cp $KLESS_PATH/patched_files/common_patched_files/cmake_configure.zeroriscy.gcc.sh $PULP_PATH/sw

	# COPY CMAKE FILES
	cp -f $KLESS_PATH/patched_files/common_patched_files/CMakeLists.txt $PULP_PATH/sw
	cp -f $KLESS_PATH/patched_files/common_patched_files/CMakeSim.txt $PULP_PATH/sw/apps

	# COPY STARTUP FILES
	cp $KLESS_PATH/patched_files/common_patched_files/crt0.klessydra.S $PULP_PATH/sw/ref
	cp $KLESS_PATH/patched_files/common_patched_files/klessydra.h $PULP_PATH/sw/libs/sys_lib/inc

	# COPY COMPILE SCRIPTS
	cp $KLESS_PATH/patched_files/t13x_patched_files/vcompile_klessydra-t1-3th.csh $PULP_PATH/vsim/vcompile
	cp $KLESS_PATH/patched_files/common_patched_files/vcompile_ips.csh $PULP_PATH/vsim/vcompile
	cp $KLESS_PATH/patched_files/common_patched_files/vcompileIPS/vcompile_klessydra-t0-2th.csh $PULP_PATH/vsim/vcompile/ips
	cp $KLESS_PATH/patched_files/common_patched_files/vcompileIPS/vcompile_klessydra-t0-3th.csh $PULP_PATH/vsim/vcompile/ips
	cp $KLESS_PATH/patched_files/common_patched_files/vcompileIPS/vcompile_klessydra-t1-3th.csh $PULP_PATH/vsim/vcompile/ips

	# COPY PATCHED SIMULATION SCRIPTS
	cp $KLESS_PATH/patched_files/common_patched_files/vsim.tcl $PULP_PATH/vsim/tcl_files/config
	cp $KLESS_PATH/patched_files/common_patched_files/vsim_ips.tcl $PULP_PATH/vsim/tcl_files/config

	# COPY PATCHED SYSTEMVERILOG FILES
	cp $KLESS_PATH/patched_files/common_patched_files/tb.sv $PULP_PATH/tb
	cp $KLESS_PATH/patched_files/common_patched_files/pulpino_top.sv $PULP_PATH/rtl
	cp $KLESS_PATH/patched_files/common_patched_files/core_region.sv $PULP_PATH/rtl

fi

exit
