`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2024 10:10:54 PM
// Design Name: 
// Module Name: LFSR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LFSR (
    input clock,
    input reset,
    output [4:0] rnd 
    );

    wire feedback = random[4] ^ random[2]; 

    reg [4:0] random, random_next, random_done;
    reg [2:0] count, count_next; //to keep track of the shifts

    always @ (posedge clock or posedge reset)
    begin
        if (reset)
        begin
            random <= 4'b1001; //An LFSR cannot have an all 0 state, thus reset to FF
            count <= 0;
        end
        else
        begin
            random <= random_next;
            count <= count_next;
        end
    end

    always @ (*) begin
        random_next = random; //default state stays the same
        count_next = count;
        
        random_next = {random[3:0], feedback}; //shift left the xor'd every posedge clock
        count_next = count + 1;

        if (count == 5) begin
            count_next = 0;
            random_done = random; //assign the random number to output after 4
        end
    end

    assign rnd = random_done;

endmodule