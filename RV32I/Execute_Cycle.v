`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 21:29:49
// Design Name: 
// Module Name: Execute_Cycle
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


module Execute_Cycle(
  input clk, rst,                      // Clock ve reset sinyalleri
  input [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, // Register'dan gelen veriler ve genişletilmiş immediate
  input [4:0] RS1_E, RS2_E, RD_E,      // Register numaraları
  input [3:0] ALUControlE,             // ALU kontrol sinyali
  input ALUSrcE, MemWriteE, MemReadE, ResultSrcE, BranchE, JumpE,  // Kontrol sinyalleri
  input [2:0] funct3_E,                // funct3 sinyali (dallanma ve ALU işlemleri için)
  input RegWriteM, RegWriteW,           // Memory ve Write-back aşamalarındaki yazma izni
  input [31:0] ALUResultM, ResultW,     // ALU sonucu ve write-back sonucu
  input [4:0] RD_M, RD_W,              // Memory ve Write-back aşamalarındaki hedef register'lar
  output [31:0] ALUResultM_out, WriteDataM, PCTargetE, PCPlus4M,   // Çıkış verileri
  output ZeroE, LessE,                 // Zero ve Less bayrakları
  output MemWriteM, MemReadM, ResultSrcM, BranchM, JumpM,          // Bellek, Branch, Jump sinyalleri
  output [4:0] RD_M_out                // Hedef register (write-back için)
);

  // Forwarding sinyalleri
  wire [1:0] ForwardAE, ForwardBE;
  
  // ALU giriş ve çıkışları
  wire [31:0] SrcA, SrcB, ALUResult; 
  wire Zero, Less;

  // Forwarding işlemleri: SrcA ve SrcB'yi mux ile seçiyoruz
  mux_3_1 muxA (
    .a(RD1_E),         // Register'dan gelen veri
    .b(ALUResultM),     // Memory aşamasından gelen veri
    .c(ResultW),        // Write-back aşamasından gelen veri
    .s(ForwardAE),      // Forwarding seçim sinyali
    .d(SrcA)            // ALU'nun A girişi
  );

  mux_3_1 muxB (
    .a(RD2_E),         // Register'dan gelen veri
    .b(ALUResultM),     // Memory aşamasından gelen veri
    .c(ResultW),        // Write-back aşamasından gelen veri
    .s(ForwardBE),      // Forwarding seçim sinyali
    .d(SrcB)            // ALU'nun B girişi
  );

  // ALU işlemleri
  ALU alu (
    .A(SrcA),
    .B(SrcB),
    .ALUControl(ALUControlE),
    .Result(ALUResult),
    .Zero(Zero),
    .Less(Less)
  );

  // Branch ve Jump kararı (Zero ve Less bayraklarına göre)
  Branch_Jump_Control branch_jump_control (
    .Branch(BranchE),
    .Jump(JumpE),
    .Zero(Zero),
    .Less(Less),
    .funct3(funct3_E),
    .PCSrc(PCTargetE)   // Nihai branch veya jump kararı
  );

  // Hazard unit'ten forwarding sinyalleri için giriş-çıkış bağlantısı
  Hazard_unit hazard_unit_inst (
    .rst(rst),
    .MemReadM(MemReadE),           // Memory aşamasındaki belleğe okuma sinyali
    .Ready(1'b1),                  // Ready sinyali (veri hazır)
    .RegWriteM(RegWriteM),         // Memory aşamasındaki yazma izni
    .RegWriteW(RegWriteW),         // Write-back aşamasındaki yazma izni
    .Rd_M(RD_M),                   // Memory aşamasındaki hedef register
    .Rd_W(RD_W),                   // Write-back aşamasındaki hedef register
    .Rs1_E(RS1_E), .Rs2_E(RS2_E),  // Execute aşamasındaki kaynak register'lar
    .ForwardAE(ForwardAE),         // ALU için forwarding sinyali A
    .ForwardBE(ForwardBE)          // ALU için forwarding sinyali B
  );

  // Pipeline register'lar (Memory aşamasına geçiş)
  reg MemWriteE_r, MemReadE_r, ResultSrcE_r, BranchE_r, JumpE_r;
  reg [31:0] ALUResultE_r, WriteDataE_r, PCPlus4E_r;
  reg [4:0] RD_E_r;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset sırasında tüm sinyalleri sıfırla
      MemWriteE_r <= 1'b0;
      MemReadE_r <= 1'b0;
      ResultSrcE_r <= 1'b0;
      BranchE_r <= 1'b0;
      JumpE_r <= 1'b0;
      ALUResultE_r <= 32'h00000000;
      WriteDataE_r <= 32'h00000000;
      PCPlus4E_r <= 32'h00000000;
      RD_E_r <= 5'h00;
    end else begin
      // Normal çalışma sırasında sinyalleri geçiştir
      MemWriteE_r <= MemWriteE;
      MemReadE_r <= MemReadE;
      ResultSrcE_r <= ResultSrcE;
      BranchE_r <= BranchE;
      JumpE_r <= JumpE;
      ALUResultE_r <= ALUResult;
      WriteDataE_r <= RD2_E;       // Belleğe yazılacak veri (RD2'den gelen veri)
      PCPlus4E_r <= PCPlus4E;      // PC + 4 değeri
      RD_E_r <= RD_E;              // Hedef register (write-back aşamasında kullanılacak)
    end
  end

  // Zero ve Less bayrakları
  assign ZeroE = Zero;
  assign LessE = Less;

  // Çıkış sinyalleri (Memory aşamasına aktarılacak)
  assign ALUResultM_out = ALUResultE_r;
  assign WriteDataM = WriteDataE_r;
  assign PCTargetE = PCE + Imm_Ext_E; // Branch veya Jump hedefi
  assign PCPlus4M = PCPlus4E_r;
  assign MemWriteM = MemWriteE_r;
  assign MemReadM = MemReadE_r;
  assign ResultSrcM = ResultSrcE_r;
  assign BranchM = BranchE_r;
  assign JumpM = JumpE_r;
  assign RD_M_out = RD_E_r;

endmodule