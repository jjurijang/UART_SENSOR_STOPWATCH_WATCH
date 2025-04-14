`timescale 1ns / 1ps


module TOP_PROJECT(
    // uartfifo
    input clk,
    input rst,
    input rx,
    output tx,
    //dht sensor
    input sw_mode_dht,
    input sw_mode_temp,
    inout dht_io,
    // US_SENSOR
    input echo,
    input sw_mode_us,
    output start_trigger,
    //ST_WA
    input [1:0]sw_mode,
    input btn_run,
    input btn_clear,
    input btn_sec_rise,
    input btn_min_rise,
    output [5:0] led,
    output [5:0] dht_state_led,
    output [3:0] fnd_comm,
    output [7:0] fnd_font

    );
    wire [7:0] w_uart_data;
    /*
    ila_0 U_ila(
        .clk(clk),
        .probe0(tx),
        .probe1(w_uart_data)
    );
*/

    TOP_UART_FIFO U_TOP_UARTFIFO(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .data(w_uart_data)
    );



    top_ST_WA U_TOP_ST_WA(
        .clk(clk),
        .reset(rst),
        .sw_mode(sw_mode),
        .echo(echo),
        .start_trigger(start_trigger),
        .sw_mode_us(sw_mode_us),
        .sw_mode_dht(sw_mode_dht),
        .sw_mode_temp(sw_mode_temp),
        .btn_run(btn_run),
        .btn_clear(btn_clear),
        .btn_sec_rise(btn_sec_rise),
        .btn_min_rise(btn_min_rise),
        .uart_data(w_uart_data),
        .led(led),
        .dht_state_led(dht_state_led),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .dht_io(dht_io)
    );
endmodule
