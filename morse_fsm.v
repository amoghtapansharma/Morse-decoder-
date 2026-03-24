`timescale 1ns / 1ps
// morse_fsm.v
// Assembles dot/dash inputs (from pulse_timer) into a pattern and triggers decode on letter gap.

module morse_fsm #(
    parameter integer UNIT_TICKS = 20000000  // 200 ms @100MHz = 20,000,000 ticks (tuneable)
) (
    input  wire clk,
    input  wire rst,
    input  wire pulse_done,           // one-cycle pulse when button released
    input  wire [31:0] pulse_width,   // width in ticks
    output reg  symbol_dot,           // high for one cycle when dot detected
    output reg  symbol_dash,          // high for one cycle when dash detected
    output reg  letter_ready,         // high for one cycle when we have a complete letter
    output reg  word_gap,             // high for one cycle when word gap
    output reg  [2:0] symbol_len,
    output reg  [7:0] symbol_pattern
);
    // internal
    reg [31:0] idle_counter;
    reg collecting;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            idle_counter <= 0;
            collecting <= 0;
            symbol_len <= 0;
            symbol_pattern <= 0;
            symbol_dot <= 0;
            symbol_dash <= 0;
            letter_ready <= 0;
            word_gap <= 0;
        end else begin
            symbol_dot <= 0;
            symbol_dash <= 0;
            letter_ready <= 0;
            word_gap <= 0;

            // If a pulse (button press) finished
            if (pulse_done) begin
                idle_counter <= 0;
                collecting <= 1;
                // classify dot/dash: dot if < 2*UNIT, dash otherwise
                if (pulse_width < (UNIT_TICKS * 2)) begin
                    // dot
                    symbol_dot <= 1;
                    // push dot bit (1) into pattern LSB-first
                    symbol_pattern <= { symbol_pattern[7:1], 1'b1 }; // shift left and insert at LSB? (we'll use LSB-first)
                    symbol_pattern <= (symbol_pattern << 1) | 8'b00000001; // careful; some tools may prefer the previous
                    symbol_len <= symbol_len + 1;
                end else begin
                    // dash
                    symbol_dash <= 1;
                    // dash = 0 stored in pattern (LSB-first)
                    symbol_pattern <= (symbol_pattern << 1); // appends 0
                    symbol_len <= symbol_len + 1;
                end
            end else begin
                // no pulse finished; increase idle counter to decide gap
                if (idle_counter < 32'h7FFFFFFF) idle_counter <= idle_counter + 1;
            end

            // check for letter gap (> 3*UNIT) or word gap (>7*UNIT)
            if (collecting && (idle_counter > (UNIT_TICKS * 3))) begin
                // end of letter
                letter_ready <= 1;
                collecting <= 0;
                idle_counter <= 0;
            end
            if (!collecting && (idle_counter > (UNIT_TICKS * 7))) begin
                // word gap
                word_gap <= 1;
                idle_counter <= 0;
            end
        end
    end
endmodule

