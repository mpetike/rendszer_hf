`timescale 1ns / 1ps


module DDS_top( //Reset,clock
                input clk,
                input rst,
                //Controll
                input [23:0] cntrl_word,
                
                //DEBUG
                output [23:0] nco_out,
                output [23:0] sin_out,
                output [23:0] tri_out
    );

    //NCO    
    reg [23:0] nco_cnt = 0;
    
    always @ (posedge clk)
    begin
        if(rst)
            nco_cnt <= 0;
        else
            begin
                nco_cnt <= nco_cnt + cntrl_word;
            end
    end    
    
    
    //LFSR 

    //Dither
    //TODO
    wire [23:0] dith_out = nco_cnt;
    
    
    //SIN gen
    //Használt regiszterek,összeköttetések
    wire [1:0] quad_sel = dith_out[23:22];  //A negyed meghatározására az NCO felsõ 2 bitjét használjuk
    reg quad_sel_z1;
    reg [9:0] LUT_address;    
    wire [22:0] sin_lut_out;
    reg signed [23:0] sin_signal = 0;
   
    //LUT be és kimenetének manipulálása
    always @ (posedge clk)
    begin
        //LUT kimenete 1 órajellel késleltetve van
        quad_sel_z1 <= quad_sel[1];
        
        //Címbemenet kezelése
        if(quad_sel[0]) //2. és 4. negyed
            begin
                LUT_address <= 10'h3FF - dith_out[21:12];
            end
        else    //1. és  3. negyed
            begin
                LUT_address <= dith_out[21:12];
            end
        //LUT kimenet mûveletei
        if(quad_sel_z1)     // 2. és 3. negyed
            begin
                sin_signal <= 0 - sin_lut_out;
            end
        else    //1. és 2. negyed
            begin
                sin_signal <= sin_lut_out;
            end
            
    end    
        //LUT példányosítása
    SIN_LUT singen( .clk(clk),
                    .address(LUT_address),
                    .sin_out(sin_lut_out));
    //COMP (SQR Wave)
    
    //TRI Wave
    reg signed [23:0] triangle_out = 0;
    wire [23:0] nco_tri_in = nco_cnt;
    
    always @ (posedge clk)
    begin
        case(nco_tri_in[23:22])
            2'b00 : triangle_out[23:1] <= nco_tri_in;
            2'b01 : triangle_out[23:1] <= 24'h800000 - nco_tri_in;
            2'b10 : triangle_out[23:1] <= 24'h800000 - nco_tri_in;
            2'b11 : triangle_out[23:1] <= nco_tri_in;
        endcase

    end
    
    //Debug connections
    assign nco_out = nco_cnt;    
    assign sin_out = sin_signal;
    assign tri_out = triangle_out;
endmodule
