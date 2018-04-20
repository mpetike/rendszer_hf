`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2018 11:47:57
// Design Name: 
// Module Name: SPI_MASTER
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


module SPI_MASTER(  //Clock and reset
                    input clk,
                    input rstn,
                    //Registers
                    input [7:0] data_in,
                    output reg [7:0] data_out,
                    output reg tx_done,
                    input cs
    );
endmodule
