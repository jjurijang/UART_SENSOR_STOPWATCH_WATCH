`timescale 1ns / 1ps


module stopwatch_dp(
    input clk,
    input reset,
    input run,
    input clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
    );
    wire w_clk_100hz;
    wire w_msec_tick, w_sec_tick, w_min_tick;
    time_counter #(.TICK_COUNT(100), .BIT_WIDTH(7)) U_Time_Msec(
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .tick(w_clk_100hz),
        .o_time(msec),
        .o_tick(w_msec_tick)
    );
    time_counter #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_Time_Sec(
        .clk(clk),
        .reset(reset),
        .tick(w_msec_tick),
        .clear(clear),
        .o_time(sec),
        .o_tick(w_sec_tick)
    );
    time_counter #(.TICK_COUNT(60), .BIT_WIDTH(6)) U_Time_Min(
        .clk(clk),
        .reset(reset),
        .tick(w_sec_tick),
        .clear(clear),       
        .o_time(min),
        .o_tick(w_min_tick)
    );
    time_counter #(.TICK_COUNT(24), .BIT_WIDTH(5)) U_Time_Hour(
        .clk(clk),
        .reset(reset),
        .tick(w_min_tick),
        .clear(clear),
        .o_time(hour),
        .o_tick()
    );
    clk_div_100hz U_Clk_Div(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .o_clk(w_clk_100hz)
    );                

endmodule
module time_counter #(parameter TICK_COUNT = 100, BIT_WIDTH = 7)(
    input clk,
    input reset,
    input tick,
    input clear,
    output [BIT_WIDTH - 1:0] o_time,
    output o_tick
);
    reg[$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
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
        if (clear == 1'b1) begin
            count_next = 0;
        end else if (tick == 1'b1) begin
            if(count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next= 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0;
            end
        end
    end
endmodule

module clk_div_100hz (
    input clk,
    input reset,
    input run,
    input clear,
    output o_clk
);                 //100_000_000
    parameter FCOUNT = 1_000_000; //10;//for test 
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next; // 출력을 f/f 으로 sequential하게 내보내게 하기 위해서
    // 이걸 쓰는게 implementation시 더 낫더라~

    assign o_clk = clk_reg;

    always @(posedge clk, posedge reset) begin
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
        clk_next = 1'b0; //clk_reg;
        if(run) begin
            if(count_reg == FCOUNT - 1) begin
                count_next = 0;
                clk_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                clk_next = 1'b0;
            end
        end else if (clear == 1'b1) begin
            count_next = 0;
            clk_next = 0;
        end
    end




endmodule