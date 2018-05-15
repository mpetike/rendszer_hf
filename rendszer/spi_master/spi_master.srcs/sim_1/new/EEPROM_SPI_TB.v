`timescale 1ns / 1ps


module EEPROM_SPI_TB(
    );
    
    
    //Clock generation
    reg S_AXI_ACLK = 0;
    
    always
    begin
        #5 S_AXI_ACLK <= ~S_AXI_ACLK;
    end
    
    //Reset signal generation
    reg S_AXI_ARESETN = 0;  //Initial state
    always
    begin
        #20;
        @(posedge S_AXI_ACLK);
        #1 S_AXI_ARESETN <= 1;        
    end
    
    //Connections
    //AXI4-Lite wires
    //Write address channel
    reg [3:0] S_AXI_AWADDR = 0;   
    reg  S_AXI_AWVALID = 0;
    wire  S_AXI_AWREADY;
    //Write data channel
    reg [31:0] S_AXI_WDATA = 0;
    reg [3:0] S_AXI_WSTRB = 0;
    reg  S_AXI_WVALID = 0;
    wire  S_AXI_WREADY;
    //Write response channel
    wire [1:0] S_AXI_BRESP;
    wire  S_AXI_BVALID;
    reg  S_AXI_BREADY = 0;
    //Read address channel
    reg [3:0] S_AXI_ARADDR = 0;
    reg  S_AXI_ARVALID = 0;
    wire  S_AXI_ARREADY;
    //Read data channel
    wire [31:0] S_AXI_RDATA;
    wire [1:0] S_AXI_RRESP;
    wire  S_AXI_RVALID;
    reg  S_AXI_RREADY = 0;
    //SPI IO
    wire MOSI;
    wire MISO;
    wire SCK;
    wire TX_DONE_IT;
    wire CS;
    
    //AXI Lite transaction tasks
    //Write transaction
    task axi_write;
        input [3:0] address;
        input [31:0] data;
        begin
            @(posedge S_AXI_ACLK);
            #1;
            S_AXI_AWADDR <= address;
            S_AXI_AWVALID <= 1;
            S_AXI_WDATA <= data;
            S_AXI_WSTRB <= 4'b1111;
            S_AXI_WVALID <= 1;
            S_AXI_BREADY <= 1;
            wait(S_AXI_AWREADY);
            wait(S_AXI_WREADY);
            @(posedge S_AXI_ACLK);
            S_AXI_WVALID <= 0;
            S_AXI_AWVALID <= 0;
            wait(S_AXI_BVALID);
            @(posedge S_AXI_ACLK);
            S_AXI_BREADY <= 0;
        end
    endtask
    
    //Read transaction
    task axi_read;
        input [3:0] address;
        output reg [31:0] data;
        begin
            @(posedge S_AXI_ACLK);
            #1;
            S_AXI_ARADDR <= address;
            S_AXI_ARVALID <= 1;
            S_AXI_RREADY <= 1;
            wait(S_AXI_ARREADY);
            @(posedge S_AXI_ACLK);
            S_AXI_ARVALID <= 0;
            wait(S_AXI_RVALID);
            @(posedge S_AXI_ACLK);
            data <= S_AXI_RDATA;
            #1;
            S_AXI_RREADY <= 0;
        end
    endtask
    
    //Read buffer    
    reg [31:0] read_data = 0;
    
    //Test cases
    always
    begin        
        #40;
        //Set up SPI
        axi_write(4,3); //CLK div /16
        axi_write(8,8'b10);     //IT enable
        //Pull CS low
        axi_write(12,8'b10);
        //WRITE LATCH ON
        axi_write(0,8'b00000110);
        //CS high
        wait(TX_DONE_IT);
        axi_write(12,8'b00);
        #50;
        //CS low
        axi_write(12,8'b10);
        //Write data
        axi_write(0,8'b00000010); wait(TX_DONE_IT);//Write instruction
        axi_write(0,8'b00000010); wait(TX_DONE_IT);   //ADDRESS
        axi_write(0,8'hAA); wait(TX_DONE_IT);   //DATA
        axi_write(0,8'hBB); wait(TX_DONE_IT);
        axi_write(0,8'hC5); wait(TX_DONE_IT); 
        axi_write(12,8'b00); //CS high
        #500;
        //Read data
        axi_write(12,8'b10); //CS low
        axi_write(0,8'b00000011); wait(TX_DONE_IT);//Read instruction
        axi_write(0,8'b00000010); wait(TX_DONE_IT);   //ADDRESS
        axi_write(0,8'b0); wait(TX_DONE_IT);  //Start transfer
        axi_read(0,read_data);  //READû
        axi_write(0,8'b0); wait(TX_DONE_IT);  //Start transfer
        axi_read(0,read_data);  //READ
        axi_write(0,8'b0); wait(TX_DONE_IT);  //Start transfer
        axi_read(0,read_data);  //READ
        axi_write(12,8'b00); //CS high
        #5000000;
    end   

    
    //Connect to UUT
    AXI_LITE_CNTRL UUT( .S_AXI_ACLK(S_AXI_ACLK),
                        .S_AXI_ARESETN(S_AXI_ARESETN),
                        .S_AXI_AWADDR(S_AXI_AWADDR),
                        .S_AXI_AWVALID(S_AXI_AWVALID),
                        .S_AXI_AWREADY(S_AXI_AWREADY),
                        .S_AXI_WDATA(S_AXI_WDATA),
                        .S_AXI_WSTRB(S_AXI_WSTRB),
                        .S_AXI_WVALID(S_AXI_WVALID),
                        .S_AXI_WREADY(S_AXI_WREADY),
                        .S_AXI_BRESP(S_AXI_BRESP),
                        .S_AXI_BVALID(S_AXI_BVALID),
                        .S_AXI_BREADY(S_AXI_BREADY),
                        .S_AXI_ARADDR(S_AXI_ARADDR),
                        .S_AXI_ARVALID(S_AXI_ARVALID),
                        .S_AXI_ARREADY(S_AXI_ARREADY),
                        .S_AXI_RDATA(S_AXI_RDATA),
                        .S_AXI_RRESP(S_AXI_RRESP),
                        .S_AXI_RVALID(S_AXI_RVALID),
                        .S_AXI_RREADY(S_AXI_RREADY),
                        .MOSI(MOSI),
                        .MISO(MISO),
                        .SCK(SCK),
                        .TX_DONE_IT(TX_DONE_IT),
                        .CS(CS)
                        );

    //EEPROM
    M25AA010A EEPROM(   .SI(MOSI),
                        .SCK(SCK),
                        .CS_N(CS),
                        .WP_N(1'b1),
                        .HOLD_N(1'b1),
                        .RESET(~S_AXI_ARESETN),
                        .SO(MISO));
    
endmodule
