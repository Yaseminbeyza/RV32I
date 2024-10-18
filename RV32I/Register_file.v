`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 15:42:24
// Design Name: 
// Module Name: Register_file
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


module Register_file(clk,rst,WE3,WD3,address1,address2,address3,RD1,RD2);

    input clk,rst,WE3;
    input [4:0] address1, address2, address3;  // Adres sinyalleri
    input [31:0] WD3;
    output [31:0] RD1, RD2;
    
     reg [31:0] Register [31:0];
      // Register'a yazma iþlemi
        always @(posedge clk) begin
            if (WE3 & (address3 != 5'h00)) begin  // x0 register'ýna yazma engellenir
                Register[address3] <= WD3;
            end
        end
             
       assign RD1 = (rst==1'b1) ? 32'd0 : Register[address1];
        assign RD2 = (rst==1'b1) ? 32'd0 : Register[address2];
    
        initial begin
            Register[0] = 32'h00000000;
        end

    
endmodule