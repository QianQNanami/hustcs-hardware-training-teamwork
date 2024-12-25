`timescale 1ns / 1ps

module SingleCycleCPU (
    input Go,
    input CLK,
    input clk,
    input UP, DOWN, CENTER, LEFT, RIGHT, // interrupt

    output [31:0] LedData,
    output [31:0] oPC,
    output [31:0] oIR,
    output [31:0] MDin,
    output [31:0] RDin,
    output [15:0] LED,
    output MemWrite,
    output RegWrite,

    output h_sync,v_sync,
    output [11:0] vga
);

    
    assign oIR = 0;
    assign MDin = 0;
    assign RDin = 0;
    assign MemWrite = 0;
    assign RegWrite = 0;
    // VGA
    wire [11:0] vaddr_x;
    wire [10:0] vaddr_y;
    wire [11:0] vdata;
    wire clk_vga;

    // interrupt 
    reg [31:0] next_PC;
    wire [31:0] EPC_out, EPCAddr_in, InterrAddr;
    wire InterrEN, Interr;
    wire uret1, uret2, uret3, uret4, uret5, Interrupt1, Interrupt2, Interrupt3, Interrupt4, Interrupt5;
    
    reg [31:0] PC;
    assign oPC = PC;
    wire [31:0] IR;
    reg uret;

    InstructionROM ROM_instruction(
        .Addr(PC[21:2]),
        .Data(IR)
    );

    initial begin
        PC = 32'h0;
        uret = 0;
    end

    wire [31:0] rsval, rtval;
    reg [4:0] rs, rt;
    reg [31:0] Regin, rd;
    reg [31:0] ADDImm, SLTImm, XORImm, ORImm, ANDImm;
    reg [4:0] SLLIshamt, SRLshamt, SRAshamt;
    reg RegWE;
    RegFile regfile(
        .Din(Regin),
        .Clk(CLK),
        .WE(RegWE),
        .WAddr(rd),
        .R1Addr(rs),
        .R2Addr(rt),
        .R1(rsval),
        .R2(rtval)
    );
    
    reg MemWE;
    reg [31:0] MemAddr, Memin;
    wire [31:0] Memout;
    RAM ram(
        .Addr(MemAddr[22:2]),
        .Din(Memin),
        .Dout(Memout),
        .Clk(CLK),
        .str(MemWE),
        .vaddr_x(vaddr_x),
        .vaddr_y(vaddr_y),
        .vdata(vdata)
    );
    
    reg [4:0] op_code;
    reg [2:0] funt3;
    reg [31:0] Uimm, Jimm, Simm, Bimm, Iimm, LEDDATA;
    always @(posedge CLK) begin
        RegWE = 0; MemWE = 0;    
        op_code = IR[29:25];
        funt3 = IR[14:12];
        if(op_code == 5'b01101) begin // LUI
            Uimm = {IR[31:12], 12'b0};
            Regin = Uimm;
            rd = IR[11:7];
            RegWE = 1;
            next_PC = PC + 4;
        end
        if(op_code == 5'b00101) begin // AUIPC
            Uimm = {IR[31:12], 12'b0};
            Regin = Uimm + PC;
            rd = IR[11:7];
            RegWE = 1;
            next_PC = PC + 4;
        end
        if(op_code == 5'b11011) begin // JAL
            Jimm = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};
            Regin = PC + 4;
            rd = IR[11:7];
            RegWE = 1;
            next_PC = PC + Jimm;
        end
        if(op_code == 5'b11001 && funt3 == 3'b000) begin // JALR
            Iimm = {{20{IR[31]}}, IR[31:20]};
            Regin = PC + 4;
            rd = IR[11:7];
            rs = IR[19:15];
            RegWE = 1;
            next_PC = rsval + Iimm;
        end
        if(op_code == 5'b11000 && funt3 == 3'b000) begin // BEQ
            Bimm = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            if(rsval == rtval) begin
                next_PC = PC + Bimm;
            end else begin
                next_PC = PC + 4;
            end
        end
        if(op_code == 5'b11000 && funt3 == 3'b001) begin // BNE
            Bimm = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            if(rsval != rtval) begin
                next_PC = PC + Bimm;
            end else begin
                next_PC = PC + 4;
            end  
        end
        if(op_code == 5'b11000 && funt3 == 3'b100) begin // BLT
            Bimm = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            if($signed(rsval) < $signed(rtval)) begin
                next_PC = PC + Bimm;
            end else begin
                next_PC = PC + 4;
            end
        end
        if(op_code == 5'b11000 && funt3 == 3'b110) begin // BLTU
            Bimm = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            if($unsigned(rsval) < $unsigned(rtval)) begin
                next_PC = PC + Bimm;
            end else begin
                next_PC = PC + 4;
            end
        end
        if(op_code == 5'b11000 && funt3 == 3'b101) begin // BGE
            Bimm = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            if($signed(rsval) >= $signed(rtval)) begin
                next_PC = PC + Bimm;
            end else begin
                next_PC = PC + 4;
            end
        end
        if(op_code == 5'b11000 && funt3 == 3'b111) begin // BGEU
            Bimm = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            if($unsigned(rsval) >= $unsigned(rtval)) begin
                next_PC = PC + Bimm;
            end else begin
                next_PC = PC + 4;
            end
        end
        if(op_code == 5'b00000 && funt3 == 3'b000) begin // LB
            Iimm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            MemAddr = rsval + Iimm;
            case(MemAddr[1:0])
                2'b00: begin
                    Regin[7:0] = Memout[7:0];
                    Regin[31:8] = {24{Memout[7]}};
                end
                2'b01: begin
                    Regin[7:0] = Memout[15:8];
                    Regin[31:8] = {24{Memout[15]}};
                end
                2'b10: begin
                    Regin[7:0] = Memout[23:16];
                    Regin[31:8] = {24{Memout[23]}};
                end
                2'b11: begin
                    Regin[7:0] = Memout[31:24];
                    Regin[31:8] = {24{Memout[31]}};
                end
            endcase
            RegWE = 1;
            next_PC = PC + 4;
        end
        if(op_code == 5'b00000 && funt3 == 3'b001) begin // LH
            Iimm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            MemAddr = rsval + Iimm;
            case(MemAddr[1:0]) 
                2'b00, 2'b01: begin
                    Regin[15:0] = Memout[15:0];
                    Regin[31:16] = {16{Memout[15]}};
                end
                2'b10, 2'b11: begin
                    Regin[15:0] = Memout[31:16];
                    Regin[31:16] = {16{Memout[31]}};
                end
            endcase
            RegWE = 1;
            next_PC = PC + 4;
        end
        if(op_code == 5'b00000 && funt3 == 3'b010) begin // LW
            Iimm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            MemAddr = rsval + Iimm;
            Regin = Memout;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if(op_code == 5'b00000 && funt3 == 3'b100) begin // LBU
            Iimm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            MemAddr = rsval + Iimm;
            case(MemAddr[1:0])
                2'b00: begin
                    Regin[7:0] = Memout[7:0];
                    Regin[31:8] = 24'b0;
                end
                2'b01: begin
                    Regin[7:0] = Memout[15:8];
                    Regin[31:8] = 24'b0;                
                end
                2'b10: begin
                    Regin[7:0] = Memout[23:16];
                    Regin[31:8] = 24'b0;
                end
                2'b11: begin
                    Regin[7:0] = Memout[31:24];
                    Regin[31:8] = 24'b0;
                end
            endcase
            RegWE = 1;
            next_PC = PC + 4;
        end
        if(op_code == 5'b00000 && funt3 == 3'b101) begin // LHU
            Iimm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            MemAddr = rsval + Iimm;
            case(MemAddr[1:0])
                2'b00, 2'b01: begin
                    Regin[15:0] = Memout[15:0];
                    Regin[31:16] = 16'b0;
                end
                2'b10, 2'b11: begin
                    Regin[15:0] = Memout[31:16];
                    Regin[31:16] = 16'b0;
                end
            endcase
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01000 && funt3 == 3'b000) begin // SB
            Simm = {{20{IR[31]}}, IR[31:25], IR[11:7]};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            MemAddr = rsval + Simm;
            Memin = Memout;
            case(MemAddr[1:0])
                2'b00: Memin[7:0] = rtval[7:0];
                2'b01: Memin[15:8] = rtval[7:0];
                2'b10: Memin[23:16] = rtval[7:0];
                2'b11: Memin[31:24] = rtval[7:0];
            endcase
            MemWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01000 && funt3 == 3'b001) begin // SH
            Simm = {{20{IR[31]}}, IR[31:25], IR[11:7]};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            MemAddr = rsval + Simm;
            Memin = Memout;
            case(MemAddr[1:0])
                2'b00: Memin[15:0] = rtval[15:0];
                2'b01: Memin[15:0] = rtval[15:0];
                2'b10: Memin[31:16] = rtval[15:0];
                2'b11: Memin[31:16] = rtval[15:0];
            endcase
            MemWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01000 && funt3 == 3'b010) begin // SW
            Simm = {{20{IR[31]}}, IR[31:25], IR[11:7]};
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            MemAddr = rsval + Simm;
            Memin = rtval;
            MemWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b00100 && funt3 == 3'b000) begin // ADDI
            ADDImm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            Regin = rsval + ADDImm;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b00100 && funt3 == 3'b010) begin // SLTI
            SLTImm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            if($signed(rsval) < SLTImm) begin // 灏� rsval 瑙嗕负鏈夌鍙锋暟
                Regin = 32'h1;
            end else begin
                Regin = 32'h0;
            end
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b00100 && funt3 == 3'b011) begin // SLTIU
            SLTImm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            if($unsigned(rsval) < SLTImm) begin // 灏� rsval 瑙嗕负鏃犵鍙锋暟
                Regin = 32'h1;
            end else begin
                Regin = 32'h0;
            end
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b00100 && funt3 == 3'b100) begin // XORI
            XORImm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            Regin = rsval ^ XORImm;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b00100 && funt3 == 3'b110) begin // ORI
            ORImm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            Regin = rsval | ORImm;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b00100 && funt3 == 3'b111) begin // ANDI
            ANDImm = {{20{IR[31]}}, IR[31:20]};
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            Regin = rsval & ANDImm;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b001) begin // SLLI
            SLLIshamt = IR[24:20];
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            Regin = rsval << SLLIshamt;
            if (SLLIshamt[4] == 0) begin
                RegWE = 1;
            end
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b101 && IR[30] == 0) begin // SRLI
            SRLshamt = IR[24:20];
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            Regin = rsval >> SRLshamt;
            if (SRLshamt[4] == 0) begin
                RegWE = 1;
            end 
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b101 && IR[30] == 1) begin // SRAI
            SRAshamt = IR[24:20];
            rs = IR[19:15]; // rs1
            rd = IR[11:7]; // rd
            Regin = $signed(rsval) >>> SRAshamt;
            if (SRAshamt[4] == 0) begin
                RegWE = 1;
            end
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b000 && IR[30] == 0) begin // ADD
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = rsval + rtval;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b000 && IR[30] == 1) begin // SUB
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = rsval - rtval;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b001) begin // SLL
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = rsval << rtval[4:0];
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b010) begin // SLT
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            if($signed(rsval) < $signed(rtval)) begin
                Regin = 32'h1;
            end else begin
                Regin = 32'h0;
            end
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b011) begin // SLTU
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            if($unsigned(rsval) < $unsigned(rtval)) begin
                Regin = 32'h1;
            end else begin
                Regin = 32'h0;
            end
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b100) begin // XOR
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = rsval ^ rtval;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b101 && IR[30] == 0) begin // SRL
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = rsval >> rtval[4:0];
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b101 && IR[30] == 1) begin // SRA
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = $signed(rsval) >>> rtval[4:0];
            RegWE = 1;
            next_PC = PC + 4;
        end        
        if (op_code == 5'b01100 && funt3 == 3'b110) begin // OR
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = rsval | rtval;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if (op_code == 5'b01100 && funt3 == 3'b111) begin // AND
            rs = IR[19:15]; // rs1
            rt = IR[24:20]; // rs2
            rd = IR[11:7]; // rd
            Regin = rsval & rtval;
            RegWE = 1;
            next_PC = PC + 4;
        end
        if(op_code == 5'b11100 && IR[31:7] == 25'b0000000000000000000000000) begin // ECALL
            rs = 5'h11;
            rt = 5'h0a;
            if(rsval == 32'h22) begin
                LEDDATA = rtval;
            end
            next_PC = PC + 4;
        end
        PC = next_PC;
    end
    assign LED = LEDDATA;
    // interrupt
    MUX2x1 #(32) interrAddr(.Dout(EPCAddr_in), .A(next_PC), .B(InterrAddr), .Sel(InterrEN)); // 2-way mul for interrupt
    MUX2x1 #(32) EPCAddr(.Dout(PCADDR), .A(EPCAddr_in), .B(EPC_out), .Sel(uret));            // 2-way mul for epc interrupt

    Interrupter Interrupter1(.CLK(CLK), .IR(UP),        .uret(uret1), .interrupt(Interrupt1), .LED(LED[0]));
    Interrupter Interrupter2(.CLK(CLK), .IR(LEFT),      .uret(uret2), .interrupt(Interrupt2), .LED(LED[1]));
    Interrupter Interrupter3(.CLK(CLK), .IR(CENTER),    .uret(uret3), .interrupt(Interrupt3), .LED(LED[2]));
    Interrupter Interrupter4(.CLK(CLK), .IR(RIGHT),     .uret(uret4), .interrupt(Interrupt4), .LED(LED[3]));
    Interrupter Interrupter5(.CLK(CLK), .IR(DOWN),      .uret(uret5), .interrupt(Interrupt5), .LED(LED[4]));
    
    EPC epc(.EN(InterrEN), .Din(next_PC), .Dout(EPC_out));
    
    Scheduler scheduler(.IRR1(Interrupt1), .IRR2(Interrupt2), .IRR3(Interrupt3), .IRR4(Interrupt4), .IRR5(Interrupt5),
                        .uret1(uret1), .uret2(uret2), .uret3(uret3), .uret4(uret4), .uret5(uret5),
                        .interr(Interr), .uret(uret), .interrEN(InterrEN), .CLK(CLK), .interrAddr(InterrAddr));
    
    InterrEn interren(.uret(uret), .CLK(CLK), .interr(Interr), .interrEN(InterrEN));


    // VGA
    clk_wiz_0 clk_wiz (.clk_in1(clk),.clk_out1(clk_vga));   // in: 100MHz, out: 65MHz
    vga vga_display(
        .clk(clk_vga),
        .vdata(vdata),
        .vaddr_x(vaddr_x),
        .vaddr_y(vaddr_y),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .vga(vga)
    );
endmodule