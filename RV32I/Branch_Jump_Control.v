`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 20:49:08
// Design Name: 
// Module Name: Branch_Jump_Control
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


module Branch_Jump_Control(
input Branch, Jump,         // Branch ve Jump sinyalleri (Control Unit'ten gelir)
    input Zero, Less,           // ALU'dan gelen Zero ve Less bayraklarý
    input [2:0] funct3,         // Dallanma türünü belirlemek için funct3 sinyali
    output reg PCSrc            // Nihai atlama veya dallanma kararý (1 ise atla)

    );
    
     always @(*) begin
           // Varsayýlan olarak dallanma veya atlama yok
           PCSrc = 1'b0;
   
           // Jump sinyali aktifse, atla (JAL, JALR)
           if (Jump) begin
               PCSrc = 1'b1;
           end
           
           // Branch sinyali aktifse dallanma kontrolü yap
           else if (Branch) begin
               case (funct3)
                   3'b000: PCSrc = Zero;        // BEQ: Zero bayraðý 1 ise dallan
                   3'b001: PCSrc = ~Zero;       // BNE: Zero bayraðý 0 ise dallan
                   3'b100: PCSrc = Less;        // BLT: Less bayraðý 1 ise dallan
                   3'b101: PCSrc = ~Less;       // BGE: Less bayraðý 0 ise dallan
                   default: PCSrc = 1'b0;       // Diðer durumlarda dallanma yok
               endcase
           end
       end

    
endmodule