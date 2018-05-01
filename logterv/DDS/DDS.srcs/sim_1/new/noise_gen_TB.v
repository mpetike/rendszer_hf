`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2018 14:17:36
// Design Name: 
// Module Name: noise_gen_TB
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


module noise_gen_TB(

    );
    
    reg rst = 0;
    always
    begin
        #50;
        rst <= 1;
    end
    
    reg clk = 0;
    always
    begin
        #5 clk <= ~clk;
    end
    
    wire [11:0] rnd_out;
    
    LFSR_Plus UUT(  .clk(clk),
                    .n_reset(rst),
                    .enable(1'b1),
                    .g_noise_out(rnd_out));
    
    
endmodule
