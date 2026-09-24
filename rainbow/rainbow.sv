// rainbow

module rainbow #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 200,            // Transition to next state after 1000/6 increments which is a 6th of a second
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Define state variable values
    localparam PWM_INC = 2'b00;
    localparam PWM_CONT1 = 2'b01;
    localparam PWM_CONT2 = 2'b10;
    localparam PWM_DEC = 2'b11;

    // Declare state variables CHANGE THIS FOR DIFFERENT INSTANCES
    logic [1:0] current_state = PWM_INC;
    logic [1:0] next_state;
    logic [1:0] next_delta_state = PWM_DEC;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = 0;
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
