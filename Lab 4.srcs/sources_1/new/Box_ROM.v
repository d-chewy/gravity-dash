`timescale 1ns / 1ps

module Box_ROM
    (
        input wire clk,
        input wire [4:0] row,
        input wire [4:0] col,
        output reg [11:0] color_data
    );

    (* rom_style = "block" *)

    //signal declaration
    reg [4:0] row_reg;
    reg [4:0] col_reg;

    always @(posedge clk)
        begin
        row_reg <= row;
        col_reg <= col;
        end

    always @*
        case ({row_reg, col_reg})
            default: color_data = 12'b111111111111;
        endcase
endmodule