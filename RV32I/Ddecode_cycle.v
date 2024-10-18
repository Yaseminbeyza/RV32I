`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 18:00:02
// Design Name: 
// Module Name: Ddecode_cycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Ddecode_Cycle(
    input clk, rst, StallD, RegWriteW,   // Clock, reset, stall sinyalleri ve write-back aþamasýndaki yazma izni
    input [4:0] RDW,             // Write-back aþamasýndaki hedef register
    input [31:0] InstrD, PCD, PCPlus4D, ResultW, // Instruction, PC ve write-back verileri

    output reg RegWriteE, ALUSrcE, MemWriteE, MemReadE, ResultSrcE, BranchE, JumpE,  // Çýkýþ kontrol sinyalleri
    output reg [3:0] ALUControlE,  // ALU kontrol sinyali
    output reg [31:0] RD1_E, RD2_E, Imm_Ext_E,  // Kaynak register verileri ve Immediate geniþletilmiþ
    output reg [4:0] RS1_E, RS2_E, RD_E,  // Register numaralarý
    output reg [2:0] funct3_E,     // funct3 sinyali
    output reg [31:0] PCE, PCPlus4E       // Program Counter ve PC+4
);

    // Geçici sinyaller
    wire RegWriteD, ALUSrcD, MemWriteD, MemReadD, ResultSrcD, BranchD, JumpD;
    wire [2:0] ImmSrcD, funct3D;
    wire [3:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;

    // Pipeline register sinyalleri
    reg RegWriteD_r, ALUSrcD_r, MemWriteD_r, MemReadD_r, ResultSrcD_r, BranchD_r, JumpD_r;
    reg [3:0] ALUControlD_r;
    reg [31:0] RD1_D_r, RD2_D_r, Imm_Ext_D_r;
    reg [4:0] RD_D_r, RS1_D_r, RS2_D_r;
    reg [2:0] funct3D_r;
    reg [31:0] PCD_r, PCPlus4D_r;

    // Control Unit modülü (RV32I'yi destekleyecek þekilde)
    Control_Unit control (
        .opcode(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[31:25]),
        .RegWrite(RegWriteD),
        .ALUSrc(ALUSrcD),
        .MemWrite(MemWriteD),
        .MemRead(MemReadD),
        .ResultSrc(ResultSrcD),
        .Branch(BranchD),
        .Jump(JumpD),
        .ALUControl(ALUControlD),
        .ImmSrc(ImmSrcD)
    );

    // Register File
    Register_file rf (
        .clk(clk),
        .rst(rst),
        .WE3(RegWriteW),
        .WD3(ResultW),
        .A1(InstrD[19:15]),    // rs1
        .A2(InstrD[24:20]),    // rs2
        .A3(RDW),              // write-back aþamasýndaki rd
        .RD1(RD1_D),           // rs1'den okunan veri
        .RD2(RD2_D)            // rs2'den okunan veri
    );

    // Immediate Geniþletme (Sign Extend)
    Extend extension (
        .In(InstrD),
        .Imm_Ext(Imm_Ext_D),
        .ImmSrc(ImmSrcD)
    );

    // Pipeline register'larý güncelleme (stall sinyalleri eklenmiþ)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset sýrasýnda her þeyi sýfýrla
            RegWriteD_r <= 1'b0;
            ALUSrcD_r <= 1'b0;
            MemWriteD_r <= 1'b0;
            MemReadD_r <= 1'b0;
            ResultSrcD_r <= 1'b0;
            BranchD_r <= 1'b0;
            JumpD_r <= 1'b0;
            ALUControlD_r <= 4'b0000;
            RD1_D_r <= 32'h00000000;
            RD2_D_r <= 32'h00000000;
            Imm_Ext_D_r <= 32'h00000000;
            RD_D_r <= 5'h00;
            PCD_r <= 32'h00000000;
            PCPlus4D_r <= 32'h00000000;
            RS1_D_r <= 5'h00;
            RS2_D_r <= 5'h00;
            funct3D_r <= 3'b000;
        end else if (!StallD) begin
            // Stall yoksa normal þekilde güncelle
            RegWriteD_r <= RegWriteD;
            ALUSrcD_r <= ALUSrcD;
            MemWriteD_r <= MemWriteD;
            MemReadD_r <= MemReadD;
            ResultSrcD_r <= ResultSrcD;
            BranchD_r <= BranchD;
            JumpD_r <= JumpD;
            ALUControlD_r <= ALUControlD;
            RD1_D_r <= RD1_D;
            RD2_D_r <= RD2_D;
            Imm_Ext_D_r <= Imm_Ext_D;
            RD_D_r <= InstrD[11:7];
            PCD_r <= PCD;
            PCPlus4D_r <= PCPlus4D;
            RS1_D_r <= InstrD[19:15];
            RS2_D_r <= InstrD[24:20];
            funct3D_r <= InstrD[14:12];
        end
        // Eðer Stall varsa, register'lar korunur, deðiþiklik yapýlmaz.
    end

    // Çýkýþ sinyalleri (always bloðuna taþýndý)
    always @(*) begin
        RegWriteE = RegWriteD_r;
        ALUSrcE = ALUSrcD_r;
        MemWriteE = MemWriteD_r;
        MemReadE = MemReadD_r;
        ResultSrcE = ResultSrcD_r;
        BranchE = BranchD_r;
        JumpE = JumpD_r;
        ALUControlE = ALUControlD_r;
        RD1_E = RD1_D_r;
        RD2_E = RD2_D_r;
        Imm_Ext_E = Imm_Ext_D_r;
        RD_E = RD_D_r;
        PCE = PCD_r;
        PCPlus4E = PCPlus4D_r;
        RS1_E = RS1_D_r;
        RS2_E = RS2_D_r;
        funct3_E = funct3D_r;
    end
endmodule