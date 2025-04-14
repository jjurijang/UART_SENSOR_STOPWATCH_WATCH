`timescale 1ns / 1ps

module top_ST_WA(
    input clk,
    input reset,
    input echo,
    input [1:0]sw_mode,
    input sw_mode_us,
    input sw_mode_dht,
    input sw_mode_temp,
    input btn_run,
    input btn_clear,
    input btn_sec_rise,
    input btn_min_rise,
    input [7:0] uart_data,
    output [5:0] led,
    output [5:0] dht_state_led,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output start_trigger,
    inout dht_io
    );
    wire [6:0] stopwatch_msec, watch_msec, msec ;
    wire [5:0] stopwatch_sec,stopwatch_min,watch_sec, watch_min, sec,min;
    wire [4:0] stopwatch_hour, watch_hour, hour;
    wire w_run, w_clear,
                o_btn_min_rise, o_btn_sec_rise,
                run, clear,
                stopwatch_clear; // 반드시 선언을 해주자 1비트라도
    // UART CU에서 나오는 wire들들
    wire w_uart_run, w_uart_clear, w_uart_sec_rise, w_uart_min_rise, w_uart_hour_rise;
    wire w_uart_dht_run,w_uart_dht_stop;
    wire w_uart_sensor_run, w_uart_sensor_stop;
    assign w_sensor_start = (w_uart_sensor_run|w_run) & sw_mode_us;
    assign w_sensor_stop = (w_uart_sensor_stop|w_clear) & sw_mode_us;
    wire [9:0] distance;
    wire [15:0] temperature,humidity;
    wire [5:0]w_dht_state_led;
    assign dht_state_led = (sw_mode_dht == 1) ? w_dht_state_led : 0;
    top_dht U_DHT_TOP(
        .clk(clk),
        .rst(reset),
        .btn_start(w_run), //w_run
        .btn_stop(o_btn_min_rise), //minrise
        .uart_dht_run(w_uart_dht_run),
        .uart_dht_stop(w_uart_dht_stop),
        .sw_mode_dht(sw_mode_dht),
        .temperature(temperature),
        .humidity(humidity),
        .led(w_dht_state_led),
        .dht_io(dht_io)
    );
    uart_cu U_UART_CU(
        .clk(clk),
        .rst(reset),
        .data(uart_data),
        .uart_run(w_uart_run),
        .uart_clear(w_uart_clear),
        .uart_sec_rise(w_uart_sec_rise),
        .uart_min_rise(w_uart_min_rise),
        .uart_hour_rise(w_uart_hour_rise),
        .uart_us_run(w_uart_sensor_run),
        .uart_us_stop(w_uart_sensor_stop),
        .uart_dht_run(w_uart_dht_run),
        .uart_dht_stop(w_uart_dht_stop)
            );


    stopwatch_top U_Stopwatch_Top(
        .clk(clk),
        .reset(reset),

        .run(w_run),
        .clear(w_clear),

        .uart_run(w_uart_run),
        .uart_clear(w_uart_clear),

        .sw_mode(sw_mode[1]),
        .msec(stopwatch_msec),
        .sec(stopwatch_sec),
        .min(stopwatch_min),
        .hour(stopwatch_hour)
    );
    watch_top U_Watch_Top(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode[1]),

        .btn_sec_rise(o_btn_sec_rise),
        .btn_min_rise(o_btn_min_rise),
        .btn_hour_rise(w_run),

        .uart_sec_rise(w_uart_sec_rise),
        .uart_min_rise(w_uart_min_rise),
        .uart_hour_rise(w_uart_hour_rise),

        .msec(watch_msec),
        .sec(watch_sec),
        .min(watch_min),
        .hour(watch_hour)
    );

    data_selector U_Data_selector(
        .sel(sw_mode[1]),
        .stopwatch_data_msec(stopwatch_msec),
        .watch_data_msec(watch_msec),
        .stopwatch_data_sec(stopwatch_sec),
        .watch_data_sec(watch_sec),
        .stopwatch_data_min(stopwatch_min),
        .watch_data_min(watch_min),
        .stopwatch_data_hour(stopwatch_hour),
        .watch_data_hour(watch_hour),

        .data_out_msec(msec),
        .data_out_sec(sec),
        .data_out_min(min),
        .data_out_hour(hour)
    
    );



    btn_debounce U_Btn_DB_Run(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_run),
        .o_btn(w_run)
    );

    btn_debounce U_Btn_DB_Clear(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_clear),
        .o_btn(w_clear)
    );


    btn_debounce U_Btn_DB_sec(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_sec_rise),
        .o_btn(o_btn_sec_rise)
    );

    btn_debounce U_Btn_DB_min(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_min_rise),
        .o_btn(o_btn_min_rise)
    );
    

    US_dist_sensor U_SNESOR(
        .clk(clk),
        .rst(reset),
        .echo(echo),
        .btn_start(w_sensor_start),
        .btn_stop(w_sensor_stop),
        .distance(distance),
        .start_trigger(start_trigger)
    );

    fnd_controller U_Fnd_Ctrl(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode[0]),
        .sw_mode_us(sw_mode_us),
        .sw_mode_dht(sw_mode_dht),
        .sw_mode_temp(sw_mode_temp),
        .humidity(humidity),
        .temperature(temperature),
        .distance(distance),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );
    led_indicator U_Led_Indicator(
        .sw_mode({sw_mode_dht,sw_mode_us,sw_mode}),
        .led(led)
    );

endmodule


module stopwatch_top (
    input clk,
    input reset,
    input run,
    input clear,
    input uart_run,
    input uart_clear,
    input sw_mode,
    output [6:0]msec,
    output [5:0]sec,
    output [5:0]min,
    output [4:0]hour
);
    wire stopwatch_run,stopwatch_clear;
    wire w_run, w_clear;
    assign stopwatch_run = (uart_run || run) && (~sw_mode);
    assign stopwatch_clear = (uart_clear || clear) && (~sw_mode);

    stopwatch_cu U_StopWatch_CU (
        .clk(clk),
        .reset(reset),

        .i_btn_run(stopwatch_run),
        .i_btn_clear(stopwatch_clear),

        .o_run(w_run),
        .o_clear(w_clear)
    );


    stopwatch_dp U_StopWatch_DP(
        .clk(clk),
        .reset(reset),
        .run(w_run),
        .clear(w_clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
endmodule
module watch_top (
    input clk,
    input reset,
    input sw_mode,

    input btn_hour_rise,
    input btn_sec_rise,
    input btn_min_rise,

    input uart_sec_rise,
    input uart_min_rise,
    input uart_hour_rise,

    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    assign w_btn_hour_rise = (uart_hour_rise || btn_hour_rise) && sw_mode;
    assign w_btn_min_rise = (uart_min_rise || btn_min_rise) && sw_mode;
    assign w_btn_sec_rise = (uart_sec_rise || btn_sec_rise) && sw_mode;

    watch_dp U_Watch_DP(
        .clk(clk),
        .reset(reset),
        .btn_sec(w_btn_sec_rise),
        .btn_min(w_btn_min_rise),
        .btn_hour(w_btn_hour_rise),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

endmodule
module led_indicator (
    input [3:0] sw_mode,
    output reg [5:0] led
);
    parameter stopwatch_sec_ms = 4'b0000, stopwatch_hour_min = 4'b0001, 
              watch_sec_ms = 4'b0010, watch_hour_min = 4'b0011,
              us_sensor = 4'b0100, dht_sensor = 4'b1000;
    always @(*) begin
        led = 4'b0001;
        case (sw_mode)
            stopwatch_sec_ms: led = 6'b000001;
            stopwatch_hour_min: led = 6'b000010;
            watch_sec_ms: led = 6'b000100;
            watch_hour_min: led = 6'b001000;
            us_sensor: led = 6'b01000;
            dht_sensor: led =  6'b10000;
            default: led = 6'b0001;
        endcase
    end
endmodule

module data_selector (
    input sel,
    input [6:0]stopwatch_data_msec,
    input [6:0]watch_data_msec,
    input [5:0]stopwatch_data_sec,
    input [5:0]watch_data_sec,
    input [5:0]stopwatch_data_min,
    input [5:0]watch_data_min,
    input [4:0]stopwatch_data_hour,
    input [4:0]watch_data_hour,

    output [6:0]data_out_msec,
    output [5:0]data_out_sec,
    output [5:0]data_out_min,
    output [4:0]data_out_hour
 
);
    mux_2x1_mode #(.BIT_WIDTH (7)) U_Mux_2x1_msec (
        .sel(sel),
        .stopwatch_data(stopwatch_data_msec),
        .watch_data(watch_data_msec),
        .data_out(data_out_msec)
    );
    mux_2x1_mode #(.BIT_WIDTH (6)) U_Mux_2x1_sec (
        .sel(sel),
        .stopwatch_data(stopwatch_data_sec),
        .watch_data(watch_data_sec),
        .data_out(data_out_sec)
    );
    mux_2x1_mode #(.BIT_WIDTH (6)) U_Mux_2x1_min (
        .sel(sel),
        .stopwatch_data(stopwatch_data_min),
        .watch_data(watch_data_min),
        .data_out(data_out_min)
    );
    mux_2x1_mode #(.BIT_WIDTH (5)) U_Mux_2x1_hour (
        .sel(sel),
        .stopwatch_data(stopwatch_data_hour),
        .watch_data(watch_data_hour),
        .data_out(data_out_hour)
    );


endmodule
module mux_2x1_mode #(parameter BIT_WIDTH = 7)(
    input sel,
    input [BIT_WIDTH -1 : 0] stopwatch_data,
    input [BIT_WIDTH -1 : 0] watch_data,
    output [BIT_WIDTH -1 : 0] data_out
);
    assign data_out = (sel == 1'b1) ? watch_data : stopwatch_data;
endmodule