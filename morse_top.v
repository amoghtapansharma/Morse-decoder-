`timescale 1ns / 1ps
module morse_top(
    input  wire clk_100MHz,
    input  wire rst_btn,
    input  wire btn_in,
    output wire [15:0] led,

    // LCD 4-bit interface
    output wire lcd_rs,
    output wire lcd_en,
    output wire [3:0] lcd_d
);

    // --- previous logic unchanged ---
    wire btn_clean, pulse_done;
    wire [31:0] pulse_width;

    debounce #(.CTR_BITS(18)) db (.clk(clk_100MHz), .rst(rst_btn), .noisy(btn_in), .clean(btn_clean));
    pulse_timer pt (.clk(clk_100MHz), .rst(rst_btn), .btn(btn_clean),
                    .pulse_done(pulse_done), .pulse_width(pulse_width));

    wire sym_dot, sym_dash, letter_ready, word_gap;
    wire [2:0] sym_len;
    wire [7:0] sym_pat;

    morse_fsm #(.UNIT_TICKS(20000000)) fsm (
        .clk(clk_100MHz), .rst(rst_btn),
        .pulse_done(pulse_done), .pulse_width(pulse_width),
        .symbol_dot(sym_dot), .symbol_dash(sym_dash),
        .letter_ready(letter_ready), .word_gap(word_gap),
        .symbol_len(sym_len), .symbol_pattern(sym_pat)
    );

    wire [7:0] decoded;
    morse_rom rom (.len(sym_len), .pattern(sym_pat), .ascii(decoded));

    lcd_driver lcd (
        .clk(clk_100MHz),
        .rst(rst_btn),
        .new_char(letter_ready),
        .char(decoded),
        .lcd_rs(lcd_rs),
        .lcd_en(lcd_en),
        .lcd_d(lcd_d)
    );

    assign led[0] = sym_dot;
    assign led[1] = sym_dash;
    assign led[2] = letter_ready;
    assign led[3] = word_gap;

endmodule

