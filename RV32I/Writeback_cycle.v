module WriteBack_Cycle(
 input clk,                      // Saat sinyali
   input [31:0] ReadDataW,          // Bellekten okunan veri
   input [31:0] ALUResultW,         // ALU sonucu
   input [31:0] PCPlus4W,           // PC + 4 deðeri (örneðin, JAL için)
   input [1:0] ResultSrcW,          // Yazýlacak veriyi seçen sinyal (mux kontrol)
   input RegWriteW,                 // Register'a yazma izni
   input [4:0] RdW,                 // Hedef register adresi
   output [31:0] ResultW            // Register'a yazýlacak nihai veri

    );
    
    // Mux ile yazýlacak veriyi seçme
        wire [31:0] selected_data;
    
        
        mux_3_1 mux_3_1_instance (
            .a(ALUResultW),     // ALU sonucu
            .b(ReadDataW),      // Bellekten okunan veri
            .c(PCPlus4W),       // PC + 4 deðeri (JAL komutu için)
            .s(ResultSrcW),     // Seçim sinyali
            .d(selected_data)   // Çýkýþ: yazýlacak veri
        );
    
        // Register dosyasýna yazýlacak olan nihai veri
        assign ResultW = selected_data;
    
        
   
endmodule