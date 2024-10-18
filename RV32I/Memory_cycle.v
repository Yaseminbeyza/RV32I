module Memory_Cycle(
input clk, rst,                     // Clock ve reset sinyalleri
    input [31:0] ALUResultM, WriteDataM, // ALU sonucundan gelen adres ve belleðe yazýlacak veri
    input [4:0] RD_M,                    // Hedef register (write-back için)
    input MemWriteM, MemReadM,            // Belleðe yazma ve okuma sinyalleri
    input ResultSrcM,                     // ALU sonucu veya bellekten okunan veriyi seçen sinyal
    output [31:0] ReadDataM, ALUResultW,  // Bellekten okunan veri ve ALU sonucu
    output RegWriteM,                     // Register'a yazma izni
    output [4:0] RDW                     // Hedef register (write-back için)

    );
    
    
    wire [31:0] Data_Memory_Out;          // Bellekten okunan veri
    
        // Data Memory modülünü çaðýrma
        Data_Memory data_memory (
            .clk(clk),
            .rst(rst),
            .address(ALUResultM),             // ALU sonucundan gelen bellek adresi
            .write_data(WriteDataM),          // Belleðe yazýlacak veri
            .MemWrite(MemWriteM),             // Belleðe yazma izni
            .MemRead(MemReadM),               // Bellekten okuma izni
            .data_out(Data_Memory_Out)        // Bellekten okunan veri (output: data_out)
        );
    
        // Bellekten okunan veri veya ALU sonucunu seç (write-back için)
        assign ReadDataM = Data_Memory_Out;
        assign ALUResultW = ALUResultM;
    
        // Bellek aþamasýndaki sinyalleri bir sonraki aþamaya aktar (write-back)
        assign RegWriteM = ResultSrcM;       // Register'a yazma izni
        assign RDW = RD_M;                   // Hedef register (write-back aþamasýna)
endmodule