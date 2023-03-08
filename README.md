<img src="/pics/Klessydra_Logo.png" width="400">

# KLESSYDRA-T1 INTRELEAVED MULTITHREADED PROCESSOR

Intro: The Klessydra processing core family is a set of processors featuring full compliance with RISC-V, and pin-to-pin compatible with the PULPino Riscy cores. Klessydra-T1 is a bare-metal 32-bit processor fully supporting the RV32IM from the RISC-V ISA, and one instruction from the Atomic "A" extension. 'T1' further extends the instruction set with a set of custom vector instructions.

Architecture: T1 as its T0 predecessor is also an interleaved multithreaded processor (Aka, barrel processor). It interleaves three hardware threads (harts). Each hart has it's own registerfile, CSR-unit, and program counter, and they communicate with each other via software interrupts.

Fencing role of the harts: The harts in the IMT archtiectures of Klessydra play an essential fencing role to avoid pipeline stalls. One role is to fence between registerfile read and write accesses, by interleaving threads to sit between the read and write stages thus never having data-dependency related pipeline stalls. The other is to fence between the execution stage where branch instructions and jumps are handled and the fetch stage, thus avoiding the need to perform any pipeline flushing. Once the number of harts becomes less then the required baseline required to create a fence, in that case the data dependency checker and the branch-predictor turn on in order to avoid data and control hazards.


PROCEDURE:

To use Klessydra-T13, please download [PULPino-Klessydra](https://github.com/klessydra/pulpino-klessydra) , and follow the guide over there. 

- For more details about the Klessydra processing cores, please refer to the technincal manual in Docs
- For more details about the Klessydra runtime libraries, please refer to the software runtime manual in Docs

Hope you like it :D
