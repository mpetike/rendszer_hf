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
    wire [31:0] NCO_OUT;
    wire [31:0] cntrl_word;
    assign cntrl_word = 85899345;
    
    
    //UUT
    DDS_top UUT(    .clk(clk),
                    .rst(rst),
                    .cntrl_word(cntrl_word),
                    .nco_out(NCO_OUT)
                    );
    
endmodule
