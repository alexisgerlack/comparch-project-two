// rainbow
//`include "pwm_states_pkg.sv"
//import pwm_states_pkg::*;

localparam [1:0] PWM_INC   = 2'b00;
localparam [1:0] PWM_CONT1 = 2'b01;
localparam [1:0] PWM_CONT2 = 2'b10;
localparam [1:0] PWM_DEC   = 2'b11;

module rainbow #(
    parameter INC_DEC_INTERVAL = 1200,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 1200,            // Transition to next state after a 6th of a second
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX,
    parameter logic [1:0] FIRST_CASE = PWM_INC,
    parameter logic [1:0] NEXT_CASE  = PWM_DEC,
    parameter INIT_VALUE = PWM_INTERVAL
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Initialize state variables
    logic [1:0] current_state = FIRST_CASE;
    logic [1:0] next_state;
    logic [1:0] next_delta_state = NEXT_CASE;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        //initializing different starting values for pwm_value
        //the onlt color that starts at 0 is red
        pwm_value = INIT_VALUE;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition) begin
        if (current_state == PWM_INC) //if its increasing we will decrease next time we are in a changing phase
            next_delta_state <= PWM_DEC;
        else if (current_state == PWM_DEC)//if its dec we will inc next time we are in a changing phase
            next_delta_state <= PWM_INC;
        current_state <= next_state;
    end

    // Compute the next state of the FSM
    always_comb begin
        next_state = 2'bxx;
        case (current_state)
            PWM_INC:
                next_state = PWM_CONT1;
            PWM_CONT1:
                next_state = PWM_CONT2;
            PWM_CONT2:
                next_state = next_delta_state;
            PWM_DEC:
                next_state = PWM_CONT1;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_CONT1:
                pwm_value <= pwm_value;
            PWM_CONT2:
                pwm_value <= pwm_value;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
