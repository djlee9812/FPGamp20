`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2020 08:00:02 PM
// Design Name: 
// Module Name: tremolo
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


module tremolo(
    input trem_on,
    input ready_in,
    input clk_in,
    input logic signed [11:0] signal_in,
    output logic signed [11:0] signal_out

    );
    
    logic [23:0] trem_wave;
    logic signed [23:0] temp;
    
    always_ff @(posedge clk_in) begin
        if (trem_on) begin
            if (ready_in) begin
                temp <= (trem_wave >> 12) * signal_in;
                signal_out <= temp >>> 12;
            end
        end else begin
            if (ready_in) signal_out <= signal_in;
        end
        trem_wave <= trem_wave + 1'b1;
    end
    
    
endmodule
