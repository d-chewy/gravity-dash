`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module stopwatch(
    // Outputs
    output [3:0] an,
    output [6:0] seg,
    // Inputs
    input one_hz_clk,
    input fast_hz_clk,
    input btn_hz_clk,
    input reset
    // input paused
    );

`include "clock_definitions.v"

// Display Registers
reg [3:0] numDisplay;
reg [1:0] anodeActive;
reg [3:0] an_en;
reg [6:0] seg_en;

// Score Digits
reg [3:0] dig3;
reg [3:0] dig2;
reg [3:0] dig1;
reg [3:0] dig0;

wire one_hz_clk_pe;
reg paused;
// reg paused_buf;

assign an[3:0] = an_en[3:0];
assign seg[6:0] = seg_en[6:0];

initial begin
    anodeActive = 0;
    dig3 = 0;
    dig2 = 0;
    dig1 = 0;
    dig0 = 0;
    paused = 0;
    // paused_buf = 0;
end

pos_edge_det one_hz_pe(.clk(btn_hz_clk), .sig(one_hz_clk), .pe(one_hz_clk_pe));

parameter COUNT_MAX = 4;
reg [3:0] count = 0;
reg start = 0;
    
always @(posedge one_hz_clk or posedge reset) begin
    if (reset) begin
        count <= 0;
        start <= 0;
    end else if (count == COUNT_MAX) begin
        start <= 1;
    end else begin
        count <= count + 1;
    end
end

// MAX is 59:59
always @(posedge btn_hz_clk) begin
    // paused_buf <= (paused) ? 1 : 0;
    if (reset) begin
        dig0 = 0;
        dig1 = 0;
        dig2 = 0;
        dig3 = 0;
        // paused_buf = 0;
    end
    else begin
        if (~paused & start & one_hz_clk_pe) begin
            if (dig0 == 9) begin
                dig0 <= 0;
                if (dig1 == 8) begin
                    dig1 <= 0;
                    if (dig2 == 9) begin
                        dig2 <= 0;
                        if (dig3 == 9) begin
                            dig3 <= 0;
                        end else begin
                            dig3 <= dig3 + 1;
                        end
                    end else begin
                        dig2 <= dig2 + 1;
                    end
                end else begin
                    dig1 <= dig1 + 1;
                end
            end else begin
                dig0 <= dig0 + 1;
            end
        end
    end
end
    
always @ (anodeActive, numDisplay) begin
    case (anodeActive)
        2'b00   : an_en <= 4'b1110; //An0 (Right to left)
        2'b01   : an_en <= 4'b1101; //An1
        2'b10   : an_en <= 4'b1011; //An2
        2'b11   : an_en <= 4'b0111; //An3
    endcase
    case (numDisplay)
        4'b0000 : seg_en <= 7'b1000000; // 0
        4'b0001 : seg_en <= 7'b1111001; // 1
        4'b0010 : seg_en <= 7'b0100100; // 2
        4'b0011 : seg_en <= 7'b0110000; // 3
        4'b0100 : seg_en <= 7'b0011001; // 4
        4'b0101 : seg_en <= 7'b0010010; // 5
        4'b0110 : seg_en <= 7'b0000010; // 6
        4'b0111 : seg_en <= 7'b1111000; // 7
        4'b1000 : seg_en <= 7'b0000000; // 8
        4'b1001 : seg_en <= 7'b0010000; // 9
        
        4'b1010 : seg_en <= blank; // IF 10 - SHOW BLANK (USED FOR BLINKING)
    endcase
end // end always@()

always @ (posedge fast_hz_clk) begin
    anodeActive = anodeActive + 1;
        case (anodeActive)
            2'b00   : numDisplay = dig0;
            2'b01   : numDisplay = dig1;
            2'b10   : numDisplay = dig2;
            2'b11   : numDisplay = dig3;
        endcase
end
endmodule