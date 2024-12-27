`timescale 1ns / 1ps


module SingleCycleCPU_tb();
    reg clk, UP, LEFT, RIGHT, DOWN;
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
        .UP(UP),
        .LEFT(LEFT),
        .RIGHT(RIGHT),
        .DOWN(DOWN)
    );

    initial begin
        clk = 1'b1;
        UP = 1'b0;
        LEFT = 1'b0;
        RIGHT = 1'b0;
        DOWN = 1'b0;
        #200 LEFT = 1'b1;
        #100 LEFT = 1'b0;
        #100 LEFT = 1'b1;
        #100 LEFT = 1'b0;
        #100 UP = 1'b1;
        #100 UP = 1'b0;
        #100 UP = 1'b1;
        #100 UP = 1'b0;
    end

    always #5 clk = ~clk;
endmodule
