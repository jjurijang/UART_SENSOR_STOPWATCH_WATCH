`timescale 1ns / 1ps


module sensor_controller(
    input clk,
    input rst,
    input done,
    input tick,
    input btn_start,
    output start_trigger
    );
    parameter TICK_COUNT = 10;
    parameter IDLE = 0, START = 1, ECHO = 2, CAL = 3;
    reg [1:0] state, next;
    reg start_trigger_next,start_trigger_reg;
    reg[$clog2(TICK_COUNT)-1:0] counter_reg,counter_next;
    assign start_trigger = start_trigger_reg;
    always @(posedge clk ,posedge rst) begin
        if(rst) begin
            state <= 0;
            counter_reg <= 0;
            start_trigger_reg <= 0;
            
        end else begin
            state <= next;
            counter_reg <= counter_next;
            start_trigger_reg <= start_trigger_next;
        end
    end
    
    always @(*) begin
        counter_next = counter_reg;
        start_trigger_next = start_trigger_reg;
        next = state;
        case (state)
            IDLE: begin
                counter_next = 0;
                start_trigger_next = 0;
                if(done == 1 || btn_start) begin
                    next = START;
                    start_trigger_next = 1;
                end
            end
            START: begin
                start_trigger_next = 1;
                if(tick == 1'b1)
                    if(counter_reg == TICK_COUNT - 1) begin
                        counter_next = 0;
                        start_trigger_next = 0;
                        next = IDLE;
                    end else begin
                        counter_next = counter_reg + 1;
                    end
            end
    endcase
    end
endmodule
