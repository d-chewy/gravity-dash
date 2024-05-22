`timescale 1ns / 1ps

module pixel_gen(
    input clk,              // 100MHz
    input one_hz_clk,       // 1Hz
    input btn_hz_clk,
    input reset,            // btnC
    input wire up,          // btnU
    input wire down,        // btnD
    input [9:0] x,          // from vga controller
    input [9:0] y,          // from vga controller
    input video_on,         // from vga controller
    input p_tick,           // 25MHz from vga controller
    
    output reg [11:0] rgb  // to DAC, to vga connector
    // output gameOver
    );
    
    // 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)

 // ********************************************************************************
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // FROG
    // square rom boundaries
    parameter BLOCK_SIZE = 32;
    parameter X_START = 288;                // starting x position - left rom edge centered horizontally
    parameter Y_START = 0;                // starting y position - centered in lower yellow area vertically
    
    reg hit_edge;       // LOSE CONDITION
    // assign gameOver = hit_edge;
    
    // Gameboard boundaries. UNNECESSARY SINCE OUR BOUNDARIES CAN BE EDGE OF DISPLAY
    parameter X_LEFT = 0;                   // against left wall 32
    parameter X_RIGHT = 640;                // against right wall 608
    parameter Y_TOP = 0;                    // against top areas  68
    parameter Y_BOTTOM = 480;               // against bottom wall 452
    // block boundary signals
    wire [9:0] x_block_l, x_block_r;        // block horizontal boundary signals
    wire [9:0] y_block_t, y_block_b;        // block vertical boundary signals  
    reg [9:0] y_block_reg, x_block_reg;     // block position
    wire [9:0] y_block_next, x_block_next;  // next cycle block position
    reg [9:0] y_delta_reg, y_delta_next;        
    reg [9:0] x_delta_reg, x_delta_next;
    parameter BLOCK_VELOCITY = 2;           // block velocity  
    parameter BLOCK_VELOCITY_NEG = -2;

    reg hasFlip;        // HAS ABILITY
    reg grav; 

    wire [3:0] rand_num;

    initial begin
        x_block_reg = X_START;
        y_block_reg = Y_START;
        grav = 0;       // default: gravity points down
        hasFlip = 1;
    end

    // Register Control
    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            x_block_reg <= X_START;
            y_block_reg <= Y_START;
        end
        else begin
            x_block_reg <= x_block_next;
            y_block_reg <= y_block_next;
        end
    end
    
    // **** ROM BOUNDARIES / STATUS SIGNALS ****

    assign x_block_l = x_block_reg;
    assign x_block_r = x_block_reg + BLOCK_SIZE - 1;
    
    assign y_block_t = y_block_reg;
    assign y_block_b = y_block_reg + BLOCK_SIZE - 1;

    // rom object status signal
    wire block_on;
                    
    // pixel within rom square boundaries
    assign block_on = (x_block_l <= x) && (x <= x_block_r) &&
                     (y_block_t <= y) && (y <= y_block_b);
    
    // **** Platform generation/graphics ****
    // Generate random number
    LFSR rand(.clock(btn_hz_clk), .reset(reset), .rnd(rand_num));

    wire [4:0] plat_on;
    wire [9:0] plat0_x_l, plat0_x_r, plat0_y_t, plat0_y_b;
    wire [9:0] plat1_x_l, plat1_x_r, plat1_y_t, plat1_y_b;
    wire [9:0] plat2_x_l, plat2_x_r, plat2_y_t, plat2_y_b;
    wire [9:0] plat3_x_l, plat3_x_r, plat3_y_t, plat3_y_b;
    wire [9:0] plat4_x_l, plat4_x_r, plat4_y_t, plat4_y_b;

    block_gen plat0(.clk(clk), .reset(reset), .PLAT_X_START(640), .PLAT_Y_START(64),
                    .rom_data(rom_data), .plat_on(plat_on[0]), .rand_num(rand_num),
                    .x_plat_l(plat0_x_l), .x_plat_r(plat0_x_r), .y_plat_t(plat0_y_t), .y_plat_b(plat0_y_b),
                    .x(x), .y(y), .one_hz_clk(one_hz_clk));
    block_gen plat1(.clk(clk), .reset(reset), .PLAT_X_START(512), .PLAT_Y_START(64),
                    .rom_data(rom_data), .plat_on(plat_on[1]), .rand_num(rand_num),
                    .x_plat_l(plat1_x_l), .x_plat_r(plat1_x_r), .y_plat_t(plat1_y_t), .y_plat_b(plat1_y_b),
                    .x(x), .y(y), .one_hz_clk(one_hz_clk));
    block_gen plat2(.clk(clk), .reset(reset), .PLAT_X_START(384), .PLAT_Y_START(64),
                    .rom_data(rom_data), .plat_on(plat_on[2]), .rand_num(rand_num),
                    .x_plat_l(plat2_x_l), .x_plat_r(plat2_x_r), .y_plat_t(plat2_y_t), .y_plat_b(plat2_y_b),
                    .x(x), .y(y), .one_hz_clk(one_hz_clk));
    block_gen plat3(.clk(clk), .reset(reset), .PLAT_X_START(256), .PLAT_Y_START(64),
                    .rom_data(rom_data), .plat_on(plat_on[3]), .rand_num(rand_num),
                    .x_plat_l(plat3_x_l), .x_plat_r(plat3_x_r), .y_plat_t(plat3_y_t), .y_plat_b(plat3_y_b),
                    .x(x), .y(y), .one_hz_clk(one_hz_clk));
    block_gen plat4(.clk(clk), .reset(reset), .PLAT_X_START(128), .PLAT_Y_START(64),
                    .rom_data(rom_data), .plat_on(plat_on[4]), .rand_num(rand_num),
                    .x_plat_l(plat4_x_l), .x_plat_r(plat4_x_r), .y_plat_t(plat4_y_t), .y_plat_b(plat4_y_b),
                    .x(x), .y(y), .one_hz_clk(one_hz_clk));
   
    // **** Player gravity controls *****
    reg hasFlip_reg;
    always @(posedge clk) begin
        hasFlip <= hasFlip_reg;
        if (up && hasFlip) begin
            grav <= 0;
            hasFlip <= 0;
        end else if (down && hasFlip) begin
            grav <= 1;
            hasFlip <= 0;
        end else if (reset) begin
            grav <= 1;
            hasFlip <= 1;
        end 
    end

    assign y_block_next = (refresh_tick) ? y_block_reg + y_delta_next : y_block_reg;
    assign x_block_next = (refresh_tick) ? x_block_reg + x_delta_next : x_block_reg;

    reg y_blocked;
    always @* begin
        // y_block_next = y_block_reg;       // no move
        // x_block_next = x_block_reg;       // no move
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        if (refresh_tick) begin
            if ((plat0_x_l <= x_block_r) && (plat0_x_r >= x_block_l) && (plat0_y_t <= y_block_b) && (plat0_y_b >= y_block_t)) begin
                // y_delta_next = 0;
                hasFlip_reg <= 1;
                y_blocked = ((plat0_y_t >= y_block_t) && (plat0_y_b <= y_block_b)) ? 0 : 1;
                x_delta_next = ((plat0_y_t >= y_block_t) && (plat0_y_b <= y_block_b)) ? -1 : x_delta_next;
            end
            else if ((plat1_x_l <= x_block_r) && (plat1_x_r >= x_block_l) && (plat1_y_t <= y_block_b) && (plat1_y_b >= y_block_t)) begin
                // y_delta_next = 0;
                hasFlip_reg <= 1;
                y_blocked = ((plat1_y_t >= y_block_t) && (plat1_y_b <= y_block_b)) ? 0 : 1;
                x_delta_next = ((plat1_y_t >= y_block_t) && (plat1_y_b <= y_block_b)) ? -1 : x_delta_next; 
            end
            else if ((plat2_x_l <= x_block_r) && (plat2_x_r >= x_block_l) && (plat2_y_t <= y_block_b) && (plat2_y_b >= y_block_t)) begin
                // y_delta_next = 0;
                hasFlip_reg <= 1;
                y_blocked = ((plat2_y_t >= y_block_t) && (plat2_y_b <= y_block_b)) ? 0 : 1;
                x_delta_next = ((plat2_y_t >= y_block_t) && (plat2_y_b <= y_block_b)) ? -1 : x_delta_next;
            end
            else if ((plat3_x_l <= x_block_r) && (plat3_x_r >= x_block_l) && (plat3_y_t <= y_block_b) && (plat3_y_b >= y_block_t)) begin
                // y_delta_next = 0;
                hasFlip_reg <= 1;
                y_blocked = ((plat3_y_t >= y_block_t) && (plat3_y_b <= y_block_b)) ? 0 : 1;
                x_delta_next = ((plat3_y_t >= y_block_t) && (plat3_y_b <= y_block_b)) ? -1 : x_delta_next;
            end
            else if ((plat4_x_l <= x_block_r) && (plat4_x_r >= x_block_l) && (plat4_y_t <= y_block_b) && (plat4_y_b >= y_block_t)) begin
                // y_delta_next = 0;
                hasFlip_reg <= 1;
                y_blocked = ((plat4_y_t >= y_block_t) && (plat4_y_b <= y_block_b)) ? 0 : 1;
                x_delta_next = ((plat4_y_t >= y_block_t) && (plat4_y_b <= y_block_b)) ? -1 : x_delta_next;
            end else begin
                y_blocked = 0;
            end
            
            if (~grav && ~y_blocked && (y_block_t > 0) && (y_block_t > (Y_TOP))) begin
                y_delta_next = BLOCK_VELOCITY_NEG; // move up
                x_delta_next = 0;
                hit_edge <= (y_block_next <= Y_TOP || x_block_next <= 0) ? 1 : 0;
            end else if(grav && ~y_blocked && (y_block_b < (Y_MAX)) && (y_block_b < (Y_BOTTOM))) begin
                y_delta_next = BLOCK_VELOCITY; // move down
                x_delta_next = 0;
                hit_edge <= ((y_block_next+BLOCK_SIZE) >= Y_MAX || x_block_next <= 0) ? 1 : 0;
            end 
        end
    end

    reg [3:0] COUNT_MAX;
    initial begin
        COUNT_MAX <= 4;
    end
    
    reg [3:0] count = 0;
    

     //READ MEMORY FILE FOR INPUT ASCII ARRAY, CREATE SIGNAL ARRAY                       
    wire [6:0] ascii;  //Signal is concatenated with X coordinate to get a value for the ROM address                 
    wire [6:0] a[8:0]; //Each index of this array holds a 7-bit ASCII value
    wire d[8:0]; //Each index of this array holds a signal that says whether the i-th item in array a above should display
    wire displayContents; //Control signal to determine whether a character should be displayed on the screen
    
    //GAME OVER - 47 41 4d 45 4f 56 45 52
    reg [6:0] readAscii [7:0];
    initial begin
      readAscii[0] = 7'h47;
      readAscii[1] = 7'h41;
      readAscii[2] = 7'h4d;
      readAscii[3] = 7'h45;
      readAscii[4] = 7'h4f;
      readAscii[5] = 7'h56;
      readAscii[6] = 7'h45;
      readAscii[7] = 7'h52;  
    end

    ///////////////////////////////////////////////////////////////////////////////////
    
    //INSTANTIATE TEXT GENERATION MODULES/////////////////////////////////////////////////////////
        //Manually feed in data to ascii_in or use another module to get live data, such as a counter
        //In this case readAscii is an array that had data imported from a hex memory file
        textGeneration c0 (.clk(clk),.reset(reset),.asciiData(a[0]), .ascii_In(readAscii[0]), //readAscii[0] holds 7'h46 or Char 'G'
        .x(x),.y(y), .displayContents(d[0]), .x_desired(10'd80), .y_desired(10'd80)); //Desired X and Y coordinate to display F is X:80, Y:80
                                                                                        // (top-left most of monitor is (0,0))
        textGeneration c1 (.clk(clk),.reset(reset),.asciiData(a[1]), .ascii_In(readAscii[1]), //Char 'A'
        .x(x),.y(y), .displayContents(d[1]), .x_desired(10'd88), .y_desired(10'd80));
        
        textGeneration c2 (.clk(clk),.reset(reset),.asciiData(a[2]), .ascii_In(readAscii[2]),//Char 'M'
        .x(x),.y(y), .displayContents(d[2]), .x_desired(10'd96), .y_desired(10'd80));
        
        textGeneration c3 (.clk(clk),.reset(reset),.asciiData(a[3]), .ascii_In(readAscii[3]),//Char 'E'
        .x(x),.y(y), .displayContents(d[3]), .x_desired(10'd104), .y_desired(10'd80));
        
        textGeneration c4 (.clk(clk),.reset(reset),.asciiData(a[4]), .ascii_In(readAscii[4]), //Char 'O'
        .x(x),.y(y), .displayContents(d[4]), .x_desired(10'd120), .y_desired(10'd80));
        
        textGeneration c5 (.clk(clk),.reset(reset),.asciiData(a[5]), .ascii_In(readAscii[5]),//Char 'V'
        .x(x),.y(y), .displayContents(d[5]), .x_desired(10'd128), .y_desired(10'd80));
        
        textGeneration c6 (.clk(clk),.reset(reset),.asciiData(a[6]), .ascii_In(readAscii[6]),//Char 'E'
        .x(x),.y(y), .displayContents(d[6]), .x_desired(10'd136), .y_desired(10'd80));
        
         textGeneration c7 (.clk(clk),.reset(reset),.asciiData(a[7]), .ascii_In(readAscii[7]),//Char 'R'
        .x(x),.y(y), .displayContents(d[7]), .x_desired(10'd144), .y_desired(10'd80));
        

//Decoder to trigger displayContents signal high or low depending on which ASCII char is reached
    assign displayContents = d[0] ? d[0] :
                             d[1] ? d[1] :
                             d[2] ? d[2] :
                             d[3] ? d[3] :
                             d[4] ? d[4] :
                             d[5] ? d[5] :
                             d[6] ? d[6] :
                             d[7] ? d[7] :
                             d[8] ? d[8] : 0;
//Decoder to assign correct ASCII value depending on which displayContents signal is used                        
    assign ascii = d[0] ? a[0] :
                   d[1] ? a[1] :
                   d[2] ? a[2] :
                   d[3] ? a[3] :
                   d[4] ? a[4] :
                   d[5] ? a[5] :
                   d[6] ? a[6] :
                   d[7] ? a[7] :
                   d[8] ? a[8] : 7'h30; //defaulted to 0
 
 //ASCII_ROM////////////////////////////////////////////////////////////       
    //Connections to ascii_rom
    wire [10:0] rom_addr;
    //Handle the row of the rom
    wire [3:0] rom_row;
    //Handle the column of the rom data
    wire [2:0] rom_col;
    //Wire to connect to rom_data of ascii_rom
    wire [7:0] rom_data;
    //Bit to signal display of data
    wire rom_bit;
    ascii_rom rom1(.clk(clk), .rom_addr(rom_addr), .data(rom_data));

    //Concatenate to get 11 bit rom_addr
    assign rom_row = y[3:0];
    assign rom_addr = {ascii, rom_row};
    assign rom_col = x[2:0];
    assign rom_bit = rom_data[~rom_col]; //need to negate since it initially displays mirrored
///////////////////////////////////////////////////////////////////////////////////////////////
    
    //If video on then check
        //If rom_bit is on
            //If x and y are in the origin/end range
                //Set RGB to display whatever is in the ROM within the origin/end range
            //Else we are out of range so we should not modify anything, RGB set to blue
        //rom_bit is off display blue
    //Video_off display black
            
    // Set RGB output value based on status signals
    always @* begin
        if(~video_on)
            rgb = 12'h000;
        
        else 
            if (hit_edge) begin
                rgb = rom_bit ? ((displayContents) ? 12'hFFF: 12'h8): 12'h8;
            end else begin
                if(block_on)
                    rgb = 12'hFFF;
                if(plat_on > 0) begin
                    rgb = 12'hFFF;
                end
            end
    end

endmodule