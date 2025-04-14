`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input sw_mode, //min_hour or msec_sec
    input sw_mode_us, //us
    input sw_mode_dht, //dht
    input sw_mode_temp, //dht_temp or humidity

    input [15:0] humidity,
    input [15:0] temperature,

    input [9:0]distance,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);
    // assign seg_comm = 4'b0000; // segment 0의 자리 on, seg는 anode type.
    
    wire [3:0] w_bcd, w_digit_msec_1, w_digit_msec_10,
                      w_digit_sec_1, w_digit_sec_10,
                      w_digit_min_1, w_digit_min_10,
                      w_digit_hour_1, w_digit_hour_10,
                      w_digit_dist_1, w_digit_dist_10,
                      w_digit_dist_100, w_digit_dist_1000,
                       w_int_humidity_1,w_int_humidity_10,
                      w_dec_humidity_1,w_dec_humidity_10,
                      w_int_temp_1, w_int_temp_10,
                      w_dec_temp_1, w_dec_temp_10;
    wire [3:0] w_digit_dist;
    wire [2:0] w_seg_sel;
    wire w_clk_100hz;
    wire [3:0] w_msec_sec, w_min_hour, w_dot,w_temp, w_humidity ;
    clk_divider U_Clk_Divider(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    counter_8 U_counter_8(
        .clk(w_clk_100hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );

    decoder_3x8 U_decoder (
        .seg_sel (w_seg_sel),
        .seg_comm(fnd_comm)
    );

    //
    digit_splitter #(.BIT_WIDTH(7)) U_Msec_ds(
    .bcd(msec),
    .digit_1(w_digit_msec_1),
    .digit_10(w_digit_msec_10)
    );
    digit_splitter #(.BIT_WIDTH(6)) U_Sec_ds(
    .bcd(sec),
    .digit_1(w_digit_sec_1),
    .digit_10(w_digit_sec_10)
    );
    digit_splitter #(.BIT_WIDTH(6)) U_Min_ds(
    .bcd(min),
    .digit_1(w_digit_min_1),
    .digit_10(w_digit_min_10)
    );
    digit_splitter #(.BIT_WIDTH(5)) U_Hour_ds(
    .bcd(hour),
    .digit_1(w_digit_hour_1),
    .digit_10(w_digit_hour_10)
    );
    digit_splitter_dist #(.BIT_WIDTH(10)) U_dist_ds(
        .bcd(distance),
        .digit_1(w_digit_dist_1),
        .digit_10(w_digit_dist_10),
        .digit_100(w_digit_dist_100),
        .digit_1000(w_digit_dist_1000)
    );

    digit_splitter #(.BIT_WIDTH(8)) U_int_humidity_ds(
        .bcd(humidity[15:8]),
        .digit_1(w_int_humidity_1),
        .digit_10(w_int_humidity_10)
    );
    digit_splitter #(.BIT_WIDTH(8)) U_dec_humidity_ds(
        .bcd(humidity[7:0]),
        .digit_1(w_dec_humidity_1),
        .digit_10(w_dec_humidity_10)
    );
    digit_splitter #(.BIT_WIDTH(8)) U_int_temp_ds(
        .bcd(temperature[15:8]),
        .digit_1(w_int_temp_1),
        .digit_10(w_int_temp_10)
    );
    digit_splitter #(.BIT_WIDTH(8)) U_dec_temp_ds(
        .bcd(temperature[7:0]),
        .digit_1(w_dec_temp_1),
        .digit_10(w_dec_temp_10)
    );

    comparator_msec U_Comp_dot(
        .msec(msec),
        .dot(w_dot)
    );

        mux_8x1 U_Mux_8x1_humidity(
        .sel(w_seg_sel),
        .x0(w_dec_humidity_1),
        .x1(w_dec_humidity_10),
        .x2(w_int_humidity_1),
        .x3(w_int_humidity_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(4'he),
        .x7(4'hf),
        .y(w_humidity)
    );
    mux_8x1 U_Mux_8x1_temperature(
        .sel(w_seg_sel),
        .x0(w_dec_temp_1),
        .x1(w_dec_temp_10),
        .x2(w_int_temp_1),
        .x3(w_int_temp_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(4'he),
        .x7(4'hf),
        .y(w_temp)
    );

    mux_8x1 U_Mux_8x1_dist(
        .sel(w_seg_sel),
        .x0(w_digit_dist_1),
        .x1(w_digit_dist_10),
        .x2(w_digit_dist_100),
        .x3(w_digit_dist_1000),
        .x4(w_digit_dist_1),
        .x5(w_digit_dist_10),
        .x6(w_digit_dist_100),
        .x7(w_digit_dist_1000),
        .y(w_digit_dist)
    );

    mux_8x1 U_Mux_8x1_msec_sec(
        .sel(w_seg_sel),
        .x0(w_digit_msec_1),
        .x1(w_digit_msec_10),
        .x2(w_digit_sec_1),
        .x3(w_digit_sec_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(w_dot),
        .x7(4'hf),
        .y(w_msec_sec)
    );
    mux_8x1 U_Mux_8x1_min_hour(
        .sel(w_seg_sel),
        .x0(w_digit_min_1),
        .x1(w_digit_min_10),
        .x2(w_digit_hour_1),
        .x3(w_digit_hour_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(w_dot),
        .x7(4'hf),
        .y(w_min_hour)
    );
    mux_5x1 U_Mux_5x1(
        .sel({sw_mode_temp,sw_mode_dht,sw_mode_us,sw_mode}),
        .x0(w_msec_sec),
        .x1(w_min_hour),
        .x2(w_digit_dist),
        .x3(w_humidity),
        .x4(w_temp),
        .y(w_bcd)
    );

    bcdtoseg U_bcdtoseg (
    .bcd(w_bcd),  // [3:0] sum 값
    .seg(fnd_font)
    );
endmodule

module clk_divider (
    input clk,
    input reset,
    output o_clk

);
    // $clog2 : 수를 나타내는데 필요한 비트 수 계산
    parameter FCOUNT  = 250_000; // 이름을 상수화하여 사용
    reg [$clog2(FCOUNT):0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 1'b0;
        end else begin
            if(r_counter == FCOUNT -1 ) begin //clk divide 계산 100M -> 10hz
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end

        end

    end
endmodule



module counter_8 (
    input clk,
    input reset,
    output [2:0] o_sel
);
    reg [2:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
    
endmodule



module decoder_3x8 (
    input [2:0] seg_sel,
    output reg [3:0] seg_comm
);
    always @(*) begin
        case (seg_sel)
            3'b000:   seg_comm = 4'b1110;
            3'b001:   seg_comm = 4'b1101;
            3'b010:   seg_comm = 4'b1011;
            3'b011:   seg_comm = 4'b0111;
            3'b100:   seg_comm = 4'b1110;
            3'b101:   seg_comm = 4'b1101;
            3'b110:   seg_comm = 4'b1011;
            3'b111:   seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end
endmodule

module digit_splitter #(parameter BIT_WIDTH = 7)(
    input [BIT_WIDTH - 1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1 = bcd % 10; //10의 1의 자리
    assign digit_10 = bcd / 10 % 10; //10의 10의 자리

endmodule
module digit_splitter_dist #(parameter BIT_WIDTH = 10)(
    input [BIT_WIDTH - 1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0]digit_100,
    output [3:0]digit_1000
);
    assign digit_1 = bcd % 10; //10의 1의 자리
    assign digit_10 = bcd / 10 % 10; //10의 10의 자리
    assign digit_100 = bcd / 100 % 10;
    assign digit_1000 = bcd / 1000 % 10;
endmodule

module mux_5x1 (
    input [3:0]sel,
    input [3:0] x0, //msec_sec
    input [3:0] x1, //min_hour
    input [3:0] x2, //us dist
    input [3:0] x3, //dht_humidity
    input [3:0] x4, //dht_temp
    output reg [3:0] y 
);
    //sel = {sw_mode_temp,sw_mode_dht,sw_mode_us,sw_mode[1:0]}
    always @(*) begin
        case (sel)
            4'b00_00: y = x0; //msec_sec
            4'b00_01: y = x1; //min_hour
            4'b00_10: y = x2; // dist
            4'b01_00: y = x3; //dht_hu
            4'b11_00: y = x4; //dht_temp
            default: y = 4'hf;
        endcase
    end
endmodule

module mux_8x1 (
    input [2:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    input [3:0] x4,
    input [3:0] x5,
    input [3:0] x6,
    input [3:0] x7,
    output reg [3:0] y
);
    always @(*) begin
        case (sel)
            3'b000: y=x0;
            3'b001: y=x1;
            3'b010: y=x2;
            3'b011: y=x3;
            3'b100: y=x4;
            3'b101: y=x5;
            3'b110: y=x6;
            3'b111: y=x7;
            default: y=4'hf;
        endcase
        
    end
endmodule
/*
module mux_4x1 (
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output [3:0] bcd // output reg [3:0] bcd로 하면 밑에서 reg 안해도 됨
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    // * : input 모두 감시, 아니면 개별 입력 선택 가능
    // always : 항상 감시한다 @이벤트 이하를 ()의 변화가 있으면, begin - end를 수행한다
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin // always 안에서는 assign 사용 불가
        case (sel)
            2'b00: r_bcd = digit_1;
            2'b01: r_bcd = digit_10;
            2'b10: r_bcd = digit_100;
            2'b11: r_bcd = digit_1000;
            default: r_bcd = 4'bx;
        endcase
    end

endmodule
*/



module bcdtoseg (
    input [3:0] bcd,     // [3:0] sum 값
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hC0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hF8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'hA: seg = 8'h88;
            4'hB: seg = 8'h83;
            4'hC: seg = 8'hC6;
            4'hD: seg = 8'hA1;
            4'hE: seg = 8'h7f;
            4'hF: seg = 8'hff;
            default: seg = 8'hff;
        endcase
    end

endmodule


module comparator_msec (
    input [6:0] msec,
    output [3:0] dot
);
    assign dot = (msec < 50) ? 4'hE : 4'hF ; // dot on, off

endmodule