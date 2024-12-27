`timescale 1ns / 1ps

module InstructionROM (
    input wire [9:0] Addr,
    output wire [31:0] Data
);
    reg [31:0] mem [0:2**10-1];
    initial begin
        $readmemh("C:/Data/hustcs-hardware-training-teamwork/maze.hex", mem, 0, 2**10-1);
    end
    assign Data = mem[Addr];
endmodule