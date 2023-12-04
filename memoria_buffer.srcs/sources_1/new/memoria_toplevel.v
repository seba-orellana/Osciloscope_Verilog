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

//La direccion para leer se puede compartir, es el mismo contador
//Dentro de adaptador se escoge con cual de los ADC se trabaja
wire [11:0] dir_salida_mem_adc;

wire [15:0] salida_mem_adc;
wire [15:0] salida_mem_adc_2;
    
blk_mem_adc16b ram_adc (
  .clka(clk_adc),    // input wire clka
  .wea(wea1),      // input wire [0 : 0] wea
  .addra(),  // input wire [11 : 0] direccion de entrada (ADC)
  .dina(),    // input wire [15 : 0] dato a escribir (ADC)
  .clkb(clk_adc),    // input wire clkb
  .addrb(dir_salida_mem_adc),  // input wire [11 : 0] direccion de salida
  .doutb(salida_mem_adc)  // output wire [15 : 0] dato de salida
);

ram_adc_2 canal_adc_2 (
  .clka(clk_adc),    // input wire clka
  .wea(wea1),      // input wire [0 : 0] wea
  .addra(),  // input wire [11 : 0] direccion de entrada (ADC)
  .dina(),    // input wire [15 : 0] dato a escribir (ADC)
  .clkb(clk_adc),    // input wire clkb
  .addrb(dir_salida_mem_adc),  // input wire [11 : 0] direccion de salida
  .doutb(salida_mem_adc_2)  // output wire [15 : 0] dato de salida
);

//////////////////////////////////////////////////
/////////////////       VGA         //////////////
//////////////////////////////////////////////////

wire [8:0] dato_salida_a_vga;
wire [9:0] dir_salida_a_vga;

wire [9:0] ram_address_vga;
wire [8:0] mem_ram_vga;

blk_mem_VGA ram_vga (
  .clka(clk_adc),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(dir_salida_a_vga),  // input wire [9 : 0] direccion para escribir desde adaptador
  .dina(dato_salida_a_vga),    // input wire [8 : 0] dato a escribir desde adaptado
  .clkb(clk_vga),    // input wire clkb
  .addrb(ram_address_vga),  // input wire [9 : 0] direccion para leer desde VGA
  .doutb(mem_ram_vga)  // output wire [8 : 0] dato para enviar a VGA
);

vga vga_monitor (
        clk_vga,
        reset,
        locked,
        mem_ram_vga,        //[8:0]
        canal_selector,
        ram_address_vga,    //[9:0]
        hs,
        vs,
        r,
        g,
        b
    );

assign wea = 1;
assign wea1 = 0;

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
        dato_rx_uart,
        canal_selector
        );      

////////////////////////////////////////////////////////
//////////         ADAPTADOR DE SE�AL       ////////////
////////////////////////////////////////////////////////

adaptador adaptador(
    clk_adc,
    reset,
    locked,
    //amp,
    //tiempo,
    salida_mem_adc,      // [15:0] input dato que ingresa de la memoria del ADC
    salida_mem_adc_2,      // [15:0] input dato que ingresa de la memoria del ADC
    canal_selector,         // input
    dir_salida_mem_adc,      // [11:0] output Direccion para leer de la memoria del ADC
    dato_salida_a_vga,     // [8:0] output A enviar a la ram del VGA
    dir_salida_a_vga       // [9:0] output Direccion del dato para escribir en la RAM de VGA (0-800)
    );
    
endmodule
