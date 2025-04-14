`timescale 1ns / 1ps


module tick_generator_1us(
    input clk,
    input rst,
    input btn_stop,
    input btn_start,
    output tick_1us
    );//100_000_000
    parameter STOP =0, RUN = 1 ;
    parameter FCOUNT = 100;
    reg [$clog2(FCOUNT)-1:0] counter_reg, counter_next;
    reg tick_next,tick_reg;
    reg state, next;
    assign tick_1us = tick_reg;

    always @(posedge clk ,posedge rst) begin
        if(rst) begin
            state <= 0;
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            state <= next;
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end
        
    end
    always @(*) begin
        tick_next = tick_reg;
        counter_next = counter_reg;
        next = state;
        case (state)
            STOP:begin
                    counter_next = 0;
                    tick_next = 0;
                if (btn_start == 1) begin
                    next = RUN;
                end
            end
            RUN: begin
                if(btn_stop == 1) begin
                    next = STOP;
                    counter_next = 0;
                    tick_next = 0;
                end else if(counter_reg == FCOUNT - 1) begin
                    counter_next = 0;
                    tick_next = 1;
                end else begin
                    counter_next = counter_reg + 1;
                    tick_next = 0;
                end

            end
            
        endcase
    end
    
endmodule

module tick_gen_1us #(parameter FCOUNT = 1000) (
    input clk,
    input rst,
    output tick
    ); //100_000_000
    reg tick_next, tick_reg;
    reg [$clog2(FCOUNT)-1:0] count_next,count_reg;
    assign tick = tick_reg;
    always @(posedge clk ,posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg <=0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end
        
    always @(*) begin
        count_next = count_reg;
        tick_next = 0;
        if(count_reg == FCOUNT -1) begin
            count_next = 0;
            tick_next = 1;
        end else begin
            count_next = count_reg + 1;
            tick_next = 0;
        end
    end
endmodule
