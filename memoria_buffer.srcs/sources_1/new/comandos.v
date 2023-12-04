`timescale 1ns / 1ps

module comandos(
    input clk_64,
    input reset,
    input locked,
    input [7:0] dato_recibido,  //Dato que entro de la UART
    input pulso_rx,             //Pulso que indica que recibi algo
    output reg canal,
    output reg [3:0] voltdiv,
    output reg [31:0] tiempo,
    output [7:0] char,
    output pulso_tx
    );

always @(posedge clk_64) begin
    if (~locked || reset) begin
        canal <= 0;
        voltdiv <= 8;
        tiempo <= 2;
    end
    else begin
        if (pulso_rx) begin
            case (dato_recibido)    
                8'h43, 8'h63 : //C
                    canal <= ~canal;
                8'h77, 8'h57 : //W
                    voltdiv <= (voltdiv > 10)? 10 : voltdiv + 1;
                8'h53, 8'h73 : //M
                    voltdiv <= (voltdiv == 0)? 0 : voltdiv - 1;
                8'h41, 8'h61 : //A
                    tiempo <= (tiempo == 0)? 0 : tiempo - 1;
                8'h44, 8'h64 : //M
                    tiempo <= (tiempo > 5)? 5 : tiempo + 1;        
                default: begin end
            endcase    
        end
    end
end

assign char = (pulso_rx)? dato_recibido : 0;
assign pulso_tx = pulso_rx;
                
endmodule    