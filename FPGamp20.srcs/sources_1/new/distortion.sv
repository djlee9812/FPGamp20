`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2020 07:51:47 PM
// Design Name: 
// Module Name: distortion
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


module distortion(
    input logic clk_in,
    input logic dist_in,
    input logic ready_in,
    input logic [11:0] audio_data,
    output logic [11:0] output_data
    );
    parameter signed LOW_THRESH = 12'd682;
    parameter signed HIGH_THRESH = 12'd1365;
    
    always_ff @(posedge clk_in) begin
        if (audio_data < LOW_THRESH || audio_data > -LOW_THRESH) begin
            output_data <= audio_data * 2'd2;
        end    
    end
endmodule
