# T13x Extensions illustration

Extensions made to this core:

-Four scratchpad memories of size 512-bytes, having dual data ports for read and write of bus width being 128-bit.The Scratchpads are nicknamed A,B,C,D and they are mapped at the following addresses respectively

  - 0x00109000 -> 0x001091FF (scA)
  - 0x00109200 -> 0x001093FF (scB)
  - 0x00109400 -> 0x001094FF (scC)
  - 0x00109600 -> 0x001096FF (scD)
  
-Three sperate execution Units that can work in parallel allowing superscalarity

  - DSP_Unit
  - IE_Unit
  - LSU_Unit
  
-DSP Unit does dot product and vector addition in SIMD fashion, but only works on 32-bit integers. 128-bits (4*32-bits).


For now, T1x extends the riscv instruction set with four new instructions:

1) Kmemld rd,rs1,rs2

-Loads the number of BYTES in "rs2" from the address in "rs1" in main memory to the internal scratchpad memory at address in "rd".
-Currently the number of bytes in rs2 have to be a multiple of four (i.e. 32-bits) or else we raise an exception.

2) kmemstr rd,rs1,rs2

-Loads the number of bytes in "rs2" from the address in "rs1" in the internal scratchpad memory at address to thee address in ram at "rd".
-Currently the number of bytes in rs2 have to be a multiple of four (i.e. 32-bits) or else we raise an exception.

 3) kaddv rd,rs1,rs2
 
 4) kdotp rd,rs1,rs2
 
- kaddv and kdotp do arithmetic operations on the vectors in "rs1" and "rs2", and store the results in "rd". Operations are done in SIMD fashion by which four elements are operated on simultanously.

- Currently the number of bytes in rs2 have to be a multiple of four (i.e. 32-bits) or else we raise an exception.

- If we have non scratchpad access, we raise an exception.

- If we have same scratchpad READ access we raise an exception.

- If writing to the scratchpads might overflow it, we raise an exception.

- However we don't raise an exception if a scratchpad is used simultanously for read and write, because as mentioned sc_memories were designed with dual ports for read and write.

Basic tests for vector addition and dot-product have been added, after you merge the Klessydra with PULPino, you will find the tests inside <pulp_path>/sw/apps/klessydra_dsp_tests/. 

Hope you like it :D

# Merging T13x User Guide

Intro: The Klessydra processing core family is a set of processors featuring full compliance with the RISC-V, and pin-to-pin compatible with the PULPino riscy cores. Klessydra cores fully support the RV32I Base Integer Instruction set, and one instruction from the RV32A extension. 'T1' further extends the instruction set with four instructions as described above. The only privilege level supported in klessydra is Machine mode "M".

This guide explains how one can download and install Pulpino, and it's 
modified version of the riscv-gnu toolchain. It also demonstrates
how to patch the offcial riscv-toolchain in order to add the klessydra 
extensions. And then it shows how you can easily merge the Klessydra-Core 
in the Pulpino project.

###########################################################################################
- Prerequisites as indicated by the pulpino group
	- ModelSim in reasonably recent version (we tested it with versions 10.2c)
	- CMake >= 2.8.0, versions greater than 3.1.0 recommended due to support for ninja
	- riscv-toolchain, there are two choices for getting the toolchain: 

  		1) RECOMENDED OPTION: Use the custom version of the RISC-V toolchain from ETH. 
  		The ETH versions supports all the ISA extensions that were incorporated 
	  	into the RI5CY core as well as the reduced base instruction set for zero-riscy.
	        " https://github.com/pulp-platform/ri5cy_gnu_toolchain.git "

		2) Or download the official RISC-V toolchain supported by Berkeley.
 	       	" https://github.com/riscv/riscv-gnu-toolchain "


	  	Please make sure you are using the newlib version of the toolchain.
	- python2 >= 2.6
	
###########################################################################################

- IF you already have pulpino and their own version of the riscv-toolchain, then skip ahead to step.4


PROCEDURE:
1.	Install the following packeges:
		
		sudo apt-get install git cmake python-yaml tcsh autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

2.	Download and build the "ri5cy-toolchain"

		a) git clone https://github.com/pulp-platform/ri5cy-gnu-toolchain.git
		
		b) cd ri5cy-gnu-toolchain
		
		c) make ZERORISCY=1
		
	When the build is done, add the path **_<path_to_toolchain>/ri5cy_gnu_toolchain/install/bin_** to the environmental variables

3.	Download the PULPino suite:

		a) git clone https://github.com/pulp-platform/pulpino.git
		
		b) cd pulpino
		
		c) ./update-ips.py	


4.	If you want to run the klessydra specific tests, you have to download and patch the official riscv-toolchain, and then build it. Instructions for doing so are included in the README.md file
	inside the folder called toolchain_files.

5.	To merge the Klessydra core, and tests:

		a) git clone https://github.com/klessydra/T13x.git
		
		b) cd T13x
		
		c) ./runMErge.sh <pulpino_path>

6.	OPTIONAL: After merging is done, this is how you will be able to test Klessydra-t1-3th.
		-Open a terminal and navigate to "sw" folder inside pulpino and execute the following commands

		a) e.g. mkdir build
		
		b) cp cmake_configure.klessydra-t1-3th.gcc.sh build/
		
		c) cd build
		
		d) ./cmake_configure.klessydra-t1-3th.gcc.sh
		
		e) make vcompile

		For running Klessydra tests; the variable "USE_KLESSYDRA_TEST" in the shell file is set to '1' by default. You only need to build and run your test
		f) (e.g. make barrier_test.vsimc)
		
		For running a PULPino test, set the variable "USE_KLESSYDRA_TEST" inside the shell file to 0, and re-execute the shell file again, and then run
		g) (e.g. make testALU.vsimc)
			
	IT"S DONE!!!!!!

EXTRA:

7.	In order to run tests in Modelsim, go to the build folder and do the following:
		make nameofthetest.vsim (or .vsimc to run a test without modelsim GUI)
