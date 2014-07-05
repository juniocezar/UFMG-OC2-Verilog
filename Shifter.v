/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Shifter (
	input	[31:0]	in,			//Valor a ser shiftado
	input	[1:0]	shiftop,	//Indica o tipo de shift que sera feito
	input	[4:0]	shiftamt,	//Quantos bits serao deslocados
	output reg	[31:0]	result		//Resultado
);

	always@(in or shiftop or shiftamt) begin
		if(shiftop == 0) begin //shift logico para a direita
			result = in >> shiftamt;
		end
		else if(shiftop == 1) begin //shift aritimetico para a direita
			result = $signed(in) >>> shiftamt;
		end
		else if(shiftop == 2) begin //shift logico para a esquerda
			result = in << shiftamt;
		end
	end

endmodule 