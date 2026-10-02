`timescale 1ns/1ps //in order to get a better read increase second number. this is wherer we establish units
`include "top.sv"
//test bench
module rainbow_tb;

    parameter PWM_INTERVAL = 1200;
    parameter INC_DEC_INTERVAL = 1200;
    parameter CLK_HALF_PERIOD = 12;
    parameter SIM_TICKS = 1_000_000;
    parameter INC_DEC_MAX = 120;

    //initializing tracked vals
    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    logic [15:0] win = 0;
    logic [15:0] hi_R = 0, hi_G = 0, hi_B = 0;
    logic [15:0] duty_R = 0, duty_G = 0, duty_B = 0;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL(INC_DEC_INTERVAL)
    ) u0 (
        .clk            (clk),
        .RGB_R          (RGB_R),
        .RGB_G          (RGB_G),
        .RGB_B          (RGB_B)
    );
    always @(posedge clk) begin // turns pwm into brightness by finding high points/pwm cycle
        if (win == PWM_INTERVAL-1) begin
            duty_R <= hi_R + RGB_R;
            duty_G <= hi_G + RGB_G;
            duty_B <= hi_B + RGB_B;
            hi_R <= 0; hi_G <= 0; hi_B <= 0;
            win  <= 0;
        end else begin
            hi_R <= hi_R + RGB_R;
            hi_G <= hi_G + RGB_G;
            hi_B <= hi_B + RGB_B;
            win  <= win + 1;
        end
    end
    always #(CLK_HALF_PERIOD) clk = ~clk;

    initial begin
        $dumpfile("rainbow.vcd"); //system functions - makes a file to save signals
        $dumpvars(0, rainbow_tb); //system functions - 0 save all signals
        #(SIM_TICKS * 2 * CLK_HALF_PERIOD);
        $finish; //ends sim
    end

endmodule

