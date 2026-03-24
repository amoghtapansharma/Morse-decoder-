`timescale 1ns / 1ps
// pulse_timer.v
// Measures how many clock cycles the (debounced) button is high
module pulse_timer(
    input  wire clk,
    input  wire rst,
    input  wire btn,          // debounced, active-high when pressed
    output reg  pulse_done,   // goes high for one cycle when a press ends
    output reg  [31:0] pulse_width
);
    reg [31:0] counter;
    reg btn_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            btn_prev <= 0;
            pulse_done <= 0;
            pulse_width <= 0;
        end else begin
            pulse_done <= 0;
            if (btn) begin
                counter <= counter + 1;
            end
            if (~btn & btn_prev) begin
                // falling edge -> button released
                pulse_done <= 1;
                pulse_width <= counter;
                counter <= 0;
            end
            if (~btn) counter <= 0; // keep clear when not pressed
            btn_prev <= btn;
        end
    end
endmodule
