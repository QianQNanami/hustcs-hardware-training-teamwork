`timescale 1ns / 1ps


module SingleCycleCPU_tb();
    reg clk, UP;
    wire [31:0] LED;
    
    wire h_sync;
    wire v_sync;
    wire [11:0] vga;
    

    SingleCycleCPU cpu(
        .Go(1),
        .CLK(clk),
        .clk(clk),
        .LedData(LED),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .vga(vga),
        .UP(UP)
    );

    initial begin
        clk = 1'b1;
        UP = 1'b0;
        #100 UP = 1'b1;
        #101 UP = 1'b0;
    end

    always #5 clk = ~clk;
endmodule
