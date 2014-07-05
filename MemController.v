/**
*Organização de Computadores II - UFMG 2014/1
*Grupo 4 - {Junio Cezar, Gabriel Miranda, Rafael Almeida, Leandro Noman, Pedro Thomas}
*MIPS Pipeline - Simplificado
*/

module MemController (  
  input clock,  
  input reset,  
  //Fetch  
  input  if_mc_en,             //1 = Indica busca de instrucao, quer ler, mem_mc_en tem q ser 0 
  //GABRIEL MUDOU O END ABAIXO PARA 32 BITS, PQ?
  input  [17:0] if_mc_addr,         //END do dado da busca acima  
  output [31:0] mc_if_data,         //DADO LIDO DA RAM E PRA ENVIAR 2 CICLOS PRA LER 
  //Memory  
  input mem_mc_rw,         //INDICA SE HAVERA ESCRITA 
  input mem_mc_en,          //INDICA QUE INST QUER LER UM DADO, TEM PRIORIDADE em cima das INST 
  input [17:0] mem_mc_addr,         //ENDERECO REFERENTE AO DADO 
  inout [31:0] mem_mc_data,         //DADO COMPLETO PARA ENVIO OU RECEBIMENTO 
  //Ram  
  output [17:0] mc_ram_addr,         //ENDERECO da RAM de acesso deve dividir por 2 
  output mc_ram_wre,             //INDICA QUANDO A OP FOR DE ESCRITA, 0 = leitura 
  inout  [15:0] mc_ram_data         //METADE DO DADO LIDO A SER ENVIADO OU RECEBIDO 
); 
  reg estado;
  reg [31:0] data, data2;
  
  assign mc_ram_wre = ((!mem_mc_en && if_mc_en) || !mem_mc_rw || !reset) ? 1'b1 : 1'b0;
  assign mc_ram_addr = (((if_mc_en && !mem_mc_en) ? if_mc_addr : mem_mc_addr)>>1)+estado;                                                     
  assign mc_ram_data = (mem_mc_rw) ? (estado ? mem_mc_data[15:0] : mem_mc_data[31:16]) : 16'hZZZZ;  //SE FOR STORE O VALOR É PEGO AQUI E PASSADO PRA RAM
  assign mem_mc_data = (mem_mc_en && !mem_mc_rw) ? {data[31:16],mc_ram_data[15:0]} : 32'hZZZZZZZZ;  
  assign mc_if_data = data2;

  always@(posedge clock or negedge reset) begin
    
    if (~reset) begin
      estado = 0;
      data = 32'h00000000;
      data2 = 32'h00000000;
    end    
    else begin  
      if (estado == 0 ) begin //Primeiro clock        
        if (mem_mc_en == 1 && mem_mc_rw == 0) begin //SE FOR UMA INST MEMORIA LEITURA BEGIN  ATENCAO NO NOSSO ESCREVE COM 0, ENTAO TEM QUE INVERTER
          data[31:24] = mc_ram_data[15:8];            
          data[23:16] = mc_ram_data[7:0];           
          estado = 1'b1; //recebe a primeira parte dos dados 
        end 
        else if (if_mc_en == 1 && mem_mc_en == 0) begin //SE FOR UMA INST FETCH BEGIN
          data[31:24] = mc_ram_data[15:8];            
          data[23:16] = mc_ram_data[7:0];            
          estado = 1'b1;
        end          
        else if(mem_mc_rw == 1) begin //SE FOR ESCRITA NA MEMORIA BEGIN            
            //FEITO POR ASSIGN
            estado = 1'b1;
        end
      end 
      else begin //Segundo clock
          if (mem_mc_en == 1 && mem_mc_rw == 0) begin //SE FOR UMA INST MEMORIA LEITURA BEGIN SEGUNDA PARTE
            data[15:8] = mc_ram_data[15:8];            
            data[7:0] = mc_ram_data[7:0]; 
            estado = 1'b0;
          end
          if (if_mc_en == 1 && mem_mc_en == 0) begin //SE FOR UMA INST FETCH BEGIN SEGUNDA PARTE        
            data2 = {data[31:16],mc_ram_data[15:0]};
            estado = 1'b0;
          end
          else if(mem_mc_rw == 1) begin //SE FOR ESCRITA NA MEMORIA BEGIN SEGUNDA PARTE
            //FEITO POR ASSIGN
            estado = 1'b0;       
          end          
      end        
    end
  end 
endmodule

