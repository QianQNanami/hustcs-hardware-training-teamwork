`timescale 1ns / 1ps

module InstructionROM (
    input wire [19:0] Addr,
    output wire [31:0] Data
);
    reg [31:0] mem [0:2**20-1];
    initial begin
        // C:/Data/project/hustcs-hardware-training-teamwork/src/vga_test/final.hex
        // C:/Data/project/HUST_RISC-V_CPU/FPGA/bin/risc-v-benchmark_ccab.hex
        $readmemh("C:/Data/project/hustcs-hardware-training-teamwork/src/vga_test/final.hex", mem, 0, 2**20-1);
    end
    assign Data = mem[Addr];
endmodule