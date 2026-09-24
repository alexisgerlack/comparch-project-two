`include "rainbow.sv"
`include "pwm.sv"

// rainbow top level module

module top #(
    parameter PWM_INTERVAL = 1200,      // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_INTERVAL = 12000,
    parameter INC_DEC_MAX = 1000
)(
    input logic     clk,
    output logic    LED
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;
    logic pwm_out;

    rainbow #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL(INC_DEC_INTERVAL),
        .INC_DEC_MAX(INC_DEC_MAX)
    ) u1 (
        .clk            (clk),
        .pwm_value      (pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_value), 
        .pwm_out        (pwm_out)
    );

    assign LED = ~pwm_out;

endmodule
