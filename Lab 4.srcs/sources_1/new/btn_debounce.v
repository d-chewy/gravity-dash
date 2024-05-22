`timescale 1ns / 1ps

module btn_debounce(
    // Outputs
    output btn_out,
    // Inputs
    input clk,
    input btn
    );
    
    reg [1:0] ff;
    
    always @(posedge clk or posedge btn) begin
        if(btn) 
            ff <= 2'b11;
        else
            ff <= {1'b0, ff[1]};
    end
    
    assign btn_out = ff[0];
endmodule
