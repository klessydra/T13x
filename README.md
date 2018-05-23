# BETA VERSION!!!
Hello this is An early release of the latest cores of the klessydra family the T1x version.
I am certain that you might encounter bugs during execution. Nevertheless updates will be followed shortly
Extensions made to this version:
-Four scratchpad memories of size 512-bytes, having dual read and write data ports of 128-bit bus width.The Scratchpads are nicknamed A,B,C,D and they are mapped for the following addresses respectively
  - 0x00109000 -> 0x001091FF (scA)
  - 0x00109200 -> 0x001093FF (scB)
  - 0x00109400 -> 0x001094FF (scC)
  - 0x00109600 -> 0x001096FF (scD)
-Three sperate execution Units that can work in parallel allowing superscalarability
  - DSP_Unit
  - IE_Unit
  - LSU_Unit
-DSP Unit does dot product and vector addition in SIMD fashion having a read and write bus width of 128-bits (4*32-bits).


For now, this version extends the riscv instruction set with four new instructions:

1) Kmemld rd,rs1,rs2

-Loads the number of BYTES in "rs2" from the address in "rs1" in main memory to the internal scratchpad memory at address in "rd".
-Currently the number of bytes in rs2 have to be a multiple of four (i.e. 32-bits) or else we raise an exception.
2) kmemstr rd,rs1,rs2

-Loads the number of bytes in "rs2" from the address in "rs1" in the internal scratchpad memory at address to thee address in ram at "rd".
-Currently the number of bytes in rs2 have to be a multiple of four (i.e. 32-bits) or else we raise an exception.

 3) kaddv rd,rs1,rs2
 4) kdotp rd,rs1,rs2
 
-They do the arithmetic operations on the vectors in "rs1" and "rs2", and store the results in "rd". Operation are done in SIMD fashion were we can operate on four elements simultanously.
-Currently the number of bytes in rs2 have to be a multiple of four (i.e. 32-bits) or else we raise an exception.
-If we have non scratchpad access, we raise an exception.
-If we have same Scratchpad READ access we raise an exception.
-If writing to the scratchpads might overflow it, we raise an exception.
-However we don't raise an exception if a scratchpad is used simultanouly for read and write, because sc_memories were designed with dual ports for read and write.

Currently there are no tests added for testing the new instructions, they will be included shortly in recent update. 

Hope you like it :D

# Merging T13x User Guide

Intro: The Klessydra processing core family is is a set of processors featuring full compliance with the RISC-V. Klessydra cores fully support the RV32I Base Integer Instruction set in M-mode and one instruction from the RV32A extension.

This guide explains how one can download and install Pulpino, and 
it's modified version of the riscv-gnu toolchain. And then it shows how 
you can easily merge the Klessydra-Core in the Pulpino project.

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

- IF you already have pulpino and their toolchain, than skip ahead to step.4


PROCEDURE:
1.	Install the following packeges:

		sudo apt-get install git cmake tcsh python-yaml autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

2.	Download the toolchain, execute the following commands in the folder where you want to download the pulpino version of the riscv-gnu toolchain

		a) git clone https://github.com/pulp-platform/ri5cy-gnu-toolchain.git
		
		b) cd ri5cy-gnu-toolchain
		
		c) make ZERORISCY=1
		
	at the end of compilation, add the path **_<path_to_toolchain>/ri5cy_gnu_toolchain/install/bin_** to the environmental variables

3.	Download PULPino suite:

		a) git clone https://github.com/pulp-platform/pulpino.git
		
		b) cd pulpino
		
		c) ./update-ips.py	
	
4.	To merge the Klessydra core:

		a) git clone https://github.com/klessydra/T13x.git
		
		b) cd T13x
		
		c) ./runMErge.sh <pulpino_path>

5.	OPTIONAL: After merging is done, this is how you will be able to test Klessydra-t1-3th.
		-Open the terminal and navigate to "sw" folder inside pulpino and execute the following commands

		a) e.g. mkdir build
		
		b) cp cmake_configure.klessydra-t1-3th.gcc.sh build/
		
		c) cd build
		
		d) ./cmake_configure.klessydra-t1-3th.gcc.sh
		
		e) make vcompile
		
		EXAMPLE TEST:
		f) make testALU.vsimc
			
	IT"S DONE!!!!!!

	Extra options: You can modify the cmake-configure file:
	for example, if you want to run zero-riscy without multiplication extensions change the variable "ZERO_RV32M" from '1' to '0' inside cmake_configure.zeroriscy.gcc.sh .
	save file and run

6.	In order to run tests in Modelsim, go to the build folder and do the following:
		make nameofthetest.vsim (or .vsimc to run a test without modelsim GUI)

7.	The list of the tests that passed on Klessydra are available in the file SIMUL_TEST_REULTS.pdf
