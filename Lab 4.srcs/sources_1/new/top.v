`timescale 1ns / 1ps

module top(
    input clk_100MHz,       // 100MHz on Basys 3
    input reset,            // btnC
    input wire up,               // btnU
    input wire down,             // btnD
	output [6:0] seg,
    output [3:0] an,
    output hsync,           // to VGA connector
    output vsync,           // to VGA connector
    output [11:0] rgb       // to DAC, to VGA connector
    );
    
    // Module connection signals
    wire w_reset, w_up, w_down;
    wire w_video_on, w_p_tick;
    wire [9:0] w_x, w_y;
    wire one_hz_clk, fast_hz_clk, btn_hz_clk;
    // wire w_gameOver;
    // RGB buffer signals
    reg [11:0] rgb_reg;
    wire[11:0] rgb_next;
    // Instantiated modules
    btn_debounce d_rst(.clk(btn_hz_clk), .btn(reset), .btn_out(w_reset));
    btn_debounce d_up(.clk(btn_hz_clk), .btn(up), .btn_out(w_up));
    btn_debounce d_down(.clk(btn_hz_clk), .btn(down), .btn_out(w_down));
    
    vga_controller vga(.clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_video_on), 
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
                       
    pixel_gen pg(.clk(clk_100MHz), .reset(w_reset), .up(w_up), .down(w_down), 
                .video_on(w_video_on), .p_tick(w_p_tick), .x(w_x), .y(w_y), .rgb(rgb_next), 
                .one_hz_clk(one_hz_clk), .btn_hz_clk(btn_hz_clk));
    
    clock_manager clk_mgr(.clk(clk_100MHz), .one_hz_clk(one_hz_clk), .fast_hz_clk(fast_hz_clk), .btn_hz_clk(btn_hz_clk));          
    
    stopwatch score(.one_hz_clk(one_hz_clk), .fast_hz_clk(fast_hz_clk), .btn_hz_clk(btn_hz_clk), .reset(w_reset), 
                    .an(an), .seg(seg));
                 
         
    // RGB buffer             
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule