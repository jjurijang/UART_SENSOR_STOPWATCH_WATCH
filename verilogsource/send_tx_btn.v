`timescale 1ns / 1ps

module send_tx_btn(
    input clk,
    input rst,
    input btn_start,
    output tx
    );
    parameter IDLE = 0, START = 1, SEND = 2;
    wire w_btn_start, w_tx_done,start;
    reg [7:0] send_tx_data_reg, send_tx_data_next;
    reg [3:0] char_count_reg, char_count_next;
    reg [1:0] state, next;
    reg start_reg, start_next;
    assign start = start_reg || w_btn_start;
    btn_debounce U_Btn_DB_SEND_TX(
        .clk(clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(w_btn_start)
    );
    
    uart U_Uart(
        .clk(clk),
        .rst(rst),
        .btn_start(start),
        .tx_data_in(send_tx_data_reg),
        .tx(tx),
        .tx_done(w_tx_done)
    );


    // send tx ascii
    always @(posedge clk ,posedge rst) begin
        if(rst)begin
            state <= 0;
            send_tx_data_reg <= 8'h30;//"0"; 둘다 가능
            char_count_reg <= 0;
            start_reg<=0;
        end else begin
            state <= next;
            send_tx_data_reg <= send_tx_data_next;
            char_count_reg <= char_count_next;
            start_reg <= start_next;
        end
    end
    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        char_count_next = char_count_reg;
        start_next = 0;
        next = state;
        case (state)
            IDLE: begin
                char_count_next = 0;
                start_next = 0;
                if(w_btn_start == 1) begin
                    next = START;
                end else begin
                    next = IDLE;
                end
            end
            START: begin
                start_next = 0;
                if(w_tx_done) begin
                    next = SEND;
                end else begin
                    next = START;
                end
            end
            SEND: begin
                if(w_tx_done == 1'b0) begin
                    if(char_count_reg == 15) begin
                        send_tx_data_next = send_tx_data_reg+1;
                        char_count_next = 0;
                        next = IDLE;
                    end else begin
                        char_count_next = char_count_reg + 1;
                        next = START;
                        start_next = 1;
                        if (send_tx_data_reg == "z") begin
                            send_tx_data_next = "0";
                        end else begin
                            send_tx_data_next = send_tx_data_reg + 1; // increase 1 for ASCII
                        end
                    end
                
                end

            end
        endcase
    end
/*
    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        if (w_btn_start==1'b1) begin //from debounce
                if (send_tx_data_reg == "z") begin
                    send_tx_data_next = "0";
                    char_count_next = char_count_reg + 1;
                end else begin
                    send_tx_data_next = send_tx_data_reg + 1; // increase 1 for ASCII
                    char_count_next = char_count_reg + 1;
                end
                
            end
        end
*/    
endmodule
