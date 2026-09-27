`timescale 10ns/10ns //in order to get a better read increase second number. this is wherer we establish units
`include "top.sv"
//test bench
module rainbow_tb;

    parameter PWM_INTERVAL = 1200;
    parameter INC_DEC_INTERVAL = 1200;
    logic clk = 0;
    logic LED;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL(INC_DEC_INTERVAL)
    ) u0 (
        .clk            (clk),
        .LED            (LED)
    );

    initial begin
        $dumpfile("rainbow.vcd"); //system functions - makes a file to save signals
        $dumpvars(0, rainbow_tb); //system functions - 0 save all signals
        #576000 //delay 6 million csssssssslock ticks
        $finish; //ends sim
    end

    always begin
        //every 4 units we flip the clock (not very accurate)
        #4 //delay
        clk = ~clk;
    end

endmodule

