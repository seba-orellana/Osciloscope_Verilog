`timescale 1ns / 1ps

module memoria_toplevel(
    input clk_in1,
    input reset,
    output hs,
    output vs,
    input rxd_i,
    output [3:0] r,
    output [3:0] g,
    output [3:0] b,
    output txd_o    
    );

wire [8:0] mem_ram_vga;
wire [8:0] address_ram_vga;

wire [8:0] dir_salida_9b;
wire [8:0] dato_salida_9b;

wire [15:0] salida_mem_adc;
wire [11:0] dir_salida_mem_adc;

clk_sys_vga clk_100_40
   (
    // Clock out ports
    .clk_100(clk_100),     // output clk_100
    .clk_vga(clk_vga),     // output clk_vga
    // Status and control signals
    .reset(reset), // input reset
    .locked0(locked0),       // output locked0
   // Clock in ports
    .clk_in1(clk_in1)      // input clk_in1
);
    
clk_wiz_1 clock_adc_uart
   (
    // Clock out ports
    .clk_uart(clk_uart),     // output clk_uart
    .clk_adc(clk_adc),     // output clk_adc
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked2),       // output locked
   // Clock in ports
    .clk_in1(clk_100)      // input clk_in1
);    

wire locked;     
assign locked = (locked0 & locked2);    
    
blk_mem_adc16b ram_adc (
  .clka(clk_adc),    // input wire clka
  .wea(wea1),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] direccion de entrada (ADC)
  .dina(dina),    // input wire [15 : 0] dato a escribir (ADC)
  .clkb(clk_adc),    // input wire clkb
  .addrb(dir_salida_mem_adc),  // input wire [11 : 0] direccion de salida
  .doutb(salida_mem_adc)  // output wire [15 : 0] dato de salida
);   

blk_mem_VGA ram_vga (
  .clka(clk_adc),    // input wire clock de escritura
  .wea(wea),      // input wire [0 : 0] wea
  .addra(dir_salida_9b),  // input wire [8 : 0] Direccion de entrada (Adaptador) 
  .dina(dato_salida_9b),    // input wire [8 : 0] Dato a escribir (Adaptador)
  .clkb(clk_vga),    // input wire clock de lectura (igual al VGA)
  .addrb(ram_address),  // input wire [8 : 0] direccion a leer para el pixel de VGA
  .doutb(mem_ram)  // output wire [8 : 0] dato a pintar en la pantalla
); 

/*
rom_seno seno (
  .clka(clk_vga),    // input wire clka
  .addra(address_ram),  // input wire [9 : 0] addra
  .douta(mem_ram)  // output wire [9 : 0] douta
);*/

//////////////////////////////////////////////////
/////////////////       VGA         //////////////
//////////////////////////////////////////////////

vga vga_monitor (
        clk_vga,
        reset,
        locked,
        mem_ram_vga,
        ram_address_vga,
        hs,
        vs,
        r,
        g,
        b
    );

assign wea = 1;

//////////////////////////////////////////////////////
/////////////////       UART        //////////////////
//////////////////////////////////////////////////////

wire [7:0] dato_tx_uart;
wire [7:0] dato_rx_uart;

uart modulo_uart (
        clk_uart,           //7.38 MHz
        locked,
        rxd_i,              //Canal de entrada por donde entran las tramas de la UART
        pulso_tx,           //Pulso habilitador para enviar por la UART
        dato_tx_uart,       //Dato a enviar por la UART
        txd_o,              //Canal de salida por donde salen las tramas de la UART
        dato_rx_uart
        );      

////////////////////////////////////////////////////////
//////////         ADAPTADOR DE SEÑAL       ////////////
////////////////////////////////////////////////////////

adaptador adaptador(
    clk_adc,
    reset,
    locked,
    //amp,
    //tiempo,
    salida_mem_adc,      //Del ADC salen 16 bits de dato
    dir_salida_mem_adc,      //Direccion para leer de la memoria del ADC
    dato_salida_9b,     //A enviar a la ram del ADC
    dir_salida_9b       //Direccion del dato para escribir en la RAM de ADC
    );
    
endmodule
