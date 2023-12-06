`timescale 1ns / 1ps

module adc(
    input clk,
    input reset,
    input locked,
    input vauxp6,            // input wire vauxp6
    input vauxn6,            // input wire vauxn6
    input vauxp14,          // input wire vauxp14
    input vauxn14,  
    output [15:0] dato_canal_1,
    //output reg [15:0] dato_canal_2,
    output [11:0] address
    );

reg [11:0] cont;
reg [6:0] dir_mem;

wire ready;

always @(posedge clk) begin
    if (reset | ~locked) begin
        cont <= 0;
    end
    else begin
        if (ready) begin
            cont <= (cont == 4000)? 0 : cont + 1;
        end
    end    
end

wire eoc;  
wire [15:0] data;   

adc_vauxp6_14 adc_canal_6_14 (
  .di_in(0),                              // input wire [15 : 0] di_in
  .daddr_in(8'h16),                        // input wire [6 : 0] daddr_in
  .den_in(eoc),                            // input wire den_in
  .dwe_in(0),                            // input wire dwe_in
  .drdy_out(ready),                        // output wire drdy_out
  .do_out(dato_canal_1),                            // output wire [15 : 0] do_out
  .dclk_in(clk),                          // input wire dclk_in
  .reset_in(reset | ~locked),             // input wire reset_in
  .vp_in(0),                              // input wire vp_in
  .vn_in(0),                              // input wire vn_in
  .vauxp6(vauxp6),                            // input wire vauxp6
  .vauxn6(vauxn6),                            // input wire vauxn6
  .vauxp14(vauxp14),                          // input wire vauxp14
  .vauxn14(vauxn14),                          // input wire vauxn14
  .channel_out(channel),                  // output wire [4 : 0] channel_out
  .eoc_out(eoc),                          // output wire eoc_out
  .alarm_out(),                      // output wire alarm_out
  .eos_out(eos),                          // output wire eos_out
  .busy_out()                        // output wire busy_out
); 

assign address = cont;
    
endmodule
