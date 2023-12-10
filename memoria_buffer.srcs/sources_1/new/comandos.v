`timescale 1ns / 1ps

module comandos(
    input clk_64,
    input reset,
    input locked,
    input [7:0] dato_recibido,  //Dato que entro de la UART
    input pulso_rx,             //Pulso que indica que recibi algo
    output reg canal,
    output reg [2:0] voltdiv,
    output reg [2:0] tiempo,
    output reg pausa
    );

always @(posedge clk_64) begin
    if (~locked || reset) begin
        //canal 0 -> CH2
        //canal 1 -> CH1
        canal <= 1;
        voltdiv <= 0;
        //tiempo <= 2;
        pausa <= 1;
        tiempo <= 7;
    end
    else begin
        if (pulso_rx) begin
            case (dato_recibido)    
                8'h43, 8'h63 : //C
                    canal <= ~canal;
                8'h77, 8'h57 : //W
                    voltdiv <= (voltdiv == 7)? 7 : voltdiv + 1;
                8'h53, 8'h73 : //S
                    voltdiv <= (voltdiv == 0)? 0 : voltdiv - 1;
                8'h41, 8'h61 : //A
                    tiempo <= (tiempo == 0)? 0 : tiempo - 1;
                8'h44, 8'h64 : //D
                    tiempo <= (tiempo == 7)? 7 : tiempo + 1;
                8'h50, 8'h70 : //P
                    pausa <= ~pausa;            
                default: begin end
            endcase    
        end
    end
end
                
endmodule      