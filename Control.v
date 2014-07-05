/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Control (
	input   [5:0]  op,
	input   [5:0]  fn,
	output  [2:0]  selwsource,
	output  [1:0]  selregdest,
	output  writereg,
	output  writeov,
	output  selimregb,
	output  selalushift,
	output  [2:0]  aluop,
	output  [1:0]  shiftop,
	output  readmem,
	output  writemem,
	output  [1:0]  selbrjumpz,
	output  [1:0]  selpctype, //seltipopc
	output  [2:0]  compop,
	output  unsig
);
	
	//Registradores Auxiliares para concatenacao dos sinais
	reg [11:0] entrada;
	reg [23:0] saida;

	//Atrelacao dos sinais de saida
	assign	writemem = saida[0];
	assign	readmem = saida[1];
	assign	selpctype = saida[3:2];
	assign	compop = saida[6:4];
	assign	selalushift = saida[7];
	assign	aluop = saida[10:8];
	assign	shiftop = saida[12:11];
	assign	unsig = saida[13];
	assign	writeov = saida[14];
	assign	writereg = saida[15];
	assign	selwsource = saida[18:16];
	assign	selregdest = saida[20:19];
	assign	selbrjumpz = saida[22:21];
	assign	selimregb = saida[23];
 

	always@(op or fn) begin 

		
		entrada = {op,fn}; //Concatenacao dos valores de entrada

		casex(entrada)
			12'b000000000100 : saida = 24'b0000100011x10xxx1xxxxx00; //SLLV
			12'b000000000110 : saida = 24'b0000100011x00xxx1xxxxx00; //SRLV
			12'b000000000111 : saida = 24'b0000100011x01xxx1xxxxx00; //SRAV
			12'b000000001000 : saida = 24'bx01xxxxx0xxxxxxxxxxx0100; //JR
			12'b000000100000 : saida = 24'b00001000100xx0100xxxxx00; //ADD
			12'b000000100001 : saida = 24'b00001000111xx0100xxxxx00; //ADDU
			12'b000000100010 : saida = 24'b00001000100xx1100xxxxx00; //SUB
			12'b000000100011 : saida = 24'b00001000111xx1100xxxxx00; //SUBU
			12'b000000100100 : saida = 24'b0000100011xxx0000xxxxx00; //AND
			12'b000000100101 : saida = 24'b0000100011xxx0010xxxxx00; //OR
			12'b000000100110 : saida = 24'b0000100011xxx1010xxxxx00; //XOR
			12'b000000100111 : saida = 24'b0000100011xxx1000xxxxx00; //NOR
			12'b000010xxxxxx : saida = 24'bx01xxxxx0xxxxxxxxxxx1000; //J
			12'b000100xxxxxx : saida = 24'bx10xxxxx0x0xxxxxx0000000; //BEQ
			12'b000101xxxxxx : saida = 24'bx10xxxxx0x0xxxxxx1010000; //BNE
			12'b000110xxxxxx : saida = 24'bx10xxxxx0x0xxxxxx0100000; //BLEZ
			12'b000111xxxxxx : saida = 24'bx10xxxxx0x0xxxxxx0110000; //BGTZ
			12'b001000xxxxxx : saida = 24'b10000000100xx0100xxxxx00; //ADDI
			12'b001001xxxxxx : saida = 24'b10000000111xx0100xxxxx00; //ADDIU
			12'b001100xxxxxx : saida = 24'b1000000011xxx0000xxxxx00; //ANDI
			12'b001101xxxxxx : saida = 24'b1000000011xxx0010xxxxx00; //ORI
			12'b001110xxxxxx : saida = 24'b1000000011xxx1010xxxxx00; //XORI
			12'b100011xxxxxx : saida = 24'b10000001110xx0100xxxxx10; //LW
			12'b101011xxxxxx : saida = 24'b100xxxxx0x0xx0100xxxxx01; //SW
			default : saida = 24'b000000000000001100000000; //Bloqueio geral para opcodes invalidos//o 11 é pq ALUOP 11 = 3 não exite, e o 00 existe e é AND, logo o bloquei não seria 100% eficiente com 00
		endcase

	end
endmodule
