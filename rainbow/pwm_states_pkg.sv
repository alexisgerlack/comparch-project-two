//package listing all the pwm states so top and rainbow can read them
package pwm_states_pkg;
    localparam [1:0] PWM_INC   = 2'b00;
    localparam [1:0] PWM_CONT1 = 2'b01;
    localparam [1:0] PWM_CONT2 = 2'b10;
    localparam [1:0] PWM_DEC   = 2'b11;
endpackage
