`timescale 1ns / 1ps
module TOP_UART_FIFO_UARTCU(
    input clk,
    input rst,
    input rx,
    output tx
);
    wire [7:0] data;
    wire w_uart_run, w_uart_clear, w_uart_sec_rise, w_uart_min_rise, w_uart_hour_rise;
    TOP_UART_FIFO dut1(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .data(data)
    );
    uart_cu U_UART_CU(
        .clk(clk),
        .rst(rst),
        .data(data),
        .uart_run(w_uart_run),
        .uart_clear(w_uart_clear),
        .uart_sec_rise(w_uart_sec_rise),
        .uart_min_rise(w_uart_min_rise),
        .uart_hour_rise(w_uart_hour_rise)
    );



endmodule

module TOP_UART_FIFO(
    input clk,
    input rst,
    input rx,
    output tx,
    output [7:0] data
);

    wire    [7:0]   w_rx_data, w_tx_data;
    wire    w_rx_done, w_tx_done, w_tx_finish;

    wire    [7:0]   fifo_data;
    wire    fifo_rx_empty, fifo_tx_full, fifo_tx_empty;
    assign data = fifo_data;

    uart dut(
        .clk(clk),
        .rst(rst),
        .btn_start(~fifo_tx_empty),
        .tx_data_in(w_tx_data),
        .tx(tx),
        .tx_done(w_tx_done),
        .tx_finish(w_tx_finish),
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(w_rx_data)
    );

    fifo dut_FIFO_rx(
        .clk(clk),
        .rst(rst),
        .wdata(w_rx_data),
        .wr(w_rx_done),
        .full(),
        .rd(~fifo_tx_full&~fifo_rx_empty),
        .rdata(fifo_data),
        .empty(fifo_rx_empty)
    );

    fifo dut_FIFO_tx(
        .clk(clk),
        .rst(rst),
        .wdata(fifo_data),
        .wr(~fifo_rx_empty),
        .full(fifo_tx_full),
        .rd(~w_tx_finish&~fifo_tx_empty),
        .rdata(w_tx_data),
        .empty(fifo_tx_empty)
    );    
    
    
    
endmodule
