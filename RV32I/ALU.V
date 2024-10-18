`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 20:45:22
// Design Name: 
// Module Name: ALU
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


module ALU(
 input [31:0] A, B,           // ALU'nun iki giriþi
   input [3:0] ALUControl,      // ALU'nun yapacaðý iþlemi belirleyen kontrol sinyali
   output reg [31:0] Result,    // ALU'nun iþlem sonucu
   output Zero,                 // Zero bayraðý: ALU sonucu sýfýr mý?
   output Less                  // Less bayraðý: A < B mi?

    );
    
    
    
      // Zero bayraðý: ALU'nun sonucu sýfýrsa aktif olur
      assign Zero = (Result == 32'b0);
      
      // Less bayraðý: A < B kontrolü (A iþaretli ve iþaretsiz olabilir)
      assign Less = ($signed(A) < $signed(B));
  
      always @(*) begin
          case (ALUControl)
              4'b0010: Result = A + B;        // Toplama (ADD)
              4'b0110: Result = A - B;        // Çýkarma (SUB)
              4'b0000: Result = A & B;        // Mantýksal AND
              4'b0001: Result = A | B;        // Mantýksal OR
              4'b0011: Result = A ^ B;        // Mantýksal XOR
              4'b0100: Result = A << B[4:0];  // Mantýksal sola kaydýrma (SLL)
              4'b0101: Result = A >> B[4:0];  // Mantýksal saða kaydýrma (SRL)
              4'b0111: Result = $signed(A) >>> B[4:0];  // Aritmetik saða kaydýrma (SRA)
              default: Result = 32'b0;        // Varsayýlan durum: ALU sonucu sýfýr
          endcase
      end
endmodule