`timescale 1ns / 1ps

module uart(
    input clk_uart,                 //7.38 MHz
    input locked_clk_uart,
    input reset,
    input rxd_i,                    //Canal de entrada por donde entran las tramas de la UART
    output txd_o,                   //Canal de salida por donde salen las tramas de la UART
    output canal_selector,
    output [2:0] voltdiv,
    output [2:0] tiempo,
    output pausa,
    output [2:0] tr_level,
    output tr_active
    );

wire [7:0] dato_rx_uart;
    
Uart_rx rx (
    rxd_i,              //Trama recibida por la UART
    reset, 
    locked_clk_uart,    
    clk_uart,           //salida de mi PLL, mi clock principal
    dato_rx_uart,       //Dato procesado en 8 bits para usar en el osciloscopio
    pulso_rx            //Pulso que indica que recibi algo, para usar dentro del modulo
    );

wire [7:0] char_tx;

Uart_tx tx (
    clk_uart,
    locked_clk_uart,
    reset,
    char_tx,       //Byte a transmitir 
    pulso_tx,           //Pulso para enviar el byte
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
    pausa,
    tr_level,
    tr_active    
    ); 
    
mensajes mensajes (
    clk_uart,
    reset,
    locked_clk_uart,
    char_tx,
    pulso_tx
    );
        
endmodule
