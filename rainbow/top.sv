`include "rainbow2.sv"
`include "pwm.sv"
//`include "pwm_states_pkg.sv"
//import pwm_states_pkg::*;
// rainbow top level module

module top #(
    parameter PWM_INTERVAL = 1200,      // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_INTERVAL = 12000,
    parameter INC_DEC_MAX = 1200 //each state lasts for imc_dec_max * inc_dec_interval
)(
    input logic     clk,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_r;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_g;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_b;
    logic pwm_out_r;
    logic pwm_out_g;
    logic pwm_out_b;

    //creating instance of rainbow for the red color
    rainbow #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL(INC_DEC_INTERVAL),
        .INC_DEC_MAX(INC_DEC_MAX),
        .FIRST_CASE     (PWM_CONT2),
        .NEXT_CASE      (PWM_DEC),
        .INIT_VALUE     (PWM_INTERVAL) //this is because red is the only one that starts fully on
    ) ur1 (
        .clk            (clk),
        .pwm_value      (pwm_value_r)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) ur2 (
        .clk            (clk),
        .pwm_value      (pwm_value_r),
        .pwm_out        (pwm_out_r)
    );

    //creating instance of rainbow for the green color
    rainbow #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL(INC_DEC_INTERVAL),
        .INC_DEC_MAX(INC_DEC_MAX),
        .FIRST_CASE     (PWM_INC),
        .NEXT_CASE      (PWM_DEC),
        .INIT_VALUE     (0)
    ) ug1 (
        .clk            (clk),
        .pwm_value      (pwm_value_g)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) ug2 (
        .clk            (clk),
        .pwm_value      (pwm_value_g),
        .pwm_out        (pwm_out_g)
    );

    //creating instance of rainbow for the blue color
    rainbow #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL(INC_DEC_INTERVAL),
        .INC_DEC_MAX(INC_DEC_MAX),
        .FIRST_CASE     (PWM_CONT1),
        .NEXT_CASE      (PWM_INC),
        .INIT_VALUE     (0)
    ) ub1 (
        .clk            (clk),
        .pwm_value      (pwm_value_b)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) ub2 (
        .clk            (clk),
        .pwm_value      (pwm_value_b),
        .pwm_out        (pwm_out_b)
    );

    assign RGB_R = pwm_out_r;
    assign RGB_G = pwm_out_g;
    assign RGB_B = pwm_out_b;

endmodule
