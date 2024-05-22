`timescale 1ns / 1ps

module block_gen(
    input clk,
    input one_hz_clk,
    input reset,
    input [9:0] PLAT_X_START,
    input [9:0] PLAT_Y_START,
    input [9:0] x,          // from vga controller
    input [9:0] y,          // from vga controller
    input rand_num,
    
    output plat_on,
    output [9:0] x_plat_l, x_plat_r,   // block horizontal boundary signals
    output [9:0] y_plat_t, y_plat_b,   // block vertical boundary signals 
    output [11:0] rom_data
    );
    parameter X_LEFT = 0;                  // against left wall 32
    parameter X_RIGHT = 640;                // against right wall 608
    parameter Y_TOP = 32;                   // against top areas  68
    parameter Y_BOTTOM = 448;               // against bottom wall 452
    
    parameter X_RIGHTMOST_START = 608;
    // 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
        
    parameter X_PLATFORM_SIZE = 128;
    parameter Y_PLATFORM_SIZE = 16;
    parameter PLAT_VELOCITY = 1;            // block velocity  
     
    reg [9:0] y_plat_reg;
    reg [9:0] x_plat_reg;

    wire [4:0] rand_num;

    initial begin
        y_plat_reg <= PLAT_Y_START;         // block starting position X
        x_plat_reg <= PLAT_X_START;         // block starting position Y
    end
    reg [9:0] y_plat_next = 0;   
    reg [9:0] x_plat_next = 0;     // signals for register buffer 
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
                x_plat_reg <= PLAT_X_START;
                y_plat_reg <= PLAT_Y_START;
            end
            else begin
                x_plat_reg <= x_plat_next;
                y_plat_reg <= y_plat_next;
            end
    end
    
    assign x_plat_l = x_plat_reg;
    assign x_plat_r = x_plat_reg + X_PLATFORM_SIZE - 1;
    
    assign y_plat_t = y_plat_reg;
    assign y_plat_b = y_plat_reg + Y_PLATFORM_SIZE - 1;
    
    wire plat_on;
    assign plat_on = (x_plat_l <= x) && (x <= x_plat_r) &&
                     (y_plat_t <= y) && (y <= y_plat_b);

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

     always @* begin
           y_plat_next = y_plat_reg;       // no move
           x_plat_next = x_plat_reg;       // no move
           if (refresh_tick) begin
               if (start && (x_plat_l > PLAT_VELOCITY) && (x_plat_l > (X_LEFT + PLAT_VELOCITY - 1))) begin
                   x_plat_next = x_plat_reg - PLAT_VELOCITY;   // platform moves left.
               end
               else if (start) begin
                   x_plat_next = X_RIGHTMOST_START;
                   y_plat_next = rand_num * Y_PLATFORM_SIZE;
               end
           end
   end
endmodule
