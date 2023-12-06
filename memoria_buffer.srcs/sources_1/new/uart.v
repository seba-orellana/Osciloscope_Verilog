`timescale 1ns / 1ps

module uart(
    input clk_uart,                 //7.38 MHz
    input locked_clk_uart,
    input reset,
    input rxd_i,                    //Canal de entrada por donde entran las tramas de la UART
    input pulso_tx,                 //Pulso habilitador para enviar por la UART
    input [7:0] dato_tx_uart,       //Dato a enviar por la UART
    output txd_o,                   //Canal de salida por donde salen las tramas de la UART
    output [7:0] dato_rx_uart,       //Dato recibido de la UART
    output canal_selector,
    output [2:0] voltdiv,
    output pausa
    );
    
Uart_rx rx (
    rxd_i,              //Trama recibida por la UART
    reset, 
    locked_clk_uart,    
    clk_uart,           //salida de mi PLL, mi clock principal
    dato_rx_uart,       //Dato procesado en 8 bits para usar en el osciloscopio
    pulso_rx            //Pulso que indica que recibi algo, para usar dentro del modulo
    );

// UART esta puenteada

Uart_tx tx (
    clk_uart,
    locked_clk_uart,
    reset,
    dato_rx_uart,       //Byte a transmitir 
    pulso_rx,           //Pulso para enviar el byte
    dato_o              //Trama codificada para enviar al transmisor de la UART
    );            

assign txd_o = dato_o;

comandos input_teclado (
    clk_uart,
    reset,
    locked_clk_uart,
    dato_rx_uart,   //Dato que entro de la UART
    pulso_rx,       //Pulso que indica que recibi algo
    canal_selector,
    voltdiv,
    tiempo,
    pausa    
    ); 
    
endmodule
