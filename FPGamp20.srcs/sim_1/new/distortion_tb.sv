`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2020 02:39:08 PM
// Design Name: 
// Module Name: distortion_tb
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


module distortion_tb(

    );
    logic clk,reset,ready,dist_in;
    logic signed [11:0] x;
    logic signed [11:0] y;
    logic [7:0] sine_out;
    
    initial begin
        clk = 0;
        dist_in = 1;
        ready = 0;
        x = 0;
        reset = 1;
        #10
        reset = 0;
    end
    always #5 clk = ~clk;
    
    sine_generator my_sin(.clk_in(clk), .rst_in(reset), .step_in(ready), .amp_out(sine_out));
    distortion my_dist(.clk_in(clk), .dist_in(dist_in), .ready_in(ready), .audio_data(x), .output_data(y));
    
    always @(posedge clk) begin
        ready <= ~ready;
        if (~ready) begin
            x <= {1'b0, sine_out, 3'b0};
        end    
    end
//    always @(posedge clk) begin
//        x <= x + 4;
//    end
endmodule
