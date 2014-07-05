/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module FPGA(
  input  [17:0] SW,
  output [17:0] LEDR,
  output [6:0] HEX0,HEX1, HEX2, HEX3,
  output [6:0] HEX4,HEX5, HEX6, HEX7,
  input  [3:0] KEY,
  output [17:0] SRAM_ADDR, //[19:0] na DE2-115
  output SRAM_WE_N, //habilita escrita na ram com valor 0
  inout  [15:0] SRAM_DQ, //16 bits data bus da memoria
  output SRAM_OE_N, 
  output SRAM_UB_N,
  output SRAM_LB_N,
  output SRAM_CE_N
  );
  
  // ====== Wires do Memcontroller ====== //
  wire  clock, reset;  
  
  // ====== Assinalamentos com pinos da FPGA ====== //
  assign LEDR[17:0] = SW[17:0];
  assign clock = ~KEY[1];
  assign reset = SW[17];  

  //assign SRAM_ADDR[19:18] = 2'b00; //DE2-115
  
  wire    [31:0]   regout;
  wire    [31:0]   memout;
  reg     [31:0]   disp;  
  wire    [4:0]    addr;

    
    assign addr = SW[4:0];

  Mips MIPS(.clock(clock),.reset(reset),.addr(SRAM_ADDR),.data(SRAM_DQ),.wre(SRAM_WE_N),
              .oute(SRAM_OE_N),.hb_mask(SRAM_UB_N),.lb_mask(SRAM_LB_N),.chip_en(SRAM_CE_N),.regout(regout),.addrout(addr),.memout(memout));


  always @(*) begin
    case (SW[6:5])
      2'b00: disp = regout;
      2'b01: disp = addr;
      2'b10: disp = memout;
      2'b11: disp = 32'h0000_0000;      
    endcase
  end
        
        
  Display D0(disp [3:0], HEX0);
  Display D1(disp [7:4], HEX1);
  Display D2(disp [11:8], HEX2);
  Display D3(disp [15:12], HEX3);
  Display D4(disp [19:16], HEX4);
  Display D5(disp [23:20], HEX5);
  Display D6(disp [27:24], HEX6);
  Display D7(disp [31:28], HEX7); 
  
endmodule



module Display(Sinal, HEX);

   input [3:0] Sinal;//valor a ser exibido

   output [6:0] HEX;//Display que exibira os valores

   reg [6:0] seg;

  always @(*)
    case(Sinal)//logica correspondente de cada valor a ser exibido (o display da altera apaga com 1 e acende com 0)
  4'h1: seg = 7'b1111001;
  4'h2: seg = 7'b0100100;
  4'h3: seg = 7'b0110000;
  4'h4: seg = 7'b0011001;
  4'h5: seg = 7'b0010010;
  4'h6: seg = 7'b0000010;
  4'h7: seg = 7'b1111000;
  4'h8: seg = 7'b0000000;
  4'h9: seg = 7'b0011000;
  4'ha: seg = 7'b0001000;
  4'hb: seg = 7'b0000011;
  4'hc: seg = 7'b1000110;
  4'hd: seg = 7'b0100001;
  4'he: seg = 7'b0000110;
  4'hf: seg = 7'b0001110;
  4'h0: seg = 7'b1000000;
  endcase

  assign HEX[0] = seg[0];
  assign HEX[1] = seg[1];
  assign HEX[2] = seg[2];
  assign HEX[3] = seg[3];
  assign HEX[4] = seg[4];
  assign HEX[5] = seg[5];
  assign HEX[6] = seg[6];

endmodule
