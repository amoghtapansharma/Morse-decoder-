`timescale 1ns / 1ps
// lcd_driver.v - Simple 4-bit HD44780 LCD interface for Nexys4 DDR
// Displays incoming ASCII char on LCD (position auto-increments)

module lcd_driver(
    input  wire clk,          // 100 MHz clock
    input  wire rst,
    input  wire new_char,     // high for one clk when a new character is ready
    input  wire [7:0] char,   // ASCII to display
    output reg  lcd_rs,
    output reg  lcd_en,
    output reg  [3:0] lcd_d
);

    // timing parameters
    localparam CLK_FREQ = 100_000_000;
    localparam DELAY_2MS = CLK_FREQ / 500;     // ~2ms delay
    localparam DELAY_50US = CLK_FREQ / 20000;  // ~50us pulse width

    reg [31:0] counter;
    reg [3:0]  state;
    reg [7:0]  data_reg;
    reg [3:0]  nibble;

    localparam INIT = 0, IDLE = 1, SEND_HIGH = 2, STROBE_H = 3, SEND_LOW = 4, STROBE_L = 5, DELAY = 6;

    initial begin
        state <= INIT;
        lcd_en <= 0;
        lcd_rs <= 0;
        lcd_d <= 4'b0000;
        counter <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= INIT;
            lcd_en <= 0;
            lcd_rs <= 0;
            lcd_d <= 4'b0000;
            counter <= 0;
        end else begin
            case (state)
                INIT: begin
                    // Simple init delay (~20ms)
                    if (counter < DELAY_2MS*10)
                        counter <= counter + 1;
                    else begin
                        counter <= 0;
                        state <= IDLE;
                    end
                end

                IDLE: begin
                    lcd_en <= 0;
                    if (new_char) begin
                        data_reg <= char;
                        lcd_rs <= 1; // data
                        state <= SEND_HIGH;
                    end
                end

                SEND_HIGH: begin
                    lcd_d <= data_reg[7:4];
                    lcd_en <= 1;
                    counter <= 0;
                    state <= STROBE_H;
                end

                STROBE_H: begin
                    if (counter < DELAY_50US)
                        counter <= counter + 1;
                    else begin
                        lcd_en <= 0;
                        state <= SEND_LOW;
                        counter <= 0;
                    end
                end

                SEND_LOW: begin
                    lcd_d <= data_reg[3:0];
                    lcd_en <= 1;
                    state <= STROBE_L;
                end

                STROBE_L: begin
                    if (counter < DELAY_50US)
                        counter <= counter + 1;
                    else begin
                        lcd_en <= 0;
                        state <= DELAY;
                        counter <= 0;
                    end
                end

                DELAY: begin
                    if (counter < DELAY_2MS)
                        counter <= counter + 1;
                    else begin
                        counter <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule

