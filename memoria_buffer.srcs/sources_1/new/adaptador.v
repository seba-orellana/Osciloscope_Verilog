`timescale 1ns / 1ps

module adaptador(
    input clk,
    input reset,
    input locked,
    //input amp,
    //input tiempo,
    input [15:0] dato_entrada,  //Del ADC salen 16 bits, solo me interesan los 12 MSB
    output reg [15:0] dir_entrada,
    output reg [9:0] dato_salida,
    output reg [9:0] dir_salida 
    );

reg [11:0] cont;
reg [15:0] dato_aux_16;
reg [10:0] cont_salida;

always @(posedge clk) begin
    if (reset || ~locked) begin
        dato_aux_16 <= 0;
    end
    else begin
        cont <= (cont >= 4000)? cont + 5: 0; //cont <= (cont != 3999)? cont + (5*tiempo): 0;
        cont_salida <= (cont_salida != 799)? cont_salida + 1: 0;
        dir_entrada <= cont;
        dato_aux_16 <= dato_entrada;
        dato_salida <= dato_aux_16[15:7];
        dir_salida <= cont_salida;
    end    
end   
    
endmodule

