localparam [1:0] PWM_INC   = 2'b00;
localparam [1:0] PWM_CONT1 = 2'b01;
localparam [1:0] PWM_CONT2 = 2'b10;
localparam [1:0] PWM_DEC   = 2'b11;

module rainbow #(
    parameter INC_DEC_INTERVAL = 5000,      // how many clock ticks until it changes brightness
    parameter INC_DEC_MAX = 400,            // how many inc/dec ticks until it changes state
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX, //needs to be 2million because there are 6 states
    parameter logic [1:0] FIRST_CASE = PWM_INC,
    parameter logic [1:0] NEXT_CASE  = PWM_DEC,
    parameter INIT_VALUE = PWM_INTERVAL
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value = INIT_VALUE
);

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec, time_to_transition;
    assign time_to_inc_dec = (count == INC_DEC_INTERVAL -1);
    assign time_to_transition = time_to_inc_dec && (inc_dec_count == INC_DEC_MAX -1);

    // Initialize state variables
    logic [1:0] current_state = FIRST_CASE;
    logic [1:0] next_state;
    logic [1:0] next_delta_state = NEXT_CASE; // whether we are going up or down next

    always_ff @(posedge clk)begin
        count <= time_to_inc_dec ? '0 : count + 1'b1; //update count
        if(time_to_inc_dec)begin
            // add subtract or neutral the pwm value
            case(current_state)
                PWM_INC: pwm_value <= pwm_value + INC_DEC_VAL;
                PWM_DEC: pwm_value <= pwm_value - INC_DEC_VAL;
                default: pwm_value <= pwm_value; //if its cont1 or cont2 stay
            endcase
            //reset back to 0
            inc_dec_count <= time_to_transition ? '0 : inc_dec_count + 1'b1;
        end
        if(time_to_transition)begin
            case(current_state)
                PWM_INC: begin
                    next_delta_state <= PWM_DEC;
                    current_state <= PWM_CONT1;
                end
                PWM_DEC: begin
                    next_delta_state <= PWM_INC;
                    current_state <= PWM_CONT1;
                end
                PWM_CONT1: current_state = PWM_CONT2;
                PWM_CONT2: current_state = next_delta_state;
            endcase
        end
    end

endmodule
