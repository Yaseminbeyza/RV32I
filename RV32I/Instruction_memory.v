module Instruction_Memory(rst , address, instruction_out);

input rst;
input [31:0] address;
output [31:0]  instruction_out;

reg [31:0] memory [511:0];

  assign instruction_out = (rst == 1'b1) ? {32{1'b0}} : memory[address[31:2]];
endmodule