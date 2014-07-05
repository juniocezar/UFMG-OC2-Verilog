/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Comparator(
    input    [31:0]    a,
    input    [31:0]    b,
    input    [2:0]    op,
    output reg    compout
);
    //reg compout;
    
    always@(a or b or op) begin
        if(op == 0) begin    //operação '000' ==
            compout = a == b;
        end
        else if(op == 1) begin    //operação '001' >=
            compout = a >= b;
        end
        else if(op == 2) begin    //operação '010' <=
            compout = (a <= b);
        end
        else if(op == 3) begin    //operação '011' >
            compout = a > b;
        end
        else if(op == 4) begin    //operação '100' <
            compout = a < b;
        end
        else if(op == 5) begin    //operação '101' !=
            compout = a != b;
        end
    end
endmodule