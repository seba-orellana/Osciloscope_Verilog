`timescale 1ns / 1ps

module adaptador(
    input clk,
    input reset,
    input locked,
    //input amp,
    //input tiempo,
    input [15:0] dato_entrada,  //Del ADC 1 salen 16 bits, solo me interesan los 12 MSB
    input [15:0] dato_entrada_2,  //Del ADC 2 salen 16 bits, solo me interesan los 12 MSB
    input canal_selector, 
    output [11:0] dir_entrada,
    output reg [8:0] dato_salida,
    output [9:0] dir_salida
    );

reg [11:0] cont;
reg [15:0] dato_aux_16;
reg [9:0] cont_salida;

always @(posedge clk) begin
    if (reset || ~locked) begin
        dato_aux_16 <= 0;
        cont <= 0;
        cont_salida <= 0;
        dato_salida <= 0;       
    end
    else begin
            cont <= (cont != 3995)? cont + 5 : 0; //cont <= (cont != 3999)? cont + (5*tiempo): 0;
            cont_salida <= (cont_salida != 799)? cont_salida + 1 : 0;
            //Se escoge con cual de los dos canales nos quedamos en pantalla:
            dato_aux_16 <= (canal_selector)? dato_entrada : dato_entrada_2;
            dato_salida <= dato_aux_16[15:7];
    end    
end
    
assign dir_entrada = cont;  
assign dir_salida = cont_salida;
    
endmodule

