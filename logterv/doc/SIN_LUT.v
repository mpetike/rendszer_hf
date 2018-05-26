`timescale 1ns / 1ps

//1024 elem� LUT egy szinusz els� negyed�t tartalmazza

module SIN_LUT( input clk,
                input [9:0] address,
                output reg [22:0] sin_out                
    );
    
    //Adress latching
    reg [9:0] address_reg;
    always @ (posedge clk)
    begin
        address_reg <= address;
    end 
    //LUT
    always @*
    begin
        case(address_reg)
        10'h000 : sin_out = 23'h000000;
        10'h001 : sin_out = 23'h003244;
        10'h002 : sin_out = 23'h006488;
        10'h003 : sin_out = 23'h0096cc;
        10'h004 : sin_out = 23'h00c910;
        10'h005 : sin_out = 23'h00fb53;
                    .
                    .
                    .
                    .
                    .
        10'h3fc : sin_out = 23'h7fff62;
        10'h3fd : sin_out = 23'h7fffa7;
        10'h3fe : sin_out = 23'h7fffd9;
        10'h3ff : sin_out = 23'h7ffff6;
        endcase
    end
    
endmodule
