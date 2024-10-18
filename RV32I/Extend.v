module Extend(In, ImmSrc, Imm_Ext);

 input [31:0] In;      // Komutun tamamý (instruction)
    input [2:0] ImmSrc;   // Immediate türünü seçmek için (artýk 3 bit, çünkü 5 türü destekliyor)
    output reg [31:0] Imm_Ext;  // Geniþletilmiþ immediate çýkýþý

    always @(*) begin
        case (ImmSrc)
            3'b000: Imm_Ext = {{20{In[31]}}, In[31:20]}; // I tipi (iþaret geniþletme)
            3'b001: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]}; // S tipi (iþaret geniþletme)
            3'b010: Imm_Ext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0}; // B tipi (iþaret geniþletme)
            3'b011: Imm_Ext = {In[31:12], 12'b0}; // U tipi (iþaretsiz geniþletme)
            3'b100: Imm_Ext = {{11{In[31]}}, In[31], In[19:12], In[20], In[30:21], 1'b0}; // J tipi (iþaret geniþletme)
            default: Imm_Ext = 32'h00000000;  // Default, bilinmeyen bir immediate türü varsa sýfýr döner
        endcase
    end
endmodule