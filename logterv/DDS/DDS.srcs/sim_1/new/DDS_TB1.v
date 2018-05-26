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
    reg rst = 1;
    always
    begin
        #20;
        rst <= 0;
    end
    
    
    //DEBUG connections
    wire [23:0] NCO_OUT;
    wire [23:0] cntrl_word;
    assign cntrl_word = 568243;
    wire signed [23:0] sinusoid;
    wire [23:0] triangle;
    wire [23:0] sqrwave;
    wire [23:0] nco_dith;
    wire [11:0] rnd;
    reg [14:0] attenn = 15'h4000;
    reg [1:0] sig_select = 0;
    wire [23:0] signal_out;
    //UUT
    
    //ATTENNUATION
    always
    begin
        #1500;
        attenn <= 15'h4000;
        #50000;
    end
    
    //SIGNAL SELECT
    always
    begin
        #2300;
        sig_select <= 2'd0;
    end
    
    
    //Write sin waveform to file
    integer file,i;
    initial
    begin
        file = $fopen("output_sin.txt","w");
        for (i = 0; i<50000; i=i+1) begin
            @(posedge clk);
            $fwrite(file,"%d\n",sinusoid);
        end
        $fclose(file);
        $finish;
    end
    
    
    DDS UUT(    .clk(clk),
                    .rst(rst),
                    .cntrl_word(cntrl_word),
                    .attenn(attenn),
                    .wave_out(signal_out),
                    .wave_sel(sig_select),
                    .nco_out(NCO_OUT),
                    .sin_out(sinusoid),
                    .tri_out(triangle),
                    .sqr_out(sqrwave),
                    .nco_dith(nco_dith),
                    .rnd(rnd)
                    );
    
endmodule
