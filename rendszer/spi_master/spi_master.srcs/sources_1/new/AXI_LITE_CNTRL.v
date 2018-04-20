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
                        input wire  S_AXI_RREADY
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
                                        input_reg0[7:0] <= S_AXI_WDATA[7:0];
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
                                        input_reg2[7:0] <= S_AXI_WDATA[7:0];
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
    reg [31:0] output_reg0 = 0;
    reg [31:0] output_reg1 = 0;
    reg [31:0] output_reg2 = 0;
    reg [31:0] output_reg3 = 0;
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
    
    //SPI register logic
    //TESTCASE
    always @ (posedge S_AXI_ACLK)
    begin
        output_reg0 <= input_reg0 + input_reg1;
    end
    
endmodule
