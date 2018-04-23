`timescale 1ns / 1ps


module DDS_top( //Reset,clock
                input clk,
                input rst,
                //Controll
                input [31:0] cntrl_word,
                
                //DEBUG
                output [31:0] nco_out
    );

    //NCO    
    reg [31:0] nco_cnt = 0;
    
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
    
    
    //SIN LUT
    
    
    //COMP
    
    //Debug connections
    assign nco_out = nco_cnt;    
    
endmodule
