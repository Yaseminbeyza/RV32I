module Hazard_unit(
 input rst,                   // Reset sinyali
   input MemReadM,              // Bellekten okuma (load) sinyali
   input Ready,                 // Bellekten okuma iþleminin tamamlanýp tamamlanmadýðýný gösteren sinyal
   input RegWriteM,             // Memory aþamasýnda register yazma sinyali
   input RegWriteW,             // Write-back aþamasýnda register yazma sinyali
   input [4:0] Rd_M,            // Memory aþamasýndaki hedef register (Rd)
   input [4:0] Rd_W,            // Write-back aþamasýndaki hedef register (Rd)
   input [4:0] Rs1_D, Rs2_D,    // Decode aþamasýndaki kaynak register'lar (Rs1 ve Rs2)
   input [4:0] Rs1_E, Rs2_E,    // Execute aþamasýndaki kaynak register'lar (Rs1 ve Rs2)
   output reg [1:0] ForwardAE,  // Forwarding sinyali A (ALU'nun ilk girdisi)
   output reg [1:0] ForwardBE,  // Forwarding sinyali B (ALU'nun ikinci girdisi)
   output reg StallF,           // Fetch aþamasýný durdurma sinyali
   output reg StallD            // Decode aþamasýný durdurma sinyali

    );
    
    
    always @(*) begin
            // Varsayýlan deðerler
            StallF = 1'b0;
            StallD = 1'b0;
            ForwardAE = 2'b00;  // 00: register'dan gelen veri
            ForwardBE = 2'b00;  // 00: register'dan gelen veri
    
            // Reset durumu
            if (rst) begin
                StallF = 1'b0;
                StallD = 1'b0;
                ForwardAE = 2'b00;
                ForwardBE = 2'b00;
            end else begin
                // Load-use hazard: Load sonrasý kullanýma yönelik stall
                if (MemReadM && ((Rd_M == Rs1_D) || (Rd_M == Rs2_D)) && !Ready) begin
                    // Eðer Memory aþamasýnda bir load komutu varsa ve Rs1 veya Rs2'de baðýmlýlýk varsa
                    StallF = 1'b1;  // Fetch aþamasýný durdur
                    StallD = 1'b1;  // Decode aþamasýný durdur
                end
    
                // Forwarding Logic
                // ForwardAE (ALU'nun ilk girdisi için)
                if (RegWriteM && (Rd_M != 5'h00) && (Rd_M == Rs1_E)) begin
                    ForwardAE = 2'b10;  // Memory aþamasýndan ALU'ya forwarding
                end else if (RegWriteW && (Rd_W != 5'h00) && (Rd_W == Rs1_E)) begin
                    ForwardAE = 2'b01;  // Write-back aþamasýndan ALU'ya forwarding
                end
    
                // ForwardBE (ALU'nun ikinci girdisi için)
                if (RegWriteM && (Rd_M != 5'h00) && (Rd_M == Rs2_E)) begin
                    ForwardBE = 2'b10;  // Memory aþamasýndan ALU'ya forwarding
                end else if (RegWriteW && (Rd_W != 5'h00) && (Rd_W == Rs2_E)) begin
                    ForwardBE = 2'b01;  // Write-back aþamasýndan ALU'ya forwarding
                end
            end
        end

    
endmodule