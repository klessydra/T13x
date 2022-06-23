<img src="/pics/Klessydra_Logo.png" width="400">

# KLESSYDRA-T1 INTRELEAVED MULTITHREADED PROCESSOR

Intro: The Klessydra processing core family is a set of processors featuring full compliance with RISC-V, and pin-to-pin compatible with the PULPino Riscy cores. Klessydra-T1 is a bare-metal 32-bit processor fully supporting the RV32IM from the RISC-V ISA, and one instruction from the Atomic "A" extension. 'T1' further extends the instruction set with a set of custom vector instructions.

Architecture: T1 as its T0 predecessor is also an interleaved multithreaded processor (Aka, barrel processor). It interleaves three hardware threads (harts). Each hart has it's own registerfile, CSR-unit, and program counter, and they communicate with each other via software interrupts.

Fencing role of the harts: The harts in the IMT archtiectures of Klessydra play an essential fencing role to avoid pipeline stalls. One role is to fence between registerfile read and write accesses, by interleaving threads to sit between the read and write stages thus never having data-dependency related pipeline stalls. The other is to fence between the execution stage where branch instructions and jumps are handled and the fetch stage, thus avoiding the need to perform any pipeline flushing. Once the number of harts becomes less then the required baseline required to create a fence, in that case the data dependency checker and the branch-predictor turn on in order to avoid data and control hazards.

<p align="center">
<img src="/pics/Klessydra-T13x.png" width="600">
</p> 

The Coprocessor is a highly parametrizable accelerator, with up to 256-bit SIMD+MIMD execution capabilities. It comprises the Multipurpose Functional Unit, and the Scratchpad Memory Interface. The custom instruction set supported are listed in the Technincal manuals in the Docs folder. In addition to SIMD execution, the coprocessor supports subword-SIMD to further accelerate 8-bit and 16-bit integer data types.

The coprocessor features a parametrizable set of Scratchpad memories 'SPMs' (parametrizable being their size and number, and their bank numbers will automatically expand to match the SIMD configuration). 

The coprocessor can be configured to run in three different modes:


1) Shared Coprocessor: Where the VCU and SPMI are shared by all the harts (SIMD Coprocessor).
2) Fully Symmetrical Coprocessor: Where each hart has its dedicated VCU and SPMI. (MIMD Coprocessor ver.1).
3) Heterogeneous coprocessor: Where the harts share the functional units in the VCU, but each hart maintains it own dedicated SPMI (MIMD coprocessor ver.2).


Parameters:
- N = Number of SPMs in the SPMI.
- D = Number of Functional Units per VCU, and banks per SPM (i.e. determines the SIMD).
- F = Number of SIMD Functional Units (i.e. determines the MIMD), when 1, it means the harts share the SIMD functional units.
- M = Number of SPMIs, as well as VCU control logic for every hart, when 1, it means the harts share the same SPM space.


<p align="center">
<img src="/pics/Vector Coprocessor.png" width="500">
</p> 

# Using Klessydra-T1

This guide explains how one can download Pulpino-Klessydra that has all the Klessydra Cores integrated inside of it, and build PULP's version of the riscv-gnu-toolchain. It also demonstrates how to patch the offcial riscv-gnu-toolchain in order to add the Klessydra custom vector extensions.

###########################################################################################

    Prerequisites as indicated by the PULP group

        Mentor ModelSim

        CMake >= 2.8.0, versions greater than 3.1.0 recommended due to support for ninja

        riscv-toolchain, there are two choices for getting the toolchain:

            RECOMENDED OPTION: Use the custom version of the RISC-V toolchain from ETH. The ETH versions supports all the ISA extensions that were incorporated into the RI5CY core as well as the reduced base instruction set for zero-riscy. " https://github.com/pulp-platform/ri5cy_gnu_toolchain.git "

            Or download the official RISC-V toolchain supported by Berkeley. " https://github.com/riscv/riscv-gnu-toolchain "

        Please make sure you are using the newlib version of the toolchain.

        python2 >= 2.6

###########################################################################################

PROCEDURE:

1.	Install the following packeges:
		
		sudo apt-get install git cmake python-yaml tcsh autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

2.	Download and build the "ri5cy_gnu_toolchain"

		a) git clone https://github.com/pulp-platform/ri5cy_gnu_toolchain.git
		
		b) cd ri5cy_gnu_toolchain
		
		c) make ZERORISCY=1

		d) in case you need to build for RISCY cores, then just do "make" instead, and then add the symbolic links as shown from step 4.
		
	When the build is done, add the path **_<path_to_toolchain>/ri5cy_gnu_toolchain/install/bin_** to the environmental variables

3.	To run the klessydra tests, you have to download and patch the official riscv-gnu-toolchain, and then build it. Instructions for doing so are included in the README.md file inside the folder called "toolchain_files".

4.		Download PULPino-Klessydra:

		a) git clone https://github.com/klessydra/pulpino-klessydra
		
		b) cd pulpino-klessydra
		
		c) ./update-ips.py	

5.	OPTIONAL: After the update scipt is done, then you will be able to test Klessydra-T1. -Navigate to "sw" folder inside pulpino and execute the following commands

		a) e.g. mkdir build
		
		b) cp cmake_configure.klessydra-t1-3th.gcc.sh build/
		
		c) cd build
		
		d) ./cmake_configure.klessydra-t1-3th.gcc.sh
		   (Execute the above script twice if you ever change the variable that changes the riscv-compiler, since changing the compiler flushes the values of the variables in the cmake cache and gives an error. Executing the script for a second time after changing the riscv-compiler will let the variables be redfined again )
		   
		e) make vcompile

		For running Klessydra tests; the variable "USE_KLESSYDRA_TEST" in the above shell file is set to '1' by default. You only need to build and run your test
		f) To run an accelerated test (e.g.  make KDOTP_test.vsimc)

		g) To run a non-accelerated test (e.g.  make barrier_test.vsimc)
		
		h) You can also run one of the PULPino native tests,  (e.g. make testALU.vsimc)
			
	IT"S DONE!!!!!!

Supplimentary Information:

6.	In order to run tests under Modelsim gui mode, navigate again to the build folder and do the following: make nameofthetest.vsim (while .vsimc runs the test under Modelsim in background)

7. Klessydra-T1 libraries are available, and their functions are described in the software runtime manual fuond in the Docs folder

# Klessydra-T1 Parameters

The following illustrates briefly the parameters of the T1, and their usage settings.

- For more details about the Klessydra processing cores, please refer to the technincal manual in Docs
- For more details about the Klessydra runtime libraries, please refer to the software runtime manual in Docs

Extensions of T1 core:

The T1 can be configed in many ways in the from the "cmake_configure.klessydra-t1-3th.gcc.sh" found in the sw forlder:

You will find the following generics that will be passed to the RTL. **_Read the comments next to the variables before modifying_**:
1)	"THREAD_POOL_SIZE" sets the number of hardware threads. This should not be set less than 3, and the T1 perfroms best when it is equal to 3 and not greater.
2)	"LUTRAM_RF" this variable creates a LUTRAM based registerfile instead of a flip-flop based one, it is good for FPGA synthesis as LUTRAMs based regfiles are more efficient than FF based ones.
3)	"RV32E" this enables the embedded extension of the RISCV ISA, and makes the regfile to be half its original size (16 regs only).
4)	"RV32M" this enable the M-extension of the RISCV ISA. The mul instruction is a single cycle instructions, and the mulh/hu/hsu instructions need 3 cycles. divisions are slow, and can be up to 32 cycles, however fast single cycle divisions are availabe for special cases (div by 0, numerator < denominator, numerator is 0, and numerator equals the denominator).
5)	"superscalar_exec_en=1"  Enables superscalar execution when set to 1, else the stall of the pipeline will depend on tha latency of the instruction executing. This more than doubles the speed of the core in many applications, however if in the exceptional case the RTL is not simulating correctly, disable this and see whether the RTL will work again.
6)	"accl_en"  Enables the generation of the hardware accelerator of the T1.
7)	"replicate_accl_en" Once set, it replicates the accelerator for every thread, this increases the parallelism of the T1 by allocating a dedicated accelerator for each hart in the T1.
8)	"multithreaded_accl_en" Set this to 1 to let the replicated accelerator have shared functional units, but maintain dedicated SPM memories for each hardware thread (note: replicate_accl_en must be set to '1').
9)	"SPM_NUM" The number of scratchpads available "Minimum allowed is 2". When the acclerator is replicated, each hardware thread will have scratchpads equal to SPM_NUM, so in a THREAD_POOL_SIZE of 3 we will have 3*SPM_NUM scratchpads in totals
10)	Addr_Width" This address is for scratchpads. Setting this will make the size of the spm to be: "2^Addr_Width -1"
11)	"SIMD" Changing the SIMD, would increase the DLP by increasing the number of the functional units in the accelerator, and the number of banks in the spms acordingly (can be power of 2 only e.g. 1,2,4,8) no more than SIMD 8 is allowed. Setting this to '8' with replicate_accl_en and superscalar_exec_en being set to '1' as well will make the accelerator run at peak performance.
12)	"MCYCLE_EN" Can be set to 1 or 0 only. Setting to zero will disable MCYCLE and MCYCLEH
13)	"MINSTRET_EN" Can be set to 1 or 0 only. Setting to zero will disable MINSTRET and MINSTRETH
14)	"MHPMCOUNTER_EN" Can be set to 1 or 0 only. Setting to zero will disable all performance counters except "MCYCLE/H" and "MINSTRET/H"
15)	"count_all" Perfomance counters count for all the harts instead of there own hart
16)	"debug_en" Generates the debug unit, the debug unit is elimentary and might need some further evaluation and testing
17)	"tracer_en" Generates an instruction tracer, used for debugging


Hope you like it :D
