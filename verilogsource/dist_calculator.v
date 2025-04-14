`timescale 1ns / 1ps


module dist_calculator(
    input clk,
    input rst,
    input tick, 
    input echo,
    input start_trigger,
    output [9:0] distance,
    output cal_done
); //100_000_000; 1us > 1000번 1ms > 1000번 500_000
parameter ECHO_COUNT = 252_0000;
parameter OUT_COUNT = 1000_010;
parameter IDLE = 0, START = 1, ECHO =2, CAL = 3, ERROR=4;
reg [2:0] state,next;
reg cal_done_reg, cal_done_next;
reg [$clog2(ECHO_COUNT)-1:0] counter_reg, counter_next;
reg [$clog2(OUT_COUNT)-1 :0] outcount_reg, outcount_next;
reg [9:0] range_reg,range_next, count_1cm_next, count_1cm_reg;

reg [7:0] count_58_next, count_58_reg;

assign cal_done = cal_done_reg;
assign distance = range_reg;

always @(posedge clk, posedge rst) begin
    if(rst) begin
        state <= 0;
        counter_reg <= 0;
        range_reg <= 0;
        cal_done_reg <= 0;
        outcount_reg <= 0;
        count_1cm_reg <=0;
        count_58_reg <=0;
    end else begin
        state = next;
        counter_reg <= counter_next;
        cal_done_reg <= cal_done_next;
        range_reg <= range_next;
        outcount_reg <= outcount_next;
        count_1cm_reg <= count_1cm_next;
        count_58_reg <= count_58_next;
    end
end

always @(*) begin
    next = state;
    counter_next = counter_reg;
    range_next = range_reg;
    outcount_next = outcount_reg;
    cal_done_next = cal_done_reg;
    count_1cm_next = count_1cm_reg;
    count_58_next = count_58_reg;
    case (state)
        IDLE: begin
            counter_next = 0;
            cal_done_next = 0;
            count_1cm_next =0;
            count_58_next = 0;
            outcount_next = 0;
            if(start_trigger == 1'b1) begin
                next = START;
            end

            
        end
        START: begin
            
            if(echo == 1 & tick == 1'b1) begin
                next = ECHO;
            end else begin
                if(tick == 1'b1) begin
                    outcount_next = outcount_reg + 1;
                    if (outcount_reg == OUT_COUNT -1) begin
                        next = ERROR;
                        outcount_next = 0;
                    end
                end

            end       
        end
        ECHO: begin
                if(tick == 1'b1) begin
                    if(echo == 0) begin
                        counter_next = counter_reg;
                        count_1cm_next = count_1cm_reg;
                        next = CAL;
                    end else begin
                        if(counter_reg == ECHO_COUNT -1) begin
                            counter_next = 0;
                            count_58_next = 0;
                            count_1cm_next = count_1cm_reg;
                            next = CAL;
                        end else begin
                            if(count_58_reg == 57) begin
                                counter_next = counter_reg + 1;
                                count_1cm_next = count_1cm_reg + 1;
                                count_58_next = 0;
                            end else begin
                                count_1cm_next = count_1cm_reg;
                                count_58_next = count_58_reg + 1;
                                counter_next = counter_reg + 1;
                            end
                        end
                    end
                end
            end
        CAL: begin
            range_next = count_1cm_reg;
            cal_done_next = 1;
            next = IDLE;
        end
        ERROR: begin
            range_next = 0;
            cal_done_next = 1;
            next = IDLE;
        end
    endcase
end


endmodule
