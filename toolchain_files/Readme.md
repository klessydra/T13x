Intro: 
Attached are the files used to build the riscv toolchain with the klessydra instruction extensions

The folder "kless-tiny-toolchain-files" builds the riscv toolchain for embedded extensions "rv32i" (Applicable for T13x ONLY)
The folder "kless-toolchain-files" builds the iscv toolchain for the base integer instruction set "rv32i"
The folder "Riscy Toolchain" contains only symbolic links incase you need to build the ri5cy core toolchain which can be done in step 2 from the main page

For Klessydra T13 core, if you configure klessydra to run in rv32e, then you have to build the embedded toolchain. Else build the normal toolchain
Or build both if you would like to experiment with both extensions.

Procedure:

1) Download the official riscv toolchain from: 

	git clone https://github.com/riscv/riscv-gnu-toolchain
   
2) Switch to the commit which has the compatible version with our patched files

For Building the normal rv32i toolchain:

	- cd riscv-gnu-toolchain
	- git checkout v20180629	

For Building the embedded rv32e toolchain (T13x only):

	- cd riscv-gnu-toolchain
	- git checkout rve

3) Update the submodules inside the riscv-gnu-toolchain

	 git submodule update --init --recursive

4) 
For Building the normal rv32i toolchain: 

  - replace the patched file kless-toolchain-files/riscv-binutils/riscv-opc.c in <path_to_toolchain>/riscv-binutils/opcode/
  - replace the patched file kless-toolchain-files/riscv-binutils/riscv-opc.h in <path_to_toolchain>/riscv-binutils/include/opcode/
  - replace the patched file kless-toolchain-files/riscv-gdb/riscv-opc.c in <path_to_toolchain>/riscv-gdb/opcode/
  - replace the patched file kless-toolchain-files/riscv-gdb/riscv-opc.h in <path_to_toolchain>/riscv-gdb/include/opcode/

For Building the embedded rv32e toolchain (T13x only):

  - replace the patched file kless-tiny-toolchain-files/riscv-binutils/riscv-opc.c in <path_to_toolchain>/riscv-binutils/opcode/
  - replace the patched file kless-tiny-toolchain-files/riscv-binutils/riscv-opc.h in <path_to_toolchain>/riscv-binutils/include/opcode/
  - replace the patched file kless-tiny-toolchain-files/riscv-gdb/riscv-opc.c in <path_to_toolchain>/riscv-gdb/opcode/
  - replace the patched file kless-tiny-toolchain-files/riscv-gdb/riscv-opc.h in <path_to_toolchain>/riscv-gdb/include/opcode/

5) Build the toolchain using the following commands

For Building the normal rv32i toolchain:
  - ./configure --prefix=/opt/riscv-rv32i/ --with-arch=rv32ia --with-abi=ilp32
  -  make

For Building the embedded rv32e toolchain (T13x only): 
  - ./configure --prefix=/opt/riscv-rv32e/ --with-arch=rv32ea --with-abi=ilp32e
  -  make

6) After the build, in order to use both pulpino ri5cy toolchain and klessydra toolchain simultaneusly, execute the "make_links.sh" which creates symbolic links of the official pointers.
For rv32i builds use the make_links.sh in "kless-toolchain-files", for rv32e use the make_tiny_links.sh in "kless-tiny-toolchain-files"

   -	copy the "make_links.sh" into <path_to_klessydra_toolchain>/bin 
   -	chmod +x <make_links_file>
   -	./<make_links_file>

7) Add the path of <klessydra_toolchain>/bin to environmental variables.

Now if you want to test the toolchain, execute the commands as such in a terminal: klessydra-unknown-elf-... (e.g. klessydra-unknown-elf-gcc -c file.c -o file.o)
