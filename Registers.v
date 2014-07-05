/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Registers (
	input	clock,
	input	reset,
	input 	[4:0] addra,
	output reg	[31:0] dataa,
	output		[31:0] ass_dataa,
	input	[4:0] addrb,
	output reg	[31:0] datab,
	output		[31:0] ass_datab,
	input	enc,
	input	[4:0] addrc,
	input	[31:0] datac,
	input [4:0] addrout,
	output [31:0] regout
	
);

	assign ass_dataa = registers[addra];
	assign ass_datab = registers[addrb];
	assign regout = registers[addrout];
	
	reg [31:0] registers [31:0];
	reg [31:0] visual;
	integer i,j;

	always @(clock or reset) begin
		if (~reset) begin
			registers[0]=32'd0;
			registers[1]=32'd0;
			registers[2]=32'd0;
			registers[3]=32'd0;
			registers[4]=32'd0;
			registers[5]=32'd0;
			registers[6]=32'd0;
			registers[7]=32'd0;
			registers[8]=32'd0;
			registers[9]=32'd0;
			registers[10]=32'd0;
			registers[11]=32'd0;
			registers[12]=32'd0;
			registers[13]=32'd0;
			registers[14]=32'd0;
			registers[15]=32'd0;
			registers[16]=32'd0;
			registers[17]=32'd0;
			registers[18]=32'd0;
			registers[19]=32'd0;
			registers[20]=32'd0;
			registers[21]=32'd0;
			registers[22]=32'd0;
			registers[23]=32'd0;
			registers[24]=32'd0;
			registers[25]=32'd0;
			registers[26]=32'd0;
			registers[27]=32'd0;
			registers[28]=32'd0;
			registers[29]=32'd0;
			registers[30]=32'd0;
			registers[31]=32'd0;
		end
		else begin
			dataa = registers[addra];
			datab = registers[addrb];			
			//escreve no registrador
			if (enc) begin
				registers[addrc][31:0] = datac;
			end
			visual = addrc;
		end
		

	end
	

endmodule
