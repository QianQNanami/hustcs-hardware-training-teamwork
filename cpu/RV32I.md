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


***

## Part II (zh)
- ADDI
  把符号位扩展的立即数加到寄存器 x[rs1]上，结果写入 x[rd]。忽略算术溢出。
- SLTI
  小于立即数则置位(Set if Less Than Immediate). I-type, RV32I and RV64I.
  比较 x[rs1]和有符号扩展的 immediate，如果 x[rs1]更小，向 x[rd]写入 1，否则写入 0。
- SLTIU 
  无符号小于立即数则置位(Set if Less Than Immediate, Unsigned). I-type, RV32I and RV64I.
  比较 x[rs1]和有符号扩展的 immediate，比较时视为无符号数。如果 x[rs1]更小，向 x[rd]写入1，否则写入 0。
- XORI
  立即数异或(Exclusive-OR Immediate). I-type, RV32I and RV64I.
  x[rs1]和有符号扩展的 immediate 按位异或，结果写入 x[rd]。
- ORI
  立即数取或(OR Immediate). R-type, RV32I and RV64I.
  把寄存器 x[rs1]和有符号扩展的立即数 immediate 按位取或，结果写入 x[rd]。
- ANDI
  与立即数 (And Immediate). I-type, RV32I and RV64I.
  把符号位扩展的立即数和寄存器 x[rs1]上的值进行位与，结果写入 x[rd]。
- SLLI
  立即数逻辑左移(Shift Left Logical Immediate). I-type, RV32I and RV64I.
  把寄存器x[rs1]左移shamt位，空出的位置填入0，结果写入x[rd]。对于RV32I，仅当shamt[5]=0时，指令才是有效的。
- SRLI
  立即数逻辑右移(Shift Right Logical Immediate). I-type, RV32I and RV64I.
  把寄存器x[rs1]右移shamt位，空出的位置填入0，结果写入x[rd]。对于RV32I，仅当shamt[5]=0时，指令才是有效的。
- SRAI
  立即数算术右移字(Shift Right Arithmetic Word Immediate). I-type, RV64I only.
  把寄存器 x[rs1]的低 32 位右移 shamt 位，空位用 x[rs1][31]填充，结果进行有符号扩展后写入 x[rd]。仅当 shamt[5]=0 时指令有效。
- ADD 
  加 (Add). RV32IC and RV64IC.
  扩展形式为 add rd, rd, rs2. rd=x0 或 rs2=x0 时非法。
- SUB
  减(Substract). R-type, RV32I and RV64I.
  x[rs1]减去 x[rs2]，结果写入 x[rd]。忽略算术溢出。
- SLL 
  逻辑左移(Shift Left Logical). R-type, RV32I and RV64I.
  把寄存器 x[rs1]左移 x[rs2]位，空出的位置填入 0，结果写入 x[rd]。x[rs2]的低 5 位（如果是RV64I 则是低 6 位）代表移动位数，其高位则被忽略。
- SLT
  小于则置位(Set if Less Than). R-type, RV32I and RV64I.
  比较 x[rs1]和 x[rs2]中的数，如果 x[rs1]更小，向 x[rd]写入 1，否则写入 0。
- SLTU
  无符号小于则置位(Set if Less Than, Unsigned). R-type, RV32I and RV64I.
  比较 x[rs1]和 x[rs2]，比较时视为无符号数。如果 x[rs1]更小，向 x[rd]写入 1，否则写入 0。
- XOR
  异或(Exclusive-OR). R-type, RV32I and RV64I.
  x[rs1]和 x[rs2]按位异或，结果写入 x[rd]。
- SRL
  逻辑右移(Shift Right Logical). R-type, RV32I and RV64I.
  把寄存器 x[rs1]右移 x[rs2]位，空出的位置填入 0，结果写入 x[rd]。x[rs2]的低 5 位（如果是RV64I 则是低 6 位）代表移动位数，其高位则被忽略。
- SRA
  算术右移(Shift Right Arithmetic). R-type, RV32I and RV64I.
  把寄存器 x[rs1]右移 x[rs2]位，空位用 x[rs1]的最高位填充，结果写入 x[rd]。x[rs2]的低 5 位（如果是 RV64I 则是低 6 位）为移动位数，高位则被忽略。
- OR
  取或(OR). R-type, RV32I and RV64I.
  把寄存器 x[rs1]和寄存器 x[rs2]按位取或，结果写入 x[rd]。
- AND
  与 (And). R-type, RV32I and RV64I.
  将寄存器 x[rs1]和寄存器 x[rs2]位与的结果写入 x[rd]。
## TODO:
- FENCE
  同步内存和 I/O(Fence Memory and I/O). I-type, RV32I and RV64I.
  在后续指令中的内存和 I/O 访问对外部（例如其他线程）可见之前，使这条指令之前的内存及 I/O 访问对外部可见。比特中的第 3,2,1 和 0 位分别对应于设备输入，设备输出，内存读写。例如 fence r,rw，将前面读取与后面的读取和写入排序，使用 pred = 0010 和 succ = 0011进行编码。如果省略了参数，则表示 fence iorw, iorw，即对所有访存请求进行排序。
- ECALL & EBREAK
  These two instructions cause a precise requested trap to the supporting execution environment.
  The ECALL instruction is used to make a service request to the execution environment. The EEI will define how parameters for the service request are passed, but usually these will be in defined locations in the integer register file.
