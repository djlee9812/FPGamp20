`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2020 11:32:28 AM
// Design Name: 
// Module Name: reverb
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


module reverb(
    input reverb_on,
    input ready_in,
    input clk_in,
    input logic signed [11:0] signal_in,
    output logic signed [11:0] signal_out

    );
    localparam READY = 5'b00001;
    localparam PREP_FIRST = 5'b00010;
    localparam GET_FIRST = 5'b00100;
    localparam GET_SECOND = 5'b01000;
    
    parameter DELAY1 = 16'd16000;
    parameter DELAY2 = 16'd32000;
    
    logic [4:0] state;
    
    logic signed [11:0] data_to_bram;
    logic signed [11:0] data_from_bram;
    logic [15:0] addr;
    logic [15:0] writeAddr;
    logic wea;
    blk_mem_gen_0 mem0(.addra(addr), .clka(clk_in), .dina(data_to_bram), .douta(data_from_bram), 
                    .ena(1), .wea(wea)); 

    logic signed [11:0] firstEcho;
    logic signed [11:0] secondEcho;
    logic signed [11:0] zeroEcho;
    
     always_ff @(posedge clk_in) begin
        if (~reverb_on) begin
            if (ready_in) signal_out <= signal_in;
            firstEcho <= 0;
            secondEcho <= 0;
            zeroEcho <= 0;
            state <= READY;
            addr <= 0;
            writeAddr <= 0;
            wea <= 1'b1;
            
        end else begin
            if (state == READY && ready_in) begin
                state <= PREP_FIRST;
                wea <= 1'b1;
                data_to_bram <= signal_in;
                addr <= writeAddr;
                writeAddr <= writeAddr + 1'b1;
                signal_out <= signal_in + (firstEcho >>> 1) + (secondEcho >>> 2);
            end else if (state == PREP_FIRST) begin
                // prep to get first echo
                wea <= 1'b0;
                addr <= writeAddr - DELAY1;
                state <= GET_FIRST;
            end else if (state == GET_FIRST) begin
                firstEcho <= data_from_bram;
                addr <= writeAddr - DELAY2;
                state <= GET_SECOND;
            end else if (state == GET_SECOND) begin
                state <= 5'b10000;
                secondEcho <= data_from_bram;
            end else if (state == 5'b10000) begin
                //signal_out <= zeroEcho + (firstEcho >>> 1) + (secondEcho >> 2);
                state <= READY;
            end else state <= READY;
        end 
        
    end
endmodule
