`timescale 1ns / 1ps
// morse_rom.v
module morse_rom(
    input  wire [2:0] len,       // up to 7 symbols
    input  wire [7:0] pattern,   // LSB-first encoding of dot/dash (1=dot,0=dash)
    output reg  [7:0] ascii
);

    always @(*) begin
        ascii = 8'h3F; // default '?'
        case ({len, pattern})
            // Letters (examples). Format: {len, pattern}
            // A: .-  => len=2, pattern LSB-first: 1 (dot), then 0 (dash) => pattern=2'b01
            {3'd2, 8'b00000001}: ascii = "A"; // .-
            // B: -... => dash, dot, dot, dot => bits LSB-first: 0,1,1,1 => 4'b1110
            {3'd4, 8'b00001110}: ascii = "B"; // -...
            {3'd4, 8'b00001010}: ascii = "C"; // -.-. (LSB-first: 0,1,0,1 => 1010 -> 0x0A)
            {3'd1, 8'b00000001}: ascii = "E"; // .
            {3'd3, 8'b00000111}: ascii = "S"; // ...
            {3'd3, 8'b00000100}: ascii = "O"; // --- (0,0,0 -> LSB-first 000 -> 0x00, but length=3 matches)
            // Quick note: for patterns that are multiple zeros you must ensure correct bit placement.
            // We'll add a reliable full table below (common letters and numbers).
            // Full table entries:
            {3'd2, 8'b00000001}: ascii = "A"; // .-
            {3'd4, 8'b00001110}: ascii = "B"; // -...
            {3'd4, 8'b00001010}: ascii = "C"; // -.-.
            {3'd3, 8'b00000110}: ascii = "D"; // -..
            {3'd1, 8'b00000001}: ascii = "E"; // .
            {3'd4, 8'b00001101}: ascii = "F"; // ..-.
            {3'd3, 8'b00000000}: ascii = "G"; // --.
            {3'd4, 8'b00001111}: ascii = "H"; // ....
            {3'd2, 8'b00000011}: ascii = "I"; // ..
            {3'd4, 8'b00000100}: ascii = "J"; // .---
            {3'd3, 8'b00000101}: ascii = "K"; // -.-
            {3'd4, 8'b00000111}: ascii = "L"; // .-..
            {3'd2, 8'b00000000}: ascii = "M"; // --
            {3'd2, 8'b00000010}: ascii = "N"; // -.
            {3'd3, 8'b00000000}: ascii = "O"; // ---
            {3'd4, 8'b00000101}: ascii = "P"; // .--.
            {3'd4, 8'b00001001}: ascii = "Q"; // --.-
            {3'd3, 8'b00000111}: ascii = "R"; // .-.
            {3'd3, 8'b00000111}: ascii = "S"; // ...
            {3'd1, 8'b00000000}: ascii = "T"; // -
            {3'd3, 8'b00000101}: ascii = "U"; // ..-
            {3'd3, 8'b00001111}: ascii = "V"; // ...-
            {3'd3, 8'b00000100}: ascii = "W"; // .--
            {3'd4, 8'b00001011}: ascii = "X"; // -..-
            {3'd4, 8'b00001001}: ascii = "Y"; // -.--
            {3'd4, 8'b00001110}: ascii = "Z"; // --..
            // Numbers (0-9)
            {3'd5, 8'b00000000}: ascii = "0"; // -----
            {3'd5, 8'b00000001}: ascii = "1"; // .----
            {3'd5, 8'b00000011}: ascii = "2"; // ..---
            {3'd5, 8'b00000111}: ascii = "3"; // ...--
            {3'd5, 8'b00001111}: ascii = "4"; // ....-
            {3'd5, 8'b00011111}: ascii = "5"; // .....
            {3'd5, 8'b00011110}: ascii = "6"; // -....
            {3'd5, 8'b00011100}: ascii = "7"; // --...
            {3'd5, 8'b00011000}: ascii = "8"; // ---..
            {3'd5, 8'b00010000}: ascii = "9"; // ----.
            default: ascii = 8'h3F; // '?'
        endcase
    end
endmodule
