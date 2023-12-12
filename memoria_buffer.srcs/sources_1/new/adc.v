`timescale 1ns / 1ps

module adc(
    input clk,
    input reset,
    input locked,
    input vauxp6,            // input wire vauxp6
    input vauxn6,            // input wire vauxn6
    input vauxp14,          // input wire vauxp14
    input vauxn14,  
    input canal_selector,
    input [2:0] tr_level,
    input tr_active,
    output reg [15:0] dato_canal_1,
    //output reg [15:0] dato_canal_2,
    output reg [11:0] address
    );

reg [11:0] cont;
reg [6:0] canal;
wire ready;
wire [15:0] dato_adc;
reg [15:0] val_anterior;
reg flag_enable;
reg flag_start;
reg [15:0] val_tr;

always @(posedge clk) begin
    if (reset | ~locked) begin
        cont <= 0;
        canal <= 0;
        address <= 0;
        flag_enable <= 1;
        flag_start <= 1;
        val_tr <= 32768;
    end
    else begin
        canal <= (canal_selector)? 8'h16 : 8'h1e;
        case (tr_level)
            0: val_tr <= 75;         // Trigger (casi) sobre 0V
            1: val_tr <= 16384;     //  1/4 de grilla
            2: val_tr <= 32768;     //  2/4 de grilla
            3: val_tr <= 49152;     //  3/4 de grilla
            4: val_tr <= 65460;     // Triger (casi) sobre 1V
        endcase
        if (ready) begin
            if (tr_active) begin
                if (flag_start) begin            
                    val_anterior <= dato_adc;
                    flag_start <= 0;
                end else begin    
                    if (val_anterior < val_tr && dato_adc >= val_tr)
                        flag_enable <= 0;
                    if (flag_enable == 0) begin    
                        address <= (address == 4000)? 0 : address + 1;
                        dato_canal_1 <= dato_adc;
                        flag_enable <= (address == 4000)? 1 : 0;
                    end
                    val_anterior <= dato_adc;
                end
            end else begin
                dato_canal_1 <= dato_adc;
                address <= (address == 4000)? 0 : address + 1;
            end                
        end
    end    
end

assign tr_enable = (~flag_enable)? 1 : 0;

wire eoc;    

adc_vauxp6_14 adc_canal_6_14 (
  .di_in(0),                              // input wire [15 : 0] di_in
  .daddr_in(canal),                        // input wire [6 : 0] daddr_in
  .den_in(eoc),                            // input wire den_in
  .dwe_in(0),                            // input wire dwe_in
  .drdy_out(ready),                        // output wire drdy_out
  .do_out(dato_adc),                            // output wire [15 : 0] do_out
  .dclk_in(clk),                          // input wire dclk_in
  .reset_in(reset | ~locked),             // input wire reset_in
  .vp_in(0),                              // input wire vp_in
  .vn_in(0),                              // input wire vn_in
  .vauxp6(vauxp6),                            // input wire vauxp6
  .vauxn6(vauxn6),                            // input wire vauxn6
  .vauxp14(vauxp14),                          // input wire vauxp14
  .vauxn14(vauxn14),                          // input wire vauxn14
  .channel_out(),                  // output wire [4 : 0] channel_out
  .eoc_out(eoc),                          // output wire eoc_out
  .alarm_out(),                      // output wire alarm_out
  .eos_out(eos),                          // output wire eos_out
  .busy_out()                        // output wire busy_out
); 

endmodule
