`timescale 1ns / 1ps

module vga (
        input clk,
        input reset,
        input locked,
        input [9:0] mem_ram,
        output [9:0] address_ram,
        output hs,
        output vs,
        output [3:0] r,
        output [3:0] g,
        output [3:0] b
    );

//800x600 60hz

///////////////////////////////////////////////
//////////////  Parametros  ///////////////////
///////////////////////////////////////////////

//TOTAL_H
//Cantidad total de pulsos de clock en horizontal
//ACTIVE + FP + BP + PW
//  800  + 40 + 88 + 128 
localparam TOTAL_H = 1056;

//TOTAL_V
//Cantidad total de pulsos de clock en vertical
//ACTIVE + FP + BP + PW
//  600  + 1  + 23 +  4 
localparam TOTAL_V = 628;

//ACTIVE_H
localparam ACTIVE_H = 800;

//ACTIVE_V
localparam ACTIVE_V = 600;

//H_PULSO
//A partir de donde debo enviar el pulso horizontal en bajo
//ACTIVE + FP + BP
//  800  + 40 + 88
localparam H_PULSO = 928;

//V_PULSO
//A partir de donde debo enviar el pulso vertical en bajo
//ACTIVE + FP + BP
//  600  + 1  + 23 
localparam V_PULSO = 624;
 
reg [10:0] h_cont;
reg [9:0] v_cont;
reg [9:0] h_active;
 
//Indica si estoy dentro de la parte ACTIVE (Para poder colorear la pantalla) 
reg in_active;

reg [3:0] r_a;
reg [3:0] g_a;
reg [3:0] b_a;

reg [9:0] val_anterior;
 
//Contadores para ir colocando los colores en la pantalla
//Una vez terminada la cuenta horizontal, empiezo con la cuenta vertical
always @(posedge clk) begin
    if (reset || ~locked) begin
        h_cont <= 0;
        v_cont <= 0;
        h_active <=0;
    end else begin
        if (h_cont < TOTAL_H - 1)begin 
            h_cont <= h_cont + 1;
            h_active <= ( h_cont>= 88 &&  h_cont< 888)? h_active + 1 : 0;
            end
        else begin
            h_cont <= 0;
            if (v_cont < TOTAL_V - 1)
                v_cont <= v_cont + 1;
            else
                v_cont <= 0;
        end  
    end
end

assign vs = (v_cont < V_PULSO)? 1 : 0;
assign hs = (h_cont < H_PULSO)? 1 : 0;

//Centrar la imagen (Sumas los BP):
//BPh = 88
//BPv = 23

/*
<----BP----><------------------ACTIVE---------------------><----FP---->
                                                                       <----PW---->

https://web.mit.edu/6.111/www/s2004/NEWKIT/vga.shtml                                                                    
*/

//Definimos la parte activa para pintar la pantalla
always @(posedge clk) begin
    if (reset || ~locked) begin
        in_active <= 0;
    end else begin
        if ((h_cont < ACTIVE_H + 88) && (v_cont < ACTIVE_V + 23) &&
            (h_cont >= 88) && (v_cont >= 23))
            in_active <= 1;
        else 
            in_active <= 0;
    end
end

always @(posedge clk) begin
    if (reset || ~locked) begin
        r_a <= 0;
        g_a <= 0;
        b_a <= 0;
        val_anterior <= 0;
    end else begin
        if (in_active) begin
        //Segun el orden de los Case, primero se pinta horizontal y despues se pinta encima el vertical
        //Pintar el fondo fuera de la grilla vertical
            if (v_cont >= 67 && v_cont <= 580) begin
                case (h_cont)
                    168,248,328,408,488,568,648,728,808: begin   //Cada 80 pixeles, una linea de la grilla
                            r_a <= 4'hF;                         //Sumar 88 para centrarla en la pantalla
                            g_a <= 4'hF;
                            b_a <= 4'hF;               
                        end
                        //Pinta el fondo gris
                        default : begin
                            r_a <= 4'h9;
                            g_a <= 4'h9;
                            b_a <= 4'h9;
                        end
                endcase
            end
            else begin      //Margenes fuera de la grilla vertical
                r_a <= 4'h9;
                g_a <= 4'h9;
                b_a <= 4'h9;                
            end    
            case (v_cont)                      
                //Grilla vertical
                //Centrada en 300, 256 pixeles hacia arriba y hacia abajo
                //Los 88 pixeles sobrantes (44 arriba y abajo) son para escribir informacion en pantalla
                //Sumar 23 del BP
                67,118,169,220,271,323,374,425,476,528,580: begin                
                    r_a <= 4'hF;
                    g_a <= 4'hF;
                    b_a <= 4'hF;
                end              
                //No hacer nada si no cae en el case, porque si no re-pintamos y borramos lo anterior 
                default : begin end
            endcase
            
/////////////////////////////////////////////////////////////////////////////////
///////////////////     Graficar resultados desde la memoria    /////////////////
/////////////////////////////////////////////////////////////////////////////////

//Ajuste de los puntos (Mantener linealidad de la funcion a graficar en la pantalla)

            if (mem_ram < val_anterior) begin
                if ((v_cont >= mem_ram) && (v_cont < val_anterior)) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
            end
            else if (mem_ram >= val_anterior) begin
                if ((v_cont >= val_anterior) && (v_cont <= mem_ram)) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
            end
            
        //actualizo el valor anterior para el proximo pixel        
        val_anterior <= mem_ram;
        end  //(end if(in_active))                   
        //Si no estamos dentro de la parte ACTIVE, no enviar colores   
        else begin 
            r_a <= 4'h0;
            g_a <= 4'h0;
            b_a <= 4'h0;
        end    
    end     //end if(reset || ~locked) 
end    

assign address_ram = h_active;

assign r = r_a;
assign g = g_a;
assign b = b_a;
        
endmodule