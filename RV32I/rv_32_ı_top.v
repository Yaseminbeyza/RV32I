`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 22:14:15
// Design Name: 
// Module Name: RV32I_Processor
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


module RV32I_Processor(
 input clk, rst 
    );
    
     // --- Fetch aþamasý sinyalleri ---
       wire [31:0] PCF, PCPlus4F, InstrF;
       wire StallF;
       
       // --- Decode aþamasý sinyalleri ---
       wire [31:0] PCD, PCPlus4D, InstrD, RD1_D, RD2_D, Imm_Ext_D;
       wire [4:0] RD_D, RS1_D, RS2_D;
       wire [2:0] funct3D;
       wire RegWriteD, ALUSrcD, MemWriteD, MemReadD, ResultSrcD, BranchD, JumpD;
       wire [3:0] ALUControlD;
       wire StallD;
   
       // --- Execute aþamasý sinyalleri ---
       wire [31:0] RD1_E, RD2_E, Imm_Ext_E, ALUResultE, WriteDataE, PCTargetE;
       wire ZeroE, LessE, PCSrcE;
       wire [4:0] RD_E, RS1_E, RS2_E;
       wire [2:0] funct3E;
       wire RegWriteE, ALUSrcE, MemWriteE, MemReadE, ResultSrcE, BranchE, JumpE;
       wire [3:0] ALUControlE;
   
       // --- Memory aþamasý sinyalleri ---
       wire [31:0] ReadDataM, ALUResultM;
       wire [4:0] RD_M;
       wire RegWriteM, MemWriteM, MemReadM, ResultSrcM;
   
       // --- Write-back aþamasý sinyalleri ---
       wire [31:0] ResultW;
       wire [4:0] RdW;
       wire RegWriteW;
   
       // --- Hazard Unit Sinyalleri ---
       wire [1:0] ForwardAE, ForwardBE;

       // --- Hazard Unit ---
       Hazard_unit hazard_unit_inst (
           .rst(rst),
           .MemReadM(MemReadM),
           .RegWriteM(RegWriteM),
           .RegWriteW(RegWriteW),
           .Rd_M(RD_M),
           .Rd_W(RdW),
           .Rs1_E(RS1_E),
           .Rs2_E(RS2_E),
           .StallF(StallF),
           .StallD(StallD),
           .ForwardAE(ForwardAE),
           .ForwardBE(ForwardBE)
       );

       // --- Fetch Cycle ---
       
       Fetch_cycle fetch_cycle (
           .clk(clk),
           .rst(rst),
           .PCSrcE(PCSrcE),
           .PCTargetE(PCTargetE),
           .StallF(StallF),
           .InstrD(InstrF),
           .PCD(PCF),
           .PCplus4D(PCPlus4F)
       );
   
       // --- Decode Cycle ---
       Ddecode_Cycle decode_cycle (
           .clk(clk),
           .rst(rst),
           .StallD(StallD),
           .InstrD(InstrF),
           .PCD(PCF),
           .PCPlus4D(PCPlus4F),
           .RegWriteW(RegWriteW),
           .RDW(RdW),
           .ResultW(ResultW),
           .RegWriteE(RegWriteE),
           .ALUSrcE(ALUSrcE),
           .MemWriteE(MemWriteE),
           .MemReadE(MemReadE),
           .ResultSrcE(ResultSrcE),
           .BranchE(BranchE),
           .JumpE(JumpE),
           .ALUControlE(ALUControlE),
           .RD1_E(RD1_E),
           .RD2_E(RD2_E),
           .Imm_Ext_E(Imm_Ext_E),
           .RS1_E(RS1_E),
           .RS2_E(RS2_E),
           .RD_E(RD_E),
           .funct3_E(funct3E),
           .PCE(PCF),
           .PCPlus4E(PCPlus4F)
       );
   
       // --- Execute Cycle ---
       Execute_Cycle execute_cycle (
           .clk(clk),
           .rst(rst),
           .RD1_E(RD1_E),
           .RD2_E(RD2_E),
           .Imm_Ext_E(Imm_Ext_E),
           .ALUSrcE(ALUSrcE),
           .ALUControlE(ALUControlE),
           .BranchE(BranchE),
           .funct3_E(funct3E),
           .PCPlus4E(PCPlus4F),
           .PCE(PCF),
           .ALUResultM(ALUResultE),
           .WriteDataM(WriteDataE),
           .PCTargetE(PCTargetE),
           .ZeroE(ZeroE),
           .LessE(LessE),
           .PCSrcE(PCSrcE),
           .RD_E(RD_E),
           .ForwardAE(ForwardAE),
           .ForwardBE(ForwardBE)
       );
   
       // --- Memory Cycle ---
       Memory_Cycle memory_cycle (
           .clk(clk),
           .rst(rst),
           .ALUResultM(ALUResultE),
           .WriteDataM(WriteDataE),
           .RD_M(RD_E),
           .MemWriteM(MemWriteE),
           .MemReadM(MemReadE),
           .ResultSrcM(ResultSrcE),
           .ReadDataM(ReadDataM),
           .ALUResultM_out(ALUResultM),
           .RegWriteM(RegWriteM),
           .RDW(RD_M)
       );
   
       // --- Write-back Cycle ---
       WriteBack_Cycle writeback_cycle (
           .clk(clk),
           .ReadDataW(ReadDataM),
           .ALUResultW(ALUResultM),
           .PCPlus4W(PCPlus4F),
           .ResultSrcW(ResultSrcE),
           .RegWriteW(RegWriteM),
           .RdW(RD_M),
           .ResultW(ResultW)
       );
   
endmodule