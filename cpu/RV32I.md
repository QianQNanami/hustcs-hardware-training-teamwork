The teamwork requires the CPU to support full RV32I IR Set. However, extending IR based on the FPGA CPU sourced from LOGISIM will pay a lot. The CPU is redesigned here.

## LUI

LUI (load upper immediate) is used to build 32-bit constants and uses the U-type format. LUI places the U-immediate value in the top 20 bits of the destination register rd, filling in the lowest 12 bits with zeros.

IR:

- Uimm: 20 [31:12]
- rd: 5 [11:7]
- opcode: 7 [6:0]

Uimm -> rd[31:12]

## AUIPC

AUIPC (add upper immediate to pc) is used to build pc-relative addresses and uses the U-type format. AUIPC forms a 32-bit offset from the 20-bit U-immediate, filling in the lowest 12 bits with zeros, adds this offset to the address of the AUIPC instruction, then places the result in register
rd.

IR:

- Uimm: 20 [31:12]
- rd: 5 [11:7]
- opcode: 7 [6:0]

## JAL

The jump and link (JAL) instruction uses the J-type format, where the J-immediate encodes a signed offset in multiples of 2 bytes. The offset is sign-extended and added to the address of the jump instruction to form the jump target address. Jumps can therefore target a ±1 MiB range. JAL stores the address of the instruction following the jump (pc+4) into register rd. The standard software calling convention uses x1 as the return address register and x5 as an alternate link register.

Plain unconditional jumps (assembler pseudoinstruction J) are encoded as a JAL with rd=x0.

IR:

- imm[20] 1 [31]
- imm[10:1] 10 [30:21]
- imm[11] 1 [20]
- imm[19:12] 8 [19:12]
- rd 5 [11:7]
- opcode 7 [6:0]

## JALR

The indirect jump instruction JALR (jump and link register) uses the I-type encoding. The target address is obtained by adding the sign-extended 12-bit I-immediate to the register rs1, then setting the least-significant bit of the result to zero. The address of the instruction following the jump (pc+4) is written to register rd. Register x0 can be used as the destination if the result is not required.

IR:

- imm[11:0] 12 [31:20]
- rs1 5 [19:15]
- func3=000 3 [14:12]
- rd 5 [11:7]
- opcode 7 [6:0]

## BEQ, BNE, BLT, BLTU, BGE, BGEU

All branch instructions use the B-type instruction format. The 12-bit B-immediate encodes signed offsets in multiples of 2 bytes. The offset is sign-extended and added to the address of the branch instruction to give the target address. The conditional branch range is ±4 KiB.

Branch instructions compare two registers. BEQ and BNE take the branch if registers rs1 and rs2 are equal or unequal respectively. BLT and BLTU take the branch if rs1 is less than rs2, using signed and unsigned comparison respectively. BGE and BGEU take the branch if rs1 is greater than or equal to rs2, using signed and unsigned comparison respectively. Note, BGT, BGTU, BLE, and BLEU can be synthesized by reversing the operands to BLT, BLTU, BGE, and BGEU, respectively.

Software should be optimized such that the sequential code path is the most common path, with less-frequently taken code paths placed out of line. Software should also assume that backward branches will be predicted taken and forward branches as not taken, at least the first time they are encountered. Dynamic predictors should quickly learn any predictable branch behavior. Unlike some other architectures, the RISC-V jump (JAL with rd=x0) instruction should always be used for unconditional branches instead of a conditional branch instruction with an alwaystrue condition. RISC-V jumps are also PC-relative and support a much wider offset range than branches, and will not pollute conditional-branch prediction tables.

The conditional branch instructions will generate an instruction-address-misaligned exception if the target address is not aligned to a four-byte boundary and the branch condition evaluates to true. If the branch condition evaluates to false, the instruction-address-misaligned exception will not be raised.

IR:

- imm[12] 1 [31]
- imm[10:5] 6 [30:25]
- rs2 5 [24:20]
- rs1 5 [19:15]
- funt3 3 [14:12]
- imm[4:1] 4 [11:8]
- imm[11] 1 [7]
- opcode [6:0]

## Load and Store

RV32I is a load-store architecture, where only load and store instructions access memory and arithmetic instructions only operate on CPU registers. RV32I provides a 32-bit address space that is byte-addressed. The EEI will define what portions of the address space are legal to access with which instructions (e.g., some addresses might be read only, or support word access only). Loads with a destination of x0 must still raise any exceptions and cause any other side effects even though the load value is discarded.

The EEI will define whether the memory system is little-endian or big-endian. In RISC-V, endianness is byte-address invariant.

IR of Load:

- imm[11:0] 12 [31:20]
- rs1 5 [19:15]
- funt3 3 [14:12]
- rd 5 [11:7]
- opcode 7 [6:0]

IR of Save:

- imm[11:5] 7 [31:25]
- rs2 5 [24:20]
- rs1 5 [19:15]
- funt3 3 [14:11]
- imm[4:0] 4 [10:7]
- opcode 7 [6:0]

Load and store instructions transfer a value between the registers and memory. Loads are encoded in the I-type format and stores are S-type. The effective address is obtained by adding register rs1 to the sign-extended 12-bit offset. Loads copy a value from memory to register rd. Stores copy the value in register rs2 to memory.

The LW instruction loads a 32-bit value from memory into rd. LH loads a 16-bit value from memory, then sign-extends to 32-bits before storing in rd. LHU loads a 16-bit value from memory but then zero extends to 32-bits before storing in rd. LB and LBU are defined analogously for 8-bit values. The SW, SH, and SB instructions store 32-bit, 16-bit, and 8-bit values from the low bits of register rs2 to memory.