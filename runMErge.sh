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

	# COPY CMAKE/SHELL SCRIPTS
	cp -f $KLESS_PATH/patched_files/t13x_patched_files/cmake_configure.klessydra-t1-3th.gcc.sh $PULP_PATH/sw
	cp -f $KLESS_PATH/patched_files/common_patched_files/cmake_configure.microriscy.gcc.sh $PULP_PATH/sw
	cp -f $KLESS_PATH/patched_files/common_patched_files/cmake_configure.riscv.gcc.sh $PULP_PATH/sw
	cp -f $KLESS_PATH/patched_files/common_patched_files/cmake_configure.riscvfloat.gcc.sh $PULP_PATH/sw
	cp -f $KLESS_PATH/patched_files/common_patched_files/cmake_configure.zeroriscy.gcc.sh $PULP_PATH/sw

	# COPY CMAKE FILES
	cp -f $KLESS_PATH/patched_files/common_patched_files/CMakeLists.txt $PULP_PATH/sw
	cp -f $KLESS_PATH/patched_files/common_patched_files/apps/CMakeSim.txt $PULP_PATH/sw/apps
        cp -f $KLESS_PATH/patched_files/common_patched_files/apps/CMakeLists.txt $PULP_PATH/sw/apps

	# COPY STARTUP FILES
	cp -f $KLESS_PATH/patched_files/common_patched_files/ref/crt0.klessydra.S $PULP_PATH/sw/ref

	# COPY KLESSYDRA APPS 
	cp -r $KLESS_PATH/patched_files/common_patched_files/apps/klessydra_tests $PULP_PATH/sw/apps

        # COPY KLESSYDRA LIBRARIES AND HEADERS
        cp -r $KLESS_PATH/patched_files/common_patched_files/klessydra_lib $PULP_PATH/sw/libs/

	# COPY PATCHED LIBS
        cp -f $KLESS_PATH/patched_files/common_patched_files/sys_lib/inc/cpu_hal.h $PULP_PATH/sw/libs/sys_lib/inc
        cp -f $KLESS_PATH/patched_files/common_patched_files/sys_lib/inc/int.h $PULP_PATH/sw/libs/sys_lib/inc
        cp -f $KLESS_PATH/patched_files/common_patched_files/sys_lib/inc/utils.h $PULP_PATH/sw/libs/sys_lib/inc
	cp -f $KLESS_PATH/patched_files/common_patched_files/sys_lib/inc/klessydra.h $PULP_PATH/sw/libs/sys_lib/inc
        cp -f $KLESS_PATH/patched_files/common_patched_files/bench_lib/src/bench.c $PULP_PATH/sw/libs/bench_lib/src
        cp -f $KLESS_PATH/patched_files/common_patched_files/sys_lib/src/utils.c $PULP_PATH/sw/libs/sys_lib/src

	# COPY COMPILE SCRIPTS
	cp $KLESS_PATH/patched_files/t13x_patched_files/vcompile_klessydra-t1-3th.csh $PULP_PATH/vsim/vcompile
	cp $KLESS_PATH/patched_files/common_patched_files/vcompile_ips.csh $PULP_PATH/vsim/vcompile
	cp $KLESS_PATH/patched_files/common_patched_files/vcompileIPS/vcompile_klessydra-t0-2th.csh $PULP_PATH/vsim/vcompile/ips
	cp $KLESS_PATH/patched_files/common_patched_files/vcompileIPS/vcompile_klessydra-t0-3th.csh $PULP_PATH/vsim/vcompile/ips
	cp $KLESS_PATH/patched_files/common_patched_files/vcompileIPS/vcompile_klessydra-t1-3th.csh $PULP_PATH/vsim/vcompile/ips

	# COPY PATCHED SIMULATION SCRIPTS
	cp $KLESS_PATH/patched_files/common_patched_files/vsim.tcl $PULP_PATH/vsim/tcl_files/config
	cp $KLESS_PATH/patched_files/common_patched_files/vsim_ips.tcl $PULP_PATH/vsim/tcl_files/config


	# COPY KLessydra-t1 wave script
	cp $KLESS_PATH/patched_files/common_patched_files/klessydra_t13x_core.tcl $PULP_PATH/vsim/waves/klessydra_t13x_core.tcl
	
	# COPY PATCHED SYSTEMVERILOG FILES
	cp $KLESS_PATH/patched_files/common_patched_files/tb.sv $PULP_PATH/tb
	cp $KLESS_PATH/patched_files/common_patched_files/pulpino_top.sv $PULP_PATH/rtl
	cp $KLESS_PATH/patched_files/common_patched_files/core_region.sv $PULP_PATH/rtl

fi

exit
