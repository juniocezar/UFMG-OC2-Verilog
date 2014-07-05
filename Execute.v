/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Execute ( 
	input clock, 
	input reset, 
	//Decode 
	input id_ex_selalushift, 
	input id_ex_selimregb, 
	input [2:0] id_ex_aluop, 
	input id_ex_unsig, 
	input [1:0] id_ex_shiftop, 
	input [4:0] id_ex_shiftamt, 
	input [31:0] id_ex_rega, 
	input id_ex_readmem, 
	input id_ex_writemem, 
	input [31:0] id_ex_regb, 
	input [31:0] id_ex_imedext, 
	input id_ex_selwsource, 
	input [4:0] id_ex_regdest, 
	input id_ex_writereg, 
	input id_ex_writeov, 
	//Fetch 
	output reg ex_if_stall, 
	//Memory 
	output reg ex_mem_readmem, 
	output reg ex_mem_writemem, 
	output reg [31:0] ex_mem_regb, 
	output reg ex_mem_selwsource, 
	output reg [4:0] ex_mem_regdest, 
	output reg ex_mem_writereg, 
	output reg [31:0] ex_mem_wbvalue 
); 

	//***Irrelevante nesse trabalho***//
	wire reg_alu_compout;
	//***reg_alu_compout***//
	
	wire reg_alu_overflow; //Sinal de overflow enviado pela ALU
	wire [31:0] reg_alu_result; //Resultado da ALU
	
	wire [31:0] reg_shifter_result; //Resultado do SHIFTER
	
	wire [31:0] b = id_ex_selimregb ? id_ex_imedext : id_ex_regb; //Seleciona qual deve ser a segunda entrada da ALU
	Alu ALU(id_ex_rega, b, reg_alu_result, id_ex_aluop, id_ex_unsig, reg_alu_compout, reg_alu_overflow);
	Shifter SHIFTER(id_ex_regb, id_ex_shiftop, id_ex_shiftamt, reg_shifter_result);

 	//assign ex_mem_regb = id_ex_regb; //JUNIO MUDOU, TIROU DO BLOCO E POS AQUI

 	reg memwrite;
 	reg memread;

	always@(posedge clock or negedge reset) begin
		if (~reset) begin			
			ex_mem_readmem = 0;
			ex_mem_writemem = 0;
			ex_mem_regb = 0;
			ex_mem_selwsource = 0;
			ex_mem_regdest = 0;
			ex_mem_writereg = 0;
			ex_mem_wbvalue = 0;					
			ex_if_stall = 0;
			memwrite = 0;
 			memread = 0;
		end else begin
		//Envia um sinal de stall caso haja um acesso à memória
			
			
			if(id_ex_readmem || id_ex_writemem) ex_if_stall = 1;
			else ex_if_stall = 0;		
			
			
			/**
			 ** Sinais repassados para a memoria
			 **/
			ex_mem_readmem = memread;
			memread = id_ex_readmem;

			ex_mem_writemem = memwrite;
			memwrite = id_ex_writemem;

			ex_mem_regb = id_ex_regb;
			ex_mem_selwsource = id_ex_selwsource;
			ex_mem_regdest = id_ex_regdest;
			
			ex_mem_writereg = ((!reg_alu_overflow | id_ex_writeov) & id_ex_writereg);
			ex_mem_wbvalue = id_ex_selalushift ? reg_shifter_result : reg_alu_result;
		end
	end
	
	
 
 endmodule 
