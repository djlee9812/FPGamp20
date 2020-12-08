`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2020 03:10:00 PM
// Design Name: 
// Module Name: shelving
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


module shelving(
    input logic clk,
    input logic signed [11:0] signal_in,
    input logic boost,
    output logic signed [11:0] signal_out
    );
    logic c;
    always_ff @(posedge clk) begin
        if (boost) begin
            
        end else begin
        
        end
    end
    
endmodule
