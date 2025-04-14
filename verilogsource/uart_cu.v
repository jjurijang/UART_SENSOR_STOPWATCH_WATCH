`timescale 1ns / 1ps


module uart_cu(
    input clk,
    input rst,
    input [7:0] data,
    output uart_run,
    output uart_clear,
    output uart_sec_rise,
    output uart_min_rise,
    output uart_hour_rise,
    output uart_us_run,
    output uart_us_stop,
    output uart_dht_run,
    output uart_dht_stop
        );
uart_us_cu U_US_UART_CU(
    .clk(clk),
    .rst(rst),
    .data(data),
    .uart_run(uart_us_run),
    .uart_stop(uart_us_stop)
);
uart_us_cu U_DHT_UART_CU(
    .clk(clk),
    .rst(rst),
    .data(data),
    .uart_run(uart_dht_run),
    .uart_stop(uart_dht_stop)
);

    uart_time_rise_cu U_WA_UART_CU(
        .clk(clk),
        .rst(rst),
        .data(data),
        .uart_sec_rise(uart_sec_rise),
        .uart_min_rise(uart_min_rise),
        .uart_hour_rise(uart_hour_rise)
    );
    uart_run_clear_cu U_ST_UART_CU(
        .clk(clk),
        .rst(rst),
        .data(data),
        .uart_run(uart_run),
        .uart_clear(uart_clear)
    );

endmodule

module uart_time_rise_cu (
    input clk,
    input rst,
    input [7:0] data,
    output reg uart_sec_rise,
    output reg uart_min_rise,
    output reg uart_hour_rise
);
    always @(posedge clk ,posedge rst) begin
        if(rst) begin
            uart_sec_rise   <= 0;
            uart_min_rise   <= 0;
            uart_hour_rise  <= 0;
        end else if (data =="H" || data =="h")begin
            uart_sec_rise   <= 0;
            uart_min_rise   <= 0;
            uart_hour_rise <= 1'b1;
        end else if (data == "M"|| data == "m") begin
            uart_sec_rise   <= 0;
            uart_min_rise <= 1'b1;
            uart_hour_rise  <= 0;
        end else if (data == "S" || data == "s") begin
            uart_sec_rise <= 1'b1;
            uart_min_rise   <= 0;
            uart_hour_rise  <= 0;

        end else begin
            uart_sec_rise   <= 0;
            uart_min_rise   <= 0;
            uart_hour_rise  <= 0;
        end
    end
endmodule
    
module uart_run_clear_cu (
    input clk,
    input rst,
    input [7:0] data,
    output uart_run,
    output uart_clear
);
    localparam IDLE = 0, RUN_STOP = 1, CLEAR = 2;
    reg [1:0] state, next;
    reg run_reg, run_next, clear_reg, clear_next;
    assign uart_run = run_reg;
    assign uart_clear = clear_reg;
    always @(posedge clk ,posedge rst) begin
        if(rst) begin
            state <= 0;
            run_reg <= 0;
            clear_reg <= 0;
        end else begin
            state <= next;
            run_reg <= run_next;
            clear_reg <= clear_next;
        end
    end

    always @(*) begin
        next = state;
        run_next = 0;
        clear_next = 0;
        case (state)
            IDLE: begin
                if(data == "R"|| data == "r") begin
                    next = RUN_STOP;
                    run_next = 1'b1;
                end else if(data == "C"|| data == "c")begin
                    next = CLEAR;
                    clear_next = 1'b1;
                end else begin
                    run_next = 0;
                    clear_next = 0;
                end
            end
            RUN_STOP: begin
                next = IDLE;
                run_next = 0;
            end
            CLEAR: begin
                next = IDLE;
                clear_next = 0;
            end
        endcase
    end

endmodule

module uart_us_cu (
    input clk,
    input rst,
    input [7:0] data,
    output uart_run,
    output uart_stop
);
    localparam IDLE = 0, RUN_STOP = 1, CLEAR = 2;
    reg [1:0] state, next;
    reg run_reg, run_next, clear_reg, clear_next;
    assign uart_run = run_reg;
    assign uart_stop = clear_reg;
    always @(posedge clk ,posedge rst) begin
        if(rst) begin
            state <= 0;
            run_reg <= 0;
            clear_reg <= 0;
        end else begin
            state <= next;
            run_reg <= run_next;
            clear_reg <= clear_next;
        end
    end

    always @(*) begin
        next = state;
        run_next = 0;
        clear_next = 0;
        case (state)
            IDLE: begin
                if(data == "R"|| data == "r") begin
                    next = RUN_STOP;
                    run_next = 1'b1;
                end else if(data == "S"|| data == "s")begin
                    next = CLEAR;
                    clear_next = 1'b1;
                end else begin
                    run_next = 0;
                    clear_next = 0;
                end
            end
            RUN_STOP: begin
                next = IDLE;
                run_next = 0;
            end
            CLEAR: begin
                next = IDLE;
                clear_next = 0;
            end
        endcase
    end

endmodule