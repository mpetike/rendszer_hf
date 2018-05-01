`timescale 1ns / 1ps


module DDS_TB1(

    );
    
    //clk generation
    reg clk = 0;
    always
    begin
        #5 clk <= ~clk;
    end
    
    //reset generation
    reg rst = 0;
    
    //DEBUG connections
    wire [23:0] NCO_OUT;
    wire [23:0] cntrl_word;
    assign cntrl_word = 419430;
    wire [23:0] sinusoid;
    wire [23:0] triangle;
    wire [23:0] sqrwave;
    
    //UUT
    DDS UUT(    .clk(clk),
                    .rst(rst),
                    .cntrl_word(cntrl_word),
                    .nco_out(NCO_OUT),
                    .sin_out(sinusoid),
                    .tri_out(triangle),
                    .sqr_out(sqrwave)
                    );
    
endmodule
