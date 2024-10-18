module UART (
    input clk,                   // Saat sinyali
    input rst,                   // Reset sinyali
    input [7:0] tx_data,         // Gönderilecek veri (8-bit)
    input tx_start,              // Gönderimi başlatma sinyali
    output reg tx_ready,         // Gönderim hazır sinyali
    output reg tx,               // Tx çıkışı (veri çıkışı)
    input rx,                    // Rx girişi (veri girişi)
    output reg [7:0] rx_data,    // Alınan veri (8-bit)
    output reg rx_ready,         // Veri alındığında sinyal
    input [15:0] baud_div,       // Programlanabilir baud rate faktörü
    output reg [7:0] tx_buffer_data, // TX buffer'dan gönderilen veri
    output reg [7:0] rx_buffer_data  // RX buffer'dan alınan veri
);

    // Dahili sayaçlar ve kayıtlar
    reg [15:0] baud_counter;       // Baud rate sayacı
    reg [3:0] tx_bit_counter;      // Gönderim bit sayacı
    reg [3:0] rx_bit_counter;      // Alım bit sayacı
    reg [7:0] tx_shift_reg;        // Gönderim kaydırma kaydı
    reg [7:0] rx_shift_reg;        // Alım kaydırma kaydı
    reg tx_busy;                   // Gönderim modülü meşgul
    reg rx_busy;                   // Alım modülü meşgul
    reg [7:0] tx_buffer [31:0];    // 32x8-bit TX buffer (dahili)
    reg [7:0] rx_buffer [31:0];    // 32x8-bit RX buffer (dahili)
    reg [4:0] tx_buffer_write_ptr; // TX tampon yazma işaretçisi
    reg [4:0] tx_buffer_read_ptr;  // TX tampon okuma işaretçisi
    reg [4:0] rx_buffer_write_ptr; // RX tampon yazma işaretçisi
    reg [4:0] rx_buffer_read_ptr;  // RX tampon okuma işaretçisi
 // Belleğe veri yazma işlemi
    always @(posedge clk) begin
        if (MemWrite) begin
            case (MemSize)
                2'b00: begin // Byte yazma (8-bit)
                    memory[address[10:2]][(address[1:0] * 8) +: 8] <= write_data[7:0];
                end
                2'b01: begin // Halfword yazma (16-bit)
                    memory[address[10:2]][(address[1] * 16) +: 16] <= write_data[15:0];
                end
                2'b10: begin // Word yazma (32-bit)
                    memory[address[10:2]] <= write_data;
                end
                default: begin
                    // Desteklenmeyen boyutlar için herhangi bir işlem yapılmaz
                end
            endcase
        end
    end
 // Bellekten veri okuma işlemi
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 32'b0;
            Ready <= 1'b0;
            cycle_counter <= 3'b000;  // Reset durumunda sayaç ve ready sinyali sıfırlanır
        end else if (MemRead) begin
            if (cycle_counter == 3'b000) begin
                // Dinamik bellek gecikmesini belirlemek için basit adres bazlı koşullar
                if (address < 32'h00000400) begin
                    // Hızlı erişim: 1 cycle (0x00000000 - 0x000003FF)
                    cycle_counter <= 3'b001;
                end else if (address >= 32'h00000400 && address < 32'h00000600) begin
                    // Orta hız: 2 cycle (0x00000400 - 0x000005FF)
                    cycle_counter <= 3'b010;
                end else if (address >= 32'h00000600 && address < 32'h00000800) begin
                    // Yavaş erişim: 3 cycle (0x00000600 - 0x000007FF)
                    cycle_counter <= 3'b011;
                end
                Ready <= 1'b0;  // Başlangıçta veri hazır değil
            end 
            else if (cycle_counter > 3'b000) begin
                cycle_counter <= cycle_counter - 1;  // Geriye doğru sayarak cycle'ı azalt
                if (cycle_counter == 3'b001) begin
                    // Veri hazır olduğunda (cycle counter sıfıra ulaşınca)
                    case (MemSize)
                        2'b00: data_out <= {24'b0, memory[address[10:2]][(address[1:0] * 8) +: 8]}; // Byte okuma
                        2'b01: data_out <= {16'b0, memory[address[10:2]][(address[1] * 16) +: 16]}; // Halfword okuma
                        2'b10: data_out <= memory[address[10:2]]; // Word okuma
                        default: data_out <= 32'b0;  // Desteklenmeyen boyutlar için sıfır döner
                    endcase
                    Ready <= 1'b1;  // Veri hazır
                end
            end
        end else begin
            data_out <= 32'b0;
            Ready <= 1'b0;
            cycle_counter <= 3'b000;  // MemRead aktif değilse, sayaç sıfırlanır
        end
    end

endmodule