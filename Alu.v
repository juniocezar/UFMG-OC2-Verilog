/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Alu( 
    input    [31:0]    a, 
    input    [31:0]    b, 
    output reg   [31:0]    aluout, 
    input    [2:0]    op, 
    input    unsig, 
    output reg  compout, 
    output reg  overflow 
);
     
    always@(a or b or op or unsig) begin 
 
        overflow <= 0;            //por padrão overflow = 0 
 
        if(unsig) begin 
            compout <= a < b; 
        end 
        else begin 
            compout <= $signed(a) < $signed(b); 
        end 
 
 
        if(op == 0) begin    //operação '000' AND 
            aluout <= a & b; 
        end 
        else if(op == 1) begin    //operação '001' OR 
            aluout <= a | b; 
        end 
        else if(op == 4) begin    //operação '100' NOR 
            aluout <= ~(a | b); //ALTERACAO EM RELACAO AO ORIGINAL. TIROU (a ~| b) E COLOCOU ~(a | b) 
        end 
        else if(op == 5) begin    //operação '101' XOR 
            aluout <= a ^ b; 
        end 
        else if(op == 2) begin    //operação '010' ADD 
            aluout <= a + b; 
            if(((a[31]) && (b[31]) && (~aluout[31])) || ((~a[31]) && (~b[31]) && (aluout[31]))) begin    //verifica o overflow de acordo com a tabela 
                overflow <= 1; //ALTERACAO EM RELACAO AO ORIGINAL TROCOU & -> && e | por ||
            end 
     
        end 
        else if(op == 6) begin    //operação '110 
            aluout <= a - b; 
            if(((b[31]) && (aluout[31]) && (~a[31])) || ((~b[31]) && (~aluout[31]) && (a[31]))) begin    //verifica o overflow de acordo com a tabela 
                overflow <= 1; 
            end 
        end 
		  else begin//ALTERACAO EM RELACAO AO ORIGINAL - COLOCOU TRATAMENTO OPCODE INVALIDO
				//aluout <= 0;
				overflow <= 0;
				compout <= 0;
		  end
    end 
endmodule
