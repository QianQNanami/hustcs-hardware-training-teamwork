`timescale 1ns / 1ps

module RAM (
    input wire [20:0] Addr,
    input wire [31:0] Din,
    input wire Clk,
    input wire str,
    output wire [31:0] Dout,

    input wire [11:0] vaddr_x,
    input wire [10:0] vaddr_y,
    output wire [11:0] vdata
);
    localparam SCALE_RATIO = 16; // TODO: change it!
    reg [31:0] mem [0:2**20-1];
    reg [11:0] vram [0:2**20-1];
    
//    integer i;
//    initial begin
//        for (i = 0; i < 2**20; i = i + 1) begin
//            mem[i] = 0;
//            vram[i] = 0;
//        end
//     mem[100] = 32'hf00;
//     mem[200] = 32'h0f0;
//     mem[300] = 32'h00f;
//     mem[400] = 32'hff0;
//     mem[500] = 32'hf0f;
//     mem[600] = 32'h0ff;
//     mem[700] = 32'hfff;
//    end

    always @(posedge Clk) begin
        if (str) begin
            if (Addr[20] == 1'b1)
                vram[Addr[19:0]] <= Din[11:0];
            else
                mem[Addr[19:0]] <= Din;
        end
    end
    
    assign Dout = mem[Addr];

    wire [19:0] vram_x;
    wire [19:0] vram_y;

    assign vram_x = vaddr_x / 16;  // TODO: change it!
    assign vram_y = vaddr_y / 16;  // TODO: change it!

    assign vdata = ((vaddr_x == 11'h7ff) | (vaddr_y == 10'h3ff)) ? 12'h000 :
                (mem[vram_y * 64 + vram_x] === 32'bx) ? 12'h000 :
                (mem[vram_y * 64 + vram_x][11:0]);

endmodule