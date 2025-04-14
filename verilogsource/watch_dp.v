`timescale 1ns / 1ps

module watch_dp (
    input clk,
    input reset,
    input btn_sec,
    input btn_min,
    input btn_hour,
    output [6:0] msec,
    output [5:0]sec,
    output [5:0]min,
    output [4:0]hour
);
    wire w_clk_100hz;
    wire w_msec_tick,w_sec_tick,w_min_tick;
    clk_divider_watch_100hz U_Clk_Div_Watch_100hz(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    watch_timer_count #(.FCOUNT(100), .BIT_WIDTH(7)) U_Watch_TC_msec(
        .clk(clk),
        .reset(reset),
        .tick(w_clk_100hz),
        .btn_time_rise(),
        .o_tick(w_msec_tick),
        .o_time(msec)
    );
    watch_timer_count #(.FCOUNT(60), .BIT_WIDTH(6)) U_Watch_TC_sec(
        .clk(clk),
        .reset(reset),
        .tick(w_msec_tick),
        .btn_time_rise(btn_sec),
        .o_tick(w_sec_tick),
        .o_time(sec)
    );
    watch_timer_count #(.FCOUNT(60), .BIT_WIDTH(6)) U_Watch_TC_min(
        .clk(clk),
        .reset(reset),
        .tick(w_sec_tick),
        .btn_time_rise(btn_min),
        .o_tick(w_min_tick),
        .o_time(min)
    );
    watch_timer_count #(.FCOUNT(24), .BIT_WIDTH(5)) U_Watch_TC_hour(
        .clk(clk),
        .reset(reset),
        .tick(w_min_tick),
        .btn_time_rise(btn_hour),
        .o_tick(),
        .o_time(hour)
    );
endmodule


module watch_timer_count #(parameter FCOUNT = 100, BIT_WIDTH = 7)(
    input clk,
    input reset,
    input tick,
    input btn_time_rise,
    output o_tick,
    output [BIT_WIDTH-1:0] o_time
);
    reg [$clog2(FCOUNT) -1:0]count_reg, count_next;
    reg tick_reg, tick_next;
    assign o_tick = tick_reg;
    assign o_time = count_reg;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end
    
    always @(*) begin
        count_next = count_reg;
        tick_next = 0;
        if(btn_time_rise == 1'b1) begin
            if(count_reg == FCOUNT - 1) begin
                count_next = 0;    
            end else begin
                count_next = count_reg + 1;    
            end
            
        end else if(tick == 1'b1) begin
            if(count_reg == FCOUNT - 1)begin
                count_next = 0;
                tick_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0;
            end    
        end
        
    end
    
endmodule

module clk_divider_watch_100hz (
    input clk,
    input reset,
    output o_clk
);              //100_000_000
    parameter FCOUNT = 1_000_000 ;
    reg clk_reg,clk_next;
    reg [$clog2(FCOUNT) - 1:0] count_reg, count_next;
    assign o_clk = clk_reg;
    always @(posedge clk ,posedge reset) begin
        if(reset) begin
            count_reg <= 0;
            clk_reg <= 0;
        end else begin
            count_reg <= count_next;
            clk_reg <= clk_next;
        end
        
    end

    always @(*) begin
        count_next = count_reg;
        clk_next = 1'b0;
        if(count_reg == FCOUNT - 1) begin
            count_next = 0;
            clk_next = 1'b1;
        end else begin
            count_next = count_reg + 1;
            clk_next = 1'b0;
        end
    end


endmodule