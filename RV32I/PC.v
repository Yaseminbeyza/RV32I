module PC (
    input clk,
    input rst,
    input StallF,           // Fetch aþamasýnda durdurma sinyali
    input [31:0] PC_Next,   // Bir sonraki program sayacý deðeri
    output reg [31:0] PC    // Mevcut program sayacý deðeri
);

always @(posedge clk or posedge rst)  
begin
    if (rst == 1'b1)  
        PC <= 32'b0;        // Reset sýrasýnda program sayacý sýfýrlanýr
    else if (!StallF)       // StallF aktif deðilse, PC güncellenir
        PC <= PC_Next;      // PC, bir sonraki deðere güncellenir
    // StallF aktifse, PC ayný kalýr (yani durur)
end

endmodule