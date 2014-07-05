/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Memory (

	input clock,
	input reset,

	// execute
	input		ex_mem_readmem, // indica se instrução é de leitura
	input 		ex_mem_writemem, // indica se instrução é de escrita
	input 	[31:0]	ex_mem_regb, // valor a ser escrito na memoria se for inst de escrita
	input 		ex_mem_selwsource, // seleciona o que escrito nos registradores: o valor lido da RAM ou o resultado do estágio de execução
	input 	[4:0]	ex_mem_regdest, // endereço do registrador a ser escrito
	input 		ex_mem_writereg, // indica se a inst escreve no banco de registrador
	input	[31:0]	ex_mem_wbvalue, // resultado do estagio de execução

	// memory controller
	output		mem_mc_rw, // 1 quando é escrita ((!ex_mem_readmem & ex_mem_writemem)
	output		mem_mc_en, // indica se faz acesso a RAM
	output	[17:0]	mem_mc_addr, // endereço que será lido na RAM, Recebe ex_mem_wbvalue[17:0]
	inout	[31:0]	mem_mc_data, // valor a ser escrito na memória ou um valor vindo do controlador de memória
	//Recebe ex_mem_regb quando mem_mc_rw é 1 e recebe um valor vindo do controlador de memória caso contrário

	// write-back
	output reg [4:0] mem_wb_regdest, // recebe valor de ex_mem_regdest
	output reg 	 mem_wb_writereg, // recebe valor de ex_mem_writereg
	output reg [31:0] mem_wb_wbvalue // mem_mc_data se selwsource for 1, ex_mem_wbvalue se 0.

);

	//memory controller
assign mem_mc_rw = (!ex_mem_readmem && ex_mem_writemem) ? 1 : 0;
assign mem_mc_en = (ex_mem_readmem || ex_mem_writemem) ? 1 : 0;
assign mem_mc_addr[17:0] = ex_mem_wbvalue;
assign mem_mc_data = (mem_mc_rw) ? ex_mem_regb : 32'hZZZZZZZZ;

reg cont;
	
initial begin cont = 0; end

always @(posedge clock or negedge reset) begin
	cont = cont + 1;
	if (~reset) begin
		//cont = 0;
		mem_wb_regdest[4:0] = 5'b0;
		mem_wb_writereg = 0;
		mem_wb_wbvalue[31:0] = 32'b0;
	end
	else if (cont == 0) begin
	//saida do writeback
		mem_wb_writereg = ex_mem_writereg;
		mem_wb_regdest = ex_mem_regdest;
		mem_wb_wbvalue = ex_mem_selwsource ? mem_mc_data : ex_mem_wbvalue;
	end
end


endmodule

