`timescale 1ns / 1ps
// debounce.v
// Simple synchronous debounce: output rises only after stable input for N cycles

module debounce #(
    parameter integer CTR_BITS = 20
) (
    input  wire clk,
    input  wire rst,
    input  wire noisy,
    output reg  clean
);
    reg [CTR_BITS-1:0] ctr;
    reg last;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ctr <= 0;
            last <= 0;
            clean <= 0;
        end else begin
            if (noisy == last) begin
                if (ctr != {CTR_BITS{1'b1}}) ctr <= ctr + 1;
                else clean <= noisy;
            end else begin
                ctr <= 0;
                last <= noisy;
            end
        end
    end
endmodule

