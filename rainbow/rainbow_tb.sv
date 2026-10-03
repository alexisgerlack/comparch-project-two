`timescale 1ns/1ps //in order to get a better read increase second number. this is wherer we establish units
`include "top.sv"
//test bench
module rainbow_tb;

    parameter PWM_INTERVAL = 1200;
    parameter INC_DEC_INTERVAL = 1200;
    parameter CLK_HALF_PERIOD = 12;
    parameter SIM_TICKS = 8640000;
    parameter INC_DEC_MAX = 1200;

    //initializing tracked vals
    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

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
    real analog_voltage = 0.0;
    real RC = 1000.0; // Adjust time constant to match your PWM frequency

    always @(posedge clk) begin
        // Simple digital RC low-pass filter approximation
        analog_voltage <= analog_voltage + ((RGB_B ? 1.0 : 0.0) - analog_voltage) / RC;
    end

    initial begin
        $dumpfile("rainbow.vcd"); //system functions - makes a file to save signals
        $dumpvars(0, rainbow_tb); //system functions - 0 save all signals
        #(SIM_TICKS * 2 * CLK_HALF_PERIOD);
        $finish; //ends sim
    end

endmodule

