`timescale 1ns / 1ps


module SPI_TB(

    );
    
    //Clock generation
    reg clk = 0;
    
    always
    begin
        #5 clk <= ~clk;
    end
    
    //Reset
    wire rstn = 1;
    
    //IO
    reg [7:0] data_in;
    reg [3:0] clk_div;
    wire [7:0] data_out;
    wire busy;
    wire tx_complete;
    reg start_tx;
    wire sck;
    wire MOSI;
    //Input
    reg MISO = 1'b1;
    
    //Controll
    always
    begin
        #20;
        @(posedge clk) #1;
        data_in <= 8'h55;
        clk_div <= 0;
        start_tx <= 1;
        @(posedge clk) #1;
        start_tx <= 0;
        wait(tx_complete);
        #20;
        @(posedge clk) #1;
        data_in <= 8'hAA;
        clk_div <= 0;
        start_tx <= 1;
        @(posedge clk) #1;
        start_tx <= 0;
        #5000;
    end
    
    //Read test
    always
    begin
        wait(tx_complete);
        #1 MISO <= 1;
        @(negedge sck);
        #1 MISO <= 0;
        @(negedge sck);
        #1 MISO <= 1;
        @(negedge sck);
        #1 MISO <= 0;
        @(negedge sck);
        #1 MISO <= 0;
        @(negedge sck);
        #1 MISO <= 1;
        @(negedge sck);
        #1 MISO <= 0;
        @(negedge sck);
        #1 MISO <= 1;
        #5000;        
    end
    
    //UUT instance
    SPI_MASTER UUT( .clk(clk),
                    .rstn(rstn),
                    .clk_div(clk_div),
                    .data_in(data_in),
                    .data_out(data_out),
                    .busy(busy),
                    .tx_complete(tx_complete),
                    .start_tx(start_tx),
                    .sck(sck),
                    .MOSI(MOSI),
                    .MISO(MISO));
                    
    
endmodule
