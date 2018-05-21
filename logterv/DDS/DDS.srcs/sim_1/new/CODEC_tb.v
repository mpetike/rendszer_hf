`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2018 14:27:25
// Design Name: 
// Module Name: CODEC_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CODEC_tb(

    );
    
    
    reg clk = 0;
    
    always
    begin
        #25 clk <= ~clk;
    end
    
endmodule
