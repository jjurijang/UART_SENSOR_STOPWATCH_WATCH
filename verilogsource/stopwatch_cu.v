`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/10 11:53:37
// Design Name: 
// Module Name: stopwatch_cu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stopwatch_cu(
    input clk,
    input reset,

    input i_btn_run,
    input i_btn_clear,

    output reg o_run,
    output reg o_clear
    );
    parameter STOP = 2'b00, RUN = 2'b01 , CLEAR = 2'b10;
    reg [1:0] state, next;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 0;
        end else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;

        o_clear = 1'b0;
        o_run = 1'b0;

        case (state)
            STOP: begin
                o_clear = 1'b0;
                o_run = 1'b0;

                if(i_btn_run == 1'b1) begin
                    next = RUN;
                end else if(i_btn_clear == 1'b1) begin
                    next = CLEAR;
                end else begin
                    next = state;
                end
                
            end
            RUN: begin
                o_clear = 1'b0;
                o_run = 1'b1;

                if(i_btn_run == 1'b1) begin
                    next = STOP;
                end else begin
                    next = state;
                end
            end
            CLEAR: begin
                o_clear = 1'b1;

                if(i_btn_clear == 1'b0) begin
                    next = STOP;
                end else begin
                    next = state;
                end
            end
            default: begin 
                next = state;

                o_clear = 1'b0;
                o_run = 1'b0;
            end
        endcase
        
    end

endmodule

