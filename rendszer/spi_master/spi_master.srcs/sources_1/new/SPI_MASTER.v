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
                    output reg sck,
                    output MOSI,
                    input MISO
    );
    
    
    
    //Clock divider
    reg [7:0] cntr = 0;
    reg cntr_enable = 0;
    
    always @(posedge clk)
    begin
        if((~rstn)||(~cntr_enable))
            cntr <= 0;
        else
            cntr <= cntr + 1;           
    end
    
    wire spi_tick = cntr[clk_div];
    
    //Controll state machine
    reg [1:0] state = 0;
    reg [7:0] TX_BUFFER;
    reg [7:0] RX_BUFFER;
    reg spi_tick_prev;
    reg [3:0] tx_count;
    
    assign MOSI = TX_BUFFER[7];
    
    //State machine
    always @(posedge clk)
    begin
        if(~rstn)
            begin
                state <= 0;
                TX_BUFFER <= 0;
                data_out <= 0;
                tx_complete <= 0;
                spi_tick_prev <= 0;
                tx_count <= 0;
                sck <= 0;
                cntr_enable <= 0;
            end
        else
            case(state)
                2'b00:  //Idle state
                    begin
                        tx_complete <= 0;
                        spi_tick_prev <= 0;
                        tx_count <= 0;
                        busy <= 0;
                        if(start_tx)
                            begin
                                state <= 2'b01;
                                busy <= 1;
                                TX_BUFFER <= data_in;
                                cntr_enable <= 1;
                                RX_BUFFER <= 0;
                            end
                    end
                2'b01:  //Transmit state
                    begin                      
                        //Shift data out falling edge
                        if((spi_tick_prev) && (~spi_tick))
                            begin
                                TX_BUFFER <= {TX_BUFFER[6:0],1'b0};
                                sck <= 0;
                                tx_count <= tx_count + 1;
                            end
                        //Sample data on rising edge
                        if((~spi_tick_prev) && (spi_tick) && (tx_count != 4'd8))
                            begin
                                RX_BUFFER <= {RX_BUFFER[6:0],MISO};
                                sck <= 1;
                            end
                        //Update tick  
                        spi_tick_prev <= spi_tick;
                        //Terminate transfer
                        if(tx_count == 4'd8)
                            begin
                                state <= 2'b10;
                                sck <= 0;                                
                            end                                                
                    end
                2'b10:  //TX done state
                    begin
                        tx_complete <= 1;
                        state <= 2'b00;
                        data_out <= RX_BUFFER;
                        TX_BUFFER <= 0;
                        cntr_enable <= 0;
                    end
                default:
                    state <= 0;
            endcase
    end
    
endmodule
