`timescale 1ns / 1ps
//AXI Lite controller with 4 32 bit registers


module AXI_LITE_CNTRL(
                        //General
                        input wire  S_AXI_ACLK, //Clock
                        input wire  S_AXI_ARESETN,  //Active LOW reset
                        //AXI4-Lite wires
                        //Write address channel
                        input wire [3:0] S_AXI_AWADDR,   //Address, 4 bits
                        input wire  S_AXI_AWVALID,  //Write address valid
                        output reg  S_AXI_AWREADY, //Write address ready
                        //Write data channel
                        input wire [31:0] S_AXI_WDATA,  //Input data
                        input wire [3:0] S_AXI_WSTRB,   //Byte lane select
                        input wire  S_AXI_WVALID,   // Write addres valid
                        output reg  S_AXI_WREADY,   //Ready for write
                        //Write response channel
                        output reg [1:0] S_AXI_BRESP,    //Write response
                        output reg  S_AXI_BVALID,
                        input wire  S_AXI_BREADY,
                        //Read address channel
                        input wire [3:0] S_AXI_ARADDR,
                        input wire  S_AXI_ARVALID,
                        output reg  S_AXI_ARREADY,
                        //Read data channel
                        output reg [31:0] S_AXI_RDATA,
                        output reg [1:0] S_AXI_RRESP,
                        output reg  S_AXI_RVALID,
                        input wire  S_AXI_RREADY,
                        //SPI signals
                        output CS,
                        output MOSI,
                        output SCK,
                        input MISO,
                        //Interrupt
                        output reg TX_DONE_IT
    );
    
    reg aw_enable = 0;
    //Awready gen
    always @ (posedge S_AXI_ACLK)
    begin
        if (~S_AXI_ARESETN) //Reset signal
            begin
                S_AXI_AWREADY <= 0;
                aw_enable <= 1;
            end
        else
            begin
                if(~S_AXI_AWREADY && S_AXI_AWVALID && S_AXI_WVALID && aw_enable)
                    begin
                        S_AXI_AWREADY <= 1;
                        aw_enable <= 0;
                    end
                else if(S_AXI_BREADY && S_AXI_BVALID)
                    begin
                        S_AXI_AWREADY <= 0;   
                        aw_enable <= 1; 
                    end
                else
                    S_AXI_AWREADY <= 0;
            end
    end
    
    //Write address latching
    
    reg [3:0] axi_waddr = 0;
    
    always @ (posedge S_AXI_ACLK)
    begin
        if(~S_AXI_ARESETN)
            begin
                axi_waddr <= 0;
            end
        else
            begin
                if(~S_AXI_AWREADY && S_AXI_AWVALID && S_AXI_WVALID && aw_enable)
                    axi_waddr <= S_AXI_AWADDR;
            end
    end
    
    //Wready gen    
    always @ (posedge S_AXI_ACLK)
    begin
        if (~S_AXI_ARESETN)
            begin
                S_AXI_WREADY <= 0;
            end
        else
            begin
                if(~S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWVALID && aw_enable)
                    begin
                        S_AXI_WREADY <= 1;
                    end
                else
                    begin
                        S_AXI_WREADY <= 0;
                    end    
            end
    end
    
    //Write logic
    //---INPUT REGISTERS------
    reg [31:0] input_reg0 = 0;
    reg [31:0] input_reg1 = 0;
    reg [31:0] input_reg2 = 0;
    reg [31:0] input_reg3 = 0;
    //------------------------
    //New TX trigger signal
    reg NEW_TX = 0;    
    reg TX_DONE_CLEAR;
    always @ (posedge S_AXI_ACLK)
    begin
        if(~S_AXI_ARESETN)
            begin
                input_reg0 <= 0;
                input_reg1 <= 0;
                input_reg2 <= 0;
                input_reg3 <= 0;
            end
        else
            begin
                if(S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWREADY && S_AXI_AWVALID)
                    begin
                        case(axi_waddr[3:2])
                            2'h0:
                                begin
                                    if(S_AXI_WSTRB[0] == 1)
                                        begin
                                            input_reg0[7:0] <= S_AXI_WDATA[7:0];
                                            NEW_TX <= 1;
                                        end
                                    if(S_AXI_WSTRB[1] == 1)
                                        input_reg0[15:8] <= S_AXI_WDATA[15:8];
                                    if(S_AXI_WSTRB[2] == 1)
                                        input_reg0[23:16] <= S_AXI_WDATA[23:16];
                                    if(S_AXI_WSTRB[3] == 1)
                                        input_reg0[31:24] <= S_AXI_WDATA[31:24];
                                end
                            2'h1:
                                begin
                                    if(S_AXI_WSTRB[0] == 1)
                                            input_reg1[7:0] <= S_AXI_WDATA[7:0];                                            
                                    if(S_AXI_WSTRB[1] == 1)
                                        input_reg1[15:8] <= S_AXI_WDATA[15:8];
                                    if(S_AXI_WSTRB[2] == 1)
                                        input_reg1[23:16] <= S_AXI_WDATA[23:16];
                                    if(S_AXI_WSTRB[3] == 1)
                                        input_reg1[31:24] <= S_AXI_WDATA[31:24];
                                end
                            2'h2:
                                begin
                                    if(S_AXI_WSTRB[0] == 1)
                                        begin
                                            input_reg2[7:0] <= S_AXI_WDATA[7:0];
                                            TX_DONE_CLEAR <= 1;
                                        end
                                    if(S_AXI_WSTRB[1] == 1)
                                        input_reg2[15:8] <= S_AXI_WDATA[15:8];
                                    if(S_AXI_WSTRB[2] == 1)
                                        input_reg2[23:16] <= S_AXI_WDATA[23:16];
                                    if(S_AXI_WSTRB[3] == 1)
                                        input_reg2[31:24] <= S_AXI_WDATA[31:24];
                                end
                            2'h3:
                                begin
                                    if(S_AXI_WSTRB[0] == 1)
                                        input_reg3[7:0] <= S_AXI_WDATA[7:0];
                                    if(S_AXI_WSTRB[1] == 1)
                                        input_reg3[15:8] <= S_AXI_WDATA[15:8];
                                    if(S_AXI_WSTRB[2] == 1)
                                        input_reg3[23:16] <= S_AXI_WDATA[23:16];
                                    if(S_AXI_WSTRB[3] == 1)
                                        input_reg3[31:24] <= S_AXI_WDATA[31:24];
                                end
                            default:
                                begin
                                end
                        endcase
                    end
                else
                    begin
                        NEW_TX <= 0;
                        TX_DONE_CLEAR <= 0;
                    end
            end
    end
    
    //Write response---------------
    always @ (posedge S_AXI_ACLK)
    begin
        if(~S_AXI_ARESETN)
            begin
                S_AXI_BVALID <= 0;
                S_AXI_BRESP <= 0;
            end
        else
            begin
                if(S_AXI_AWREADY && S_AXI_AWVALID && ~S_AXI_BVALID && S_AXI_WREADY && S_AXI_WVALID)
                    begin
                        S_AXI_BVALID <= 1;
                        S_AXI_BRESP <= 0;
                    end
                else
                    begin
                        if(S_AXI_BREADY && S_AXI_BVALID)
                            S_AXI_BVALID <= 0;
                    end
            end
    end
    
    //Implement axi_arready generation
    
    reg [3:0] axi_araddr = 0;
    
    always @ (posedge S_AXI_ACLK)
    begin
        if(~S_AXI_ARESETN)
            begin
                S_AXI_ARREADY <= 0;
                axi_araddr <= 0;
            end
        else
            begin
                if(~S_AXI_ARREADY && S_AXI_ARVALID)
                    begin
                        S_AXI_ARREADY <= 1;
                        axi_araddr <= S_AXI_ARADDR;
                    end
                else
                    begin
                        S_AXI_ARREADY <= 0;
                    end
            end
    end
    
    //Implement axi_arvalid generation
    always @ (posedge S_AXI_ACLK)
    begin
        if(~S_AXI_ARESETN)
            begin
                S_AXI_RVALID <= 0;
                S_AXI_RRESP <= 0;
            end
        else
            begin
                if(S_AXI_ARREADY && S_AXI_ARVALID && ~S_AXI_RVALID)
                    begin
                        S_AXI_RVALID <= 1;
                        S_AXI_RRESP <= 0;
                    end
                else if(S_AXI_RVALID && S_AXI_RREADY)
                    begin
                        S_AXI_RVALID <= 0;
                    end
            end        
    end
    
    //Read logic
    //----Output registers------
    wire [31:0] output_reg0;
    wire [31:0] output_reg1;
    wire [31:0] output_reg2;
    wire [31:0] output_reg3;
    //--------------------------
    
    always @ (posedge S_AXI_ACLK)
    begin
        if(~S_AXI_ARESETN)
            begin
                S_AXI_RDATA <= 0;
            end
        else
            begin
                if(S_AXI_ARREADY && S_AXI_ARVALID && ~S_AXI_RVALID)
                    begin
                        case(axi_araddr[3:2])
                            2'h0 : S_AXI_RDATA <= output_reg0;
                            2'h1 : S_AXI_RDATA <= output_reg1;
                            2'h2 : S_AXI_RDATA <= output_reg2;
                            2'h3 : S_AXI_RDATA <= output_reg3;                         
                        endcase
                    end
            end
    end
    
    //--------------------------------------------------------------------------
    //SPI controll logic
       
    //Data register IN trigger
    wire SPI_busy;    
    wire TX_START = ~SPI_busy & NEW_TX & CS;
    
    //IT generation & TX_COMPLETE flag 
    reg TX_DONE_REG;
    wire TX_DONE_SPI;
    assign output_reg2[0] = TX_DONE_REG;
    assign output_reg2[1] = input_reg2[1];    
    
    
    always @ (posedge S_AXI_ACLK)
    begin
        if(S_AXI_ARESETN)
            begin
                TX_DONE_REG <= 0;
                TX_DONE_IT <= 0;
            end
        else
            begin
                if(TX_DONE_SPI)
                    begin
                        TX_DONE_REG <= 1;
                        if(input_reg2[1])
                            TX_DONE_IT <= 0;
                    end
                else if(((TX_DONE_CLEAR) && (input_reg2[0])) || (TX_START))
                    begin
                        TX_DONE_REG <= 0;
                        TX_DONE_IT <= 0;
                    end
                else
                    TX_DONE_IT <= 0;
            end
    end
    
    //REG4 CS BUSY
    assign CS = input_reg3[1];
    assign output_reg3[1] = input_reg3[1];
    assign output_reg3[0] = SPI_busy;
    
    //SPI connection
    SPI_MASTER SPI( .clk(S_AXI_ACLK),
                    .rstn(S_AXI_ARESETN),
                    .clk_div(input_reg1[2:0]),
                    .data_in(input_reg0[7:0]),
                    .data_out(output_reg0[7:0]),
                    .busy(SPI_busy),
                    .tx_complete(TX_DONE_SPI),
                    .start_tx(TX_START),
                    .MOSI(MOSI),
                    .MISO(MISO),
                    .sck(SCK)
                    );
    
    //Etc
    assign output_reg0[31:8] = 24'h0;
    assign output_reg1 = {29'h0,input_reg1[2:0]};
    assign output_reg2[31:2] = 30'h0;
    assign output_reg3[31:2] = 30'h0;
    
endmodule
