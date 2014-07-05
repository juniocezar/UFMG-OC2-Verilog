/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module Decode (
	input clock, 
 	input reset, 
	//Fetch 
	input [31:0] if_id_instruc, /*Contém o valor da instrução recebida do estágio de busca de instruções. Os bits entre 31 e 26, 
inclusive, devem ser conectados na porta op do módulo de controle e os bits entre 5 e 0, inclusive, devem ser conectados na porta fn do módulo de controle */
	input [31:0] if_id_nextpc, //Valor de nextpc recebido do estágio de busca de instruções 
	output id_if_selpcsource, //Recebe a saída do comparador caso selbrjumpz (saida do módulo de controle) seja 2’b10, 1 caso selbrjumpz seja 2’b01 e 0 caso contrário
	output [31:0] id_if_rega, //Recebe o valor de reg_id_ass_dataa 
	output [31:0] id_if_pcimd2ext, //Recebe if_id_nextpc + {{16{if_id_instruc[15]}},if_id_instruc[15:0]}<<2'b10
	output [31:0] id_if_pcindex, //Recebe {if_id_nextpc[31:28],if_id_instruc[25:0]<<2'b10}
	output [1:0] id_if_selpctype, //Recebe o valor da saida selpctype do módulo de controle 

	//Execute 
	output reg id_ex_selalushift, //Recebe o valor da saida selalushift do módulo de controle 
	output reg id_ex_selimregb, //Recebe o valor da saida selimregb do módulo de controle 
	output reg [2:0] id_ex_aluop, //Recebe o valor da saida aluop do módulo de controle 
	output reg id_ex_unsig, //Recebe o valor da saida unsig do módulo de controle 
	output reg [1:0] id_ex_shiftop, //Recebe o valor da saida shiftop do módulo de controle 
	output [4:0] id_ex_shiftamt, //Recebe o valor de reg_id_dataa 
	output [31:0] id_ex_rega, // Recebe o valor de reg_id_dataa 
	output reg id_ex_readmem, //Recebe o valor da saida readmem do módulo de controle
	output reg id_ex_writemem, //Recebe o valor da saida writemem do módulo de controle
	output [31:0] id_ex_regb, //Recebe o valor de reg_id_datab 
	output reg [31:0] id_ex_imedext, //Recebe o valor de if_id_instruc[15:0] e estende para 32 bits conservando o sinal
	output reg id_ex_selwsource, //Recebe o valor da saida selwsource do módulo de controle caso ele tenha sido modificado como descrito abaixo, ou apenas selwsource[0] 
	output reg [4:0] id_ex_regdest,/*Recebe if_id_instruc[15:11] quando selregdest é 1 e if_id_instruc[20:16] quando selregdest 0. Caso o 
controle não tenha sido modificado, como descrito abaixo, a mesma seleção deve ser feita mas considerando-se apenas selregdest[0] */ 
	output reg id_ex_writereg, //Recebe o valor da saida writereg do módulo de controle
	output reg id_ex_writeov, //Recebe o valor da saida writeov do módulo de controle
	
	//Registers 
	output [4:0] id_reg_addra, // Recebe if_id_instruc[25:21] 
	output [4:0] id_reg_addrb, //Recebe if_id_instruc[20:16] 
	input [31:0] reg_id_dataa,  // Valor lido de forma síncrona do banco de registradores na posição especificada por id_reg_addra 
	input [31:0] reg_id_datab, //Valor lido de forma síncrona do banco de registradores na posição especificada por id_reg_addrb 
	input [31:0] reg_id_ass_dataa, /*Valor lido de forma assíncrona do banco de registradores na posição especificada por 
id_reg_addra. Deve ser conectado na porta a do comparado*/
	input [31:0] reg_id_ass_datab /*Valor lido de forma assíncrona do banco de registradores na posição especificada por 
id_reg_addrb. Deve ser conectado na porta b do comparador*/
);


	reg reg_id_if_selpcsource;
	reg [31:0] reg_id_if_rega;
	reg [31:0] reg_id_if_pcimd2ext;
	reg [31:0] reg_id_if_pcindex; 
	reg [1:0] reg_id_if_selpctype;
	//Execute 
	reg [4:0] reg_id_ex_shiftamt; 
	reg [31:0] reg_id_ex_rega; 
	reg [31:0] reg_id_ex_regb; 
	wire [31:0] imediato;
	//Registers 
	reg [4:0] reg_id_reg_addra;
	reg [4:0] reg_id_reg_addrb;

	assign id_if_selpcsource = reg_id_if_selpcsource;
		
	/* MUDEI PRA TENTAR RESOLVER O PC ERRADO DOS JR SEGUIDOS */
	assign id_if_rega = reg_id_ass_dataa; //reg_id_if_rega;
	
	
	
	assign id_if_pcimd2ext = reg_id_if_pcimd2ext;
	assign id_if_pcindex = reg_id_if_pcindex; 
	assign id_if_selpctype = reg_id_if_selpctype;
	//Execute 
	assign id_ex_shiftamt = reg_id_ex_shiftamt; 
	assign id_ex_rega = reg_id_ex_rega; 
	assign id_ex_regb = reg_id_ex_regb; 
	//Registers 
	assign id_reg_addra = reg_id_reg_addra;
	assign id_reg_addrb = reg_id_reg_addrb;
	assign imediato = {{16{if_id_instruc[15]}}, if_id_instruc[15:0]};


	
	// ========= wires do Comparador ========== // 
 	wire [2:0] op_comparator;
 	wire [31:0] b, a;
 	wire compout;

 	// ========== wires do Controle =========== // 
	wire [5:0] op_control, fn;
	wire writereg, writeov, selimregb, selalushift, readmem, writemem, using;
	wire [1:0] selregdest, shiftop, selbrjumpz, selpctype;
	wire [2:0] compop, aluop, selwsource;

	Comparator COMPARATOR(a, b, op_comparator, compout); //a recebe reg_id_dataa e b recebe reg_iddatab

	// ============ Assinalamentos do Controle ======================== 
		assign op_control = if_id_instruc [31:26];
		assign fn = if_id_instruc [5:0];
	// ================================================================

	Control CONTROL(
		op_control,
		fn,
		selwsource,
		selregdest,
		writereg,
		writeov,
		selimregb,
		selalushift,
		aluop,
		shiftop,
		readmem,
		writemem,
		selbrjumpz,
		selpctype, //seltipopc
		compop,
		unsig
	); 
	

	// ============ Assinalamentos do Comparador ======================
		assign op_comparator = compop; 
		assign a = reg_id_dataa;
	    assign b = reg_id_datab;
	// ================================================================

	reg atraso;

	// ============== Registradores de atraso =====================//

	reg [31:0] atraso_id_ex_imedext;
	reg [2:0]  atraso_aluop;
	reg [4:0] atraso_id_ex_regdest;
	reg atraso_writemem;
	reg atraso_writereg;
	reg [1:0] atraso_selregdest;
	reg atraso_writeov;
	reg atraso_selwsource;

	reg atraso_selalushift;
	reg atraso_selimregb;
	reg atraso_unsig;
	reg [1:0] atraso_shiftop;
	reg [31:0] atraso_reg_id_dataa;
	reg [4:0] A;
	reg [4:0] B;

	//  ===================== ===================== ===============//


	always @(clock or reset) begin
	if(~reset)begin
		id_ex_selalushift = 0; 
		id_ex_selimregb = 0; 
		id_ex_aluop = 3'b000; 
		id_ex_unsig = 0; 
		id_ex_shiftop  = 2'b00; 
		reg_id_ex_shiftamt = 4'b0000; //ERA OUTPUT E NAO OUTPUT REG
		reg_id_ex_rega  = 32'h0000_0000;  //ERA OUTPUT E NAO OUTPUT REG
		id_ex_readmem = 0; 
		id_ex_writemem = 0; 
		reg_id_ex_regb  = 32'h0000_0000;  //ERA OUTPUT E NAO OUTPUT REG 
		id_ex_imedext  = 32'h0000_0000; 
		id_ex_selwsource = 0; 
		id_ex_regdest = 5'b00000; 
		id_ex_writereg = 0; 
		id_ex_writeov = 0; 		
		reg_id_if_selpcsource = 0;
		atraso = 0;
		//Registradores de atrasos
		atraso_id_ex_imedext = 32'd0;
		atraso_aluop = 3'd0;
		atraso_id_ex_regdest = 5'd0;
		atraso_writemem = 1'd0;
		atraso_writereg = 1'd0;
		atraso_selregdest = 2'd0;
		atraso_writeov  = 1'd0;
		atraso_selwsource = 1'd0;
		atraso_selalushift = 1'd0;
		atraso_selimregb = 1'd0;
		atraso_unsig = 1'd0;
		atraso_shiftop = 2'd0;
		atraso_reg_id_dataa = 32'd0;			
		A = 5'd0;
		B = 5'd0;
	end
	else begin	
		case(selbrjumpz) //DEVE IR PRA UM BLOCO ALWAYS
			2'b10 : reg_id_if_selpcsource = compout;
			2'b01 : reg_id_if_selpcsource = 1;
			default : reg_id_if_selpcsource = 0;
		endcase
		
		reg_id_if_rega = reg_id_ass_dataa;
		reg_id_if_pcimd2ext = ({{16{if_id_instruc[15]}},if_id_instruc[15:0]}<<2) + if_id_nextpc;
		reg_id_if_pcindex = {6'b000000,if_id_instruc[25:0]}; // SEM MULTIPLICACAO DESSA VEZ
		reg_id_if_selpctype = selpctype;
	

	// ================================== ASSINALAMENTOS DO REGISTER ====================================

		reg_id_reg_addra = A;
		reg_id_reg_addrb = B;

		A = if_id_instruc[25:21];
		B = if_id_instruc[20:16];
	//==================================================================================================

	// =================== ASSINALAMENTOS DO EXECUTE COM SISTEMA DE ATRASO =============================
		id_ex_selalushift = atraso_selalushift; 
		atraso_selalushift = selalushift;

		id_ex_selimregb = atraso_selimregb;
		atraso_selimregb = selimregb;
		
		id_ex_unsig = atraso_unsig;
		atraso_unsig = unsig;

		id_ex_shiftop = atraso_shiftop;
		atraso_unsig = shiftop;

		reg_id_ex_shiftamt = atraso_reg_id_dataa;
		atraso_reg_id_dataa = reg_id_dataa;

		reg_id_ex_rega = reg_id_dataa;		
		reg_id_ex_regb = reg_id_datab;
		
		id_ex_readmem = readmem;		
		id_ex_writemem = writemem;		

		id_ex_aluop = atraso_aluop;
		atraso_aluop = aluop;
		id_ex_selwsource = atraso_selwsource;
		atraso_selwsource = selwsource[0];
		id_ex_regdest = atraso_id_ex_regdest;
		case(selregdest[0]) //DEVE IR A UM BLOCO
			1'b1: atraso_id_ex_regdest = !clock? if_id_instruc[15:11] : atraso_id_ex_regdest;
			1'b0: atraso_id_ex_regdest = !clock? if_id_instruc[20:16] : atraso_id_ex_regdest;
		endcase
		id_ex_writereg = atraso_writereg;
		atraso_writereg = writereg;
		id_ex_imedext = atraso_id_ex_imedext; //atraso
		atraso_id_ex_imedext =  imediato;  //CHECAR SE A EXTENSAO DE SINAL ESTA CORRETA		
		id_ex_writeov = atraso_writeov;
		atraso_writeov = writeov;
	//==================================================================================================
	end
	//=================================================================================================

end
 
endmodule
