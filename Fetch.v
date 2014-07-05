/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Fetch (
	input				clock,
	input				reset,
	//Execute
	input				ex_if_stall,
	//Decode
	output reg	[31:0]	if_id_nextpc,
	output reg	[31:0]	if_id_instruc,
	input				id_if_selpcsource,
	input		[31:0]	id_if_rega,
	input		[31:0]	id_if_pcimd2ext,
	input		[31:0]	id_if_pcindex,
	input		[1:0]	id_if_selpctype,
	//Memory Controller
	output reg			if_mc_en,
	output 		[31:0]	if_mc_addr, //MUDEI DE 31 para 18
	input		[31:0]	mc_if_data
);

	reg [31:0] pc,current,nextpc_reg;
	reg [31:0] instruction;
	reg [31:0] anterior;
	reg [31:0] cont;

	assign if_mc_addr = pc; 
	
	always @(posedge clock or negedge reset) begin
		current = pc;
		if(~reset) begin
			pc = 32'd0;
			if_id_nextpc = 32'd0;
			if_id_instruc = 32'd0;
			instruction = 32'd0;
			cont = 32'd0;
		end
		else begin		
			//So faz o que tem que fazer se nao tiver stall
			if(~ex_if_stall) begin				
				//Indica que uma instrucao deve ser lida da memoria
				if_mc_en = 1;
				//Seta o proximo pc
				if(~id_if_selpcsource && cont != 0) begin
					pc = pc + 4; 	

					if_id_instruc = instruction;									
					instruction = mc_if_data;	
					anterior = mc_if_data;

				end else begin					
					case(id_if_selpctype)						
						2'b00: pc = id_if_pcimd2ext;                       
						2'b01: pc = id_if_rega;
						2'b10: pc = id_if_pcindex;
						2'b11: pc = 32'd64;
					endcase		
					//$display("ENTRO NO CASO MORTO");
					if_id_instruc = instruction;									
					instruction = mc_if_data;												
				end
				if_id_nextpc = nextpc_reg;
				nextpc_reg = pc;
			end
			else begin			//CONSERTAR AKI QUARTA	
				if_id_nextpc = pc;
				if_mc_en = 0;
				if_id_instruc = instruction;				
				instruction = anterior;
				anterior = 32'd0;
			end
			if( mc_if_data == 32'd0) begin
				cont = cont + 1;
			end
		end
	end

	
	
endmodule
