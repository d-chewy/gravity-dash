`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2024 04:45:46 PM
// Design Name: 
// Module Name: pos_edge_det
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


module pos_edge_det(
    // Outputs
    wire pe,
    // Inputs
    wire clk,
    wire sig
    );
    
    reg sig_dly;
    
    initial
        sig_dly = 0;
    
    always @(posedge clk) begin
        sig_dly <= sig;
    end
    
    assign pe = ~sig_dly & sig;
    
endmodule
