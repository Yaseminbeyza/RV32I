`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 17:22:15
// Design Name: 
// Module Name: Control_unite
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


module Control_Unit(
    input [6:0] opcode,     // Opcode alaný
    input [2:0] funct3,     // Funct3 alaný
    input [6:0] funct7,     // Funct7 alaný (R tipi komutlar için)
    output reg RegWrite,    // Register'a yazma izni
    output reg ALUSrc,      // ALU'ya immediate mi yoksa register mý girecek
    output reg MemWrite,    // Belleðe yazma izni
    output reg ResultSrc,   // Bellekten okunan veri mi yoksa ALU sonucu mu register'a yazýlacak
    output reg Branch,      // Dallanma iþlemi
    output reg Jump,        // Jump iþlemi (JAL, JALR)
    output reg [3:0] ALUControl, // ALU kontrol sinyali
    output reg [2:0] ImmSrc // Immediate geniþletme için 3 bit sinyal
);

    always @(*) begin
        case (opcode)
            // R-Tipi komutlar (örneðin ADD, SUB, AND, OR, XOR)
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b0;     // ALU'nun ikinci girdisi register'dan gelir
                MemWrite = 1'b0;   // Belleðe yazma yapýlmaz
                ResultSrc = 1'b0;  // ALU sonucu register'a yazýlýr
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok

                // Funct3 ve Funct7'ye göre ALU kontrol sinyali
                case ({funct7, funct3})
                    10'b0000000000: ALUControl = 4'b0010;  // ADD
                    10'b0100000000: ALUControl = 4'b0110;  // SUB
                    10'b0000000111: ALUControl = 4'b0000;  // AND
                    10'b0000000110: ALUControl = 4'b0001;  // OR
                    10'b0000000100: ALUControl = 4'b0011;  // XOR
                    10'b0000000001: ALUControl = 4'b0100;  // SLL (Logical shift left)
                    10'b0000000101: ALUControl = 4'b0101;  // SRL (Logical shift right)
                    10'b0100000101: ALUControl = 4'b0111;  // SRA (Arithmetic shift right)
                    default: ALUControl = 4'b0000;         // Varsayýlan: AND
                endcase

                ImmSrc = 3'bxxx;    // R-tipi komutlarda immediate yok
            end

            // I-Tipi komutlar (örneðin ADDI, LOAD)
            7'b0010011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;     // ALU'nun ikinci girdisi immediate'den gelir
                MemWrite = 1'b0;   // Belleðe yazma yapýlmaz
                ResultSrc = 1'b0;  // ALU sonucu register'a yazýlýr
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok

                // Funct3'e göre ALU iþlemi
                case (funct3)
                    3'b000: ALUControl = 4'b0010;  // ADDI
                    3'b111: ALUControl = 4'b0000;  // ANDI
                    3'b110: ALUControl = 4'b0001;  // ORI
                    3'b100: ALUControl = 4'b0011;  // XORI
                    3'b001: ALUControl = 4'b0100;  // SLLI
                    3'b101: ALUControl = (funct7 == 7'b0000000) ? 4'b0101 : 4'b0111;  // SRLI veya SRAI
                    default: ALUControl = 4'b0000;  // Varsayýlan: AND
                endcase

                ImmSrc = 3'b000;    // I-Tipi immediate geniþletme
            end

            // Load komutlarý (örneðin LW)
            7'b0000011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;     // Bellekten okuma için adres immediate'den hesaplanýr
                MemWrite = 1'b0;   // Belleðe yazma yapýlmaz
                ResultSrc = 1'b1;  // Bellekten okunan veri register'a yazýlýr
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok
                ALUControl = 4'b0010;  // ALU toplama iþlemi yapar
                ImmSrc = 3'b000;    // I-Tipi immediate geniþletme
            end

            // Store komutlarý (örneðin SW)
            7'b0100011: begin
                RegWrite = 1'b0;   // Belleðe yazma yapýldýðý için register'a yazma yapýlmaz
                ALUSrc = 1'b1;     // Belleðe yazýlacak adres immediate'den hesaplanýr
                MemWrite = 1'b1;   // Belleðe yazma yapýlýr
                ResultSrc = 1'bx;  // Bellekten okuma yapýlmadýðý için önemsiz
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok
                ALUControl = 4'b0010;  // ALU toplama iþlemi yapar
                ImmSrc = 3'b001;    // S-Tipi immediate geniþletme
            end

            // Branch komutlarý (örneðin BEQ)
            7'b1100011: begin
                RegWrite = 1'b0;   // Dallanma komutlarýnda register'a yazma yapýlmaz
                ALUSrc = 1'b0;     // ALU'nun ikinci girdisi register'dan gelir
                MemWrite = 1'b0;   // Belleðe yazma yapýlmaz
                ResultSrc = 1'bx;  // Bellekten okuma yapýlmadýðý için önemsiz
                Branch = 1'b1;     // Dallanma iþlemi yapýlýr
                Jump = 1'b0;       // Jump yok

                // Funct3'e göre dallanma türü (örneðin BEQ, BNE)
                case (funct3)
                    3'b000: ALUControl = 4'b0110;  // BEQ (eþitlik kontrolü)
                    3'b001: ALUControl = 4'b0110;  // BNE (eþit deðil kontrolü)
                    default: ALUControl = 4'b0110;  // Varsayýlan olarak BEQ
                endcase

                ImmSrc = 3'b010;    // B-Tipi immediate geniþletme
            end

            // LUI ve AUIPC komutlarý (U-Tipi)
            7'b0110111, 7'b0010111: begin
                RegWrite = 1'b1;   // Register'a yazma yapýlýr
                ALUSrc = 1'b1;     // Immediate deðer kullanýlýr
                MemWrite = 1'b0;   // Belleðe yazma yapýlmaz
                ResultSrc = 1'b0;  // ALU sonucu register'a yazýlýr
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok
                ALUControl = 4'b0010;  // ALU toplama iþlemi yapar (AUIPC)
                ImmSrc = 3'b011;    // U-Tipi immediate geniþletme
            end

            // JAL komutu (J-Tipi)
            7'b1101111: begin
                RegWrite = 1'b1;   // Geri dönüþ adresi register'a yazýlýr
                ALUSrc = 1'b1;     // Immediate kullanýlýr
                MemWrite = 1'b0;   // Belleðe yazma yapýlmaz
                ResultSrc = 1'b0;  // PC + 4 register'a yazýlýr
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b1;       // Jump var
                ALUControl = 4'b0010;  // ALU toplama iþlemi yapar
                ImmSrc = 3'b100;    // J-Tipi immediate geniþletme
            end

            // JALR komutu (Jump and Link Register)
            7'b1100111: begin
                RegWrite = 1'b1;   // Geri dönüþ adresi register'a yazýlýr
                ALUSrc = 1'b1;     // Immediate kullanýlýr
                MemWrite = 1'b0;   // Belleðe yazma yapýlmaz
                ResultSrc = 1'b0;  // PC + 4 register'a yazýlýr
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b1;       // Jump var
                ALUControl = 4'b0010;  // ALU toplama iþlemi yapar
                ImmSrc = 3'b000;    // I-Tipi immediate geniþletme
            end

            default: begin
                RegWrite = 1'b0;   // Varsayýlan durumda register'a yazma yapýlmaz
                ALUSrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 1'b0;
                Branch = 1'b0;
                Jump = 1'b0;
                ALUControl = 4'b0000;  // ALU durumu geçersiz
                ImmSrc = 3'b000;    // Default I-Tipi geniþletme
            end
        endcase
    end
endmodule