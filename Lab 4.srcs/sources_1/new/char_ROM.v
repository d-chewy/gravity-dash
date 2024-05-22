`timescale 1ns / 1ps

module char_ROM
    (
        input wire clk,
        input x, y,
        output reg text_on
    );

    (* rom_style = "block" *)

    //signal declaration
    reg [9:0] x_reg;
    reg [9:0] y_reg;
    initial begin
        text_on = 0;
    end
    always @(posedge clk)
        begin
        x_reg <= x;
        y_reg <= y;
        end

    always @* begin
        if (x_reg > 200) begin
            text_on = 1;
        end else begin
            text_on = 0;
        end
//        case ({x, y})
//            20'd153600 : text_on = 1;
//            20'd153601 : text_on = 1;
//            20'd153602 : text_on = 1;
//            20'd153603 : text_on = 1;
//            20'd153604 : text_on = 1;
//            20'd153605 : text_on = 1;
//            20'd153606 : text_on = 1;
//            20'd153607 : text_on = 1;
//            20'd153608 : text_on = 1;
//            20'd153609 : text_on = 1;
//            20'd154112 : text_on = 1;
//            20'd154113 : text_on = 1;
//            20'd154114 : text_on = 1;
//            20'd154115 : text_on = 1;
//            20'd154116 : text_on = 1;
//            20'd154117 : text_on = 1;
//            20'd154118 : text_on = 1;
//            20'd154119 : text_on = 1;
//            20'd154120 : text_on = 1;
            
//        endcase
    end
endmodule