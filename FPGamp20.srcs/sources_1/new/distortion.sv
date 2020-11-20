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
    input logic signed [11:0] audio_data,
    output logic signed [11:0] output_data
    );
    parameter signed LOW_THRESH = 682;
//    parameter signed HIGH_THRESH = 12'd1365;
    parameter signed HIGH_THRESH = 1020;
    
    always_ff @(posedge clk_in) begin
        if (dist_in) begin
            // if abs(audio_data) < LOW_THRESH
            if ((audio_data < LOW_THRESH && audio_data > 0) || (audio_data > -LOW_THRESH && audio_data < 0)) begin
                output_data <= audio_data <<< 1;
            // if abs(audio_data) < HIGH_THRESH
            end else if ((audio_data < HIGH_THRESH && audio_data > LOW_THRESH) || 
                (audio_data > -HIGH_THRESH && audio_data < -LOW_THRESH)) begin
                output_data <= audio_data <<< 1;
            // if above and positive set to max
            end else if (audio_data > 0) begin
                output_data <= 11'b111_1111_1111;
            // if negative, set to min
            end else if (audio_data < 0) begin
                output_data <= -11'b111_1111_1111;
            end
        end else begin
            output_data <= audio_data;
        end
    end
endmodule
