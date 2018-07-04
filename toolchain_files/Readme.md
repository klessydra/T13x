Intro: 
Attached are the files used to build the riscv toolchain with the klessydra instruction extensions

1) Download the official riscv toolchain from: 

   https://github.com/riscv/riscv-gnu-toolchain

2) replace the patched file riscv-opc.c in <path_to_toolchain>/riscv-binutils-gdb/opcode/
   replace the patched file riscv-opc.h in <path_to_toolchain>/riscv-binutils-gdb/include/opcode/

3) Build the toolchain using the following commands
    
   ./configure --prefix=/opt/riscv --with-arch=rv32g --with-abi=ilp32
      make

4) After the build, in order to use both pulpino ri5cy toolchain and klessydra toolchain simultaneusly. Execute the "make_links.sh" which creates symbolic links of the official pointers.
   -	copy the "make_links.sh" into <path_to_klessydra_toolchain>/bin using "sudo cp"
   -	sudo chmod +x make_links.sh
   -	sudo ./make_links.sh

5) Add the path of <klessydra_toolchain>/bin to environmental variables.

Now if you want to test the toolchain, execute the commands as such in a terminal: klessydra-unknown-elf-... (e.g. klessydra-unknown-elf-gcc -c file.c -o file.o)
