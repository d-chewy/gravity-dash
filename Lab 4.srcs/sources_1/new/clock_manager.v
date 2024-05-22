`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module clock_manager(
    // Outputs
    output one_hz_clk,
    output fast_hz_clk,
    output btn_hz_clk,
    // Inputs
    input clk
    );
 
`include "clock_definitions.v"

reg [25:0] clk_div_one; //26 bits to get to 50 million
reg [19:0] clk_div_fast;
reg [23:0] clk_div_btn;

reg one_hz_clk_reg;
reg fast_hz_clk_reg;
reg btn_hz_clk_reg;

initial begin
    clk_div_one = 1;
    clk_div_fast = 1;
    clk_div_btn = 1;

    one_hz_clk_reg = 0;
    fast_hz_clk_reg = 0;
    btn_hz_clk_reg = 0;
end

// 1 Hz Clock Divider
always @(posedge clk) begin
    if (clk_div_one == oneHz) begin
        one_hz_clk_reg <= ~one_hz_clk_reg;
        clk_div_one <= 1;
    end else begin
        clk_div_one <= clk_div_one + 1;
    end
end

// Seven Segment Display Clock
always @(posedge clk) begin
    if (clk_div_fast == fastHz) begin
        fast_hz_clk_reg <= ~fast_hz_clk_reg;
        clk_div_fast <= 1;
    end else begin
        clk_div_fast <= clk_div_fast + 1;
    end
end

// Sampling clock for buttons
always @(posedge clk) begin
    if (clk_div_btn == btnHz) begin
        btn_hz_clk_reg <= ~btn_hz_clk_reg;
        clk_div_btn <= 1;
    end else begin
        clk_div_btn <= clk_div_btn + 1;
    end
end

assign one_hz_clk = one_hz_clk_reg;
assign fast_hz_clk = fast_hz_clk_reg;
assign btn_hz_clk = btn_hz_clk_reg;

endmodule