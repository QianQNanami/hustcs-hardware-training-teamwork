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
    localparam SCALE_RATIO = 32; // TODO: change it!
    reg [31:0] mem [0:2**20-1];
    reg [11:0] vram [0:2**20-1];
    
//    integer i;
   initial begin
    //    for (i = 0; i < 2**20; i = i + 1) begin
    //        mem[i] = 0;
    //        vram[i] = 0;
    //    end
    // vram[100] = 12'hf00;
    // vram[200] = 12'h0f0;
    // vram[300] = 12'h00f;
    // vram[400] = 12'hff0;
    // vram[500] = 12'hf0f;
    // vram[600] = 12'h0ff;
    // vram[700] = 12'hfff;
   end

    always @(posedge Clk) begin
        if (str) begin
            if (Addr[20] == 1'b1)
                vram[Addr[19:0]] <= Din[11:0];
            else
                mem[Addr[19:0]] <= Din;
        end
    end
    
    assign Dout = mem[Addr];
    assign vdata = ((vaddr_x == 11'h7ff) | (vaddr_y == 10'h3ff)) ? 12'h000 :
                (vram[vaddr_y / SCALE_RATIO * (1024 / SCALE_RATIO) + vaddr_x / SCALE_RATIO] === 12'bx) ? 12'h000 :
                (vram[vaddr_y / SCALE_RATIO * (1024 / SCALE_RATIO) + vaddr_x / SCALE_RATIO]);

endmodule