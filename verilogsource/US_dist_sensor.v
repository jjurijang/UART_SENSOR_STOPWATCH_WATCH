`timescale 1ns / 1ps


module US_dist_sensor(
    input clk,
    input rst,
    input echo,
    input btn_start,
    input btn_stop,
    output [9:0]distance,
    output start_trigger
    );
    wire tick_1us;
    wire done;
    dist_calculator U_DIST_CAL(
        .clk(clk),
        .rst(rst),
        .tick(tick_1us), 
        .echo(echo),
        .distance(distance),
        .cal_done(done),
        .start_trigger(start_trigger)
    );
    tick_generator_1us U_TICK_GEN_1us(
        .clk(clk),
        .rst(rst),
        .btn_stop(btn_stop),
        .btn_start(btn_start),
        .tick_1us(tick_1us)
    );
    
    sensor_controller U_US_CTRL(
        .clk(clk),
        .rst(rst),
        .done(done),
        .tick(tick_1us),
        .btn_start(btn_start),
        .start_trigger(start_trigger)
        );
endmodule
