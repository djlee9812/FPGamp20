`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2020 02:41:26 PM
// Design Name: 
// Module Name: vibrato
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


module vibrato(
    input vibrato_on,
    input ready_in,
    input clk_in,
    input rst_in,
    input flange_on,
    input logic signed [11:0] signal_in,
    output logic signed [11:0] signal_out,
    output logic ready_out
    );
    
    localparam READY = 3'b001;
    localparam RECEIVE = 3'b010;
    localparam PREPARE = 3'b100;
    
    logic  [7:0] sin_wave;
    sine_generator wave5hz( .clk_in(clk_in), .rst_in(rst_in), .step_in(ready_in), .amp_out(sin_wave));
    
    logic [3:0] state;
    logic signed [11:0] data_to_bram;
    logic signed [11:0] data_from_bram;
    logic [15:0] addr;
    logic [15:0] writeAddr;
    logic wea;
    blk_mem_gen_0 mem0(.addra(addr), .clka(clk_in), .dina(data_to_bram), .douta(data_from_bram), 
                    .ena(1), .wea(wea));
    
    logic signed [12:0] vibAcc;
    always_ff @(posedge clk_in) begin
        if (~vibrato_on) begin
            ready_out <= 1'b0;
            if (ready_in) begin
                signal_out <= signal_in;
                ready_out <= 1'b1;
            end
            state <= READY;
            addr <= 0;
            writeAddr <= 0;
            wea <= 1'b1;
            
        end else begin
            ready_out <= 1'b0;
            if (state == READY && ready_in) begin
                state <= RECEIVE;
                wea <= 1'b1;
                data_to_bram <= signal_in;
                addr <= writeAddr;
                writeAddr <= writeAddr + 1'b1;
                vibAcc <= (flange_on) ? signal_in : 0;
            end else if (state == RECEIVE) begin
                // prep to get delayed sound
                wea <= 1'b0;
                addr <= writeAddr - sin_wave;
                state <= PREPARE;
            end else if (state == PREPARE) begin
                // get delayed sound and output
                signal_out <= (vibAcc + data_from_bram) >>> 1;
                ready_out <= 1'b1;
                state <= READY;
            end else state <= READY;
        end 
        
    end
    
endmodule

