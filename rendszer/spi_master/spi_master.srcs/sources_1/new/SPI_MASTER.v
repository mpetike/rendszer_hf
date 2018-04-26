`timescale 1ns / 1ps



module SPI_MASTER(  //Clock and reset
                    input clk,
                    input rstn,
                    //Registers
                    input [2:0] clk_div,
                    input [7:0] data_in,
                    output reg [7:0] data_out,
                    output reg busy,
                    output reg tx_complete,
                    input start_tx,
                    //IO
                    output sck,
                    output MOSI,
                    input MISO
    );
    
    //Controll line
    reg spi_enable;    
    
    //SPI COUNTER
    reg [12:0] spi_cntr = 0;    
    always @ (posedge clk)
    begin
        if((~spi_enable) || (~rstn))
            spi_cntr <= 0;
        else
            spi_cntr <= spi_cntr + 1;
    end
    
    //CLK div ratio 2/4/.../512
    wire [3:0] spi_state_cnt;
    assign spi_state_cnt = spi_cntr[clk_div +: 4];
    
    assign sck = spi_state_cnt[0];
    //CNTRL logic
    reg [1:0] state = 0;    //State machine state
    reg [7:0] TX_buffer;
    reg [7:0] RX_buffer;
    
    assign MOSI = TX_buffer[7];
    //SPI transmit state machine
    always @ (posedge clk)
    begin
        if(~rstn)
            begin
                state <= 0;
                busy <= 0;
                tx_complete <= 0;
                data_out <= 0;
                TX_buffer <= 0;
                spi_enable <= 0;
            end
        else
            begin
                case(state)
                    2'b00:  //Idle/setup state
                        begin
                            busy <= 0;
                            tx_complete <= 0;
                            spi_enable <= 0;                            
                            //Set up transmission when start signal is given
                            if(start_tx)
                                begin                                    
                                    state <= 2'b01;
                                    TX_buffer <= data_in;
                                    spi_enable <= 1;
                                    busy <= 1;
                                end
                        end
                    2'b01:  //Transfer state
                        begin              
                            #1; //DEBUG TIME DELAY
                            //On falling edge shift out tx data
                            if(spi_cntr[0] == 0)
                                TX_buffer <= {TX_buffer[6:0],1'b0};
                            //On rising edge shift in data
                            if(spi_cntr[0] == 1)
                                RX_buffer <= {RX_buffer[6:0],MISO};
                            //After 8 bits terminate transfer
                            if(spi_state_cnt == 4'b1111)
                                begin
                                    spi_enable <= 0;
                                    state <= 2'b10;
                                end
                        end
                    2'b10:  //Transfer complete state
                        begin
                            data_out <= RX_buffer;
                            TX_buffer <= 0;
                            state <= 2'b00;
                            tx_complete <= 1;
                        end
                    default : state <= 0;
                endcase
            end
    end   

endmodule
