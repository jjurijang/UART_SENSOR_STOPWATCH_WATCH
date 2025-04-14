`timescale 1ns / 1ps

module TOP_SENSOR(
    input clk,
    input rst,
    input echo,
    input btn_start,
    input [1:0] sw_mode,
    output start_trigger,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );
    wire [9:0]distance;
    wire w_btn_start;
    btn_debounce U_BTN_DB(
        .clk(clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(w_btn_start)
    );
    US_dist_sensor U_SNESOR(
        .clk(clk),
        .rst(rst),
        .echo(echo),
        .btn_start(w_btn_start),
        .distance(distance),
        .start_trigger(start_trigger)
    );
    fnd_controller U_FND_CTRL(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .distance(distance),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );
endmodule
