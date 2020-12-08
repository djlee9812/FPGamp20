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
    input rst_in,
    input logic signed [11:0] signal_in,
    output logic signed [11:0] signal_out,
    output logic ready_out
    );
    
    logic  [7:0] sin_wave;
    sine_generator wave5hz( .clk_in(clk_in), .rst_in(rst_in), .step_in(ready_in), .amp_out(sin_wave));
    logic signed [8:0] signed_sine;
    assign signed_sine = {1'b0, sin_wave};
    logic signed [20:0] temp;
    logic state;
    
    always_ff @(posedge clk_in) begin
        if (trem_on) begin
            if (ready_in && state == 2'b00) begin
                temp <= (signed_sine*signal_in);
                state <= 2'b01;
            end else if (state == 2'b01) begin
                signal_out <= temp>>>9;
                ready_out <= 1'b1;
                state <= 2'b10;
            end else if (state == 2'b10) begin
                ready_out <= 1'b0;
                state <= 2'b00;
            end
        end else begin
            state <= 2'b00;
            ready_out <= 1'b0;
            if (ready_in) begin 
                signal_out <= signal_in;
                ready_out <= 1'b1;
            end 
        end
    end
    
    
endmodule


