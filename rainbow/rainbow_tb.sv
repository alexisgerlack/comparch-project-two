`timescale 1ns/1ps //in order to get a better read increase second number. this is wherer we establish units
`include "top.sv"
//test bench
module rainbow_tb;

    parameter PWM_INTERVAL = 1200;
    parameter INC_DEC_INTERVAL = 5000;
    parameter CLK_HALF_PERIOD = 12;
    parameter SIM_TICKS = 12000000;
    parameter INC_DEC_MAX = 400;

    //initializing tracked vals
    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;
    real expect_r  = 0.0;   // what pwm_value says it should be
    real expect_g  = 0.0;
    real expect_b  = 0.0;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL(INC_DEC_INTERVAL)
    ) u0 (
        .clk            (clk),
        .RGB_R          (RGB_R),
        .RGB_G          (RGB_G),
        .RGB_B          (RGB_B)
    );
    always #(CLK_HALF_PERIOD) clk = ~clk;

    always @(posedge clk)begin
        expect_r <= 100.0 * u0.pwm_value_r / PWM_INTERVAL;
        expect_g <= 100.0 * u0.pwm_value_g / PWM_INTERVAL;
        expect_b <= 100.0 * u0.pwm_value_b / PWM_INTERVAL;
    end

    initial begin
        $dumpfile("rainbow.vcd"); //system functions - makes a file to save signals
        $dumpvars(0, rainbow_tb); //system functions - 0 save all signals
        #(SIM_TICKS * 2 * CLK_HALF_PERIOD);
        $finish; //ends sim
    end

endmodule

