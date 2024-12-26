`timescale 1ns / 1ps

module InstructionROM (
    input wire [19:0] Addr,
    output wire [31:0] Data
);
    reg [31:0] mem [0:2**20-1];
    initial begin
        $readmemh("C:/Data/hustcs-hardware-training-teamwork/example/vga_asm_test/test_2.hex", mem, 0, 2**20-1);
    end
    assign Data = mem[Addr];
endmodule