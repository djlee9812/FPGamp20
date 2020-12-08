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
    output logic signed [11:0] signal_out,
    output logic ready_out

    );
    localparam READY = 6'b000001;
    localparam PREP_FIRST = 6'b000010;
    localparam GET_FIRST = 6'b000100;
    localparam GET_SECOND = 6'b001000;
    localparam GET_THIRD = 6'b010000;
    localparam FINAL = 6'b100000;
    
    parameter DELAY1 = 16'd20000;
    parameter DELAY2 = 16'd24000;
    parameter DELAY3 = 16'd28000;
    parameter DELAY4 = 16'd32000;
    parameter DELAY5 = 16'd36000;
    parameter DELAY6 = 16'd40000;
    
    logic [5:0] state;
    
    logic signed [11:0] data_to_bram;
    logic signed [11:0] data_from_bram;
    logic [15:0] addr;
    logic [15:0] writeAddr;
    logic wea;
    blk_mem_gen_0 mem0(.addra(addr), .clka(clk_in), .dina(data_to_bram), .douta(data_from_bram), 
                    .ena(1), .wea(wea));
    logic [15:0] addr1;
    logic signed [11:0] data_from_bram1;
    blk_mem_gen_0 mem1(.addra(addr1), .clka(clk_in), .dina(data_to_bram), .douta(data_from_bram1), 
                    .ena(1), .wea(wea)); 

    logic signed [11:0] firstEcho;
    logic signed [11:0] secondEcho;
    logic signed [11:0] thirdEcho;
    logic signed [11:0] fourthEcho;
    logic signed [11:0] fifthEcho;
    logic signed [11:0] sixthEcho;
    logic signed [13:0] verb;
    
     always_ff @(posedge clk_in) begin
        if (~reverb_on) begin
            ready_out <= 1'b0;
            if (ready_in) begin
                signal_out <= signal_in;
                ready_out <= 1'b1;
            end
            verb <= 0;
            state <= READY;
            addr <= 0;
            addr1 <= 0;
            writeAddr <= 0;
            wea <= 1'b1;
            
        end else begin
            ready_out <= 1'b0;
            if (state == READY && ready_in) begin
                state <= PREP_FIRST;
                wea <= 1'b1;
                data_to_bram <= signal_in;
                addr <= writeAddr;
                addr1 <= writeAddr;
                writeAddr <= writeAddr + 1'b1;
                verb <= signal_in;
            end else if (state == PREP_FIRST) begin
                // prep to get first echo
                wea <= 1'b0;
                addr <= writeAddr - DELAY1;
                addr1 <= writeAddr - DELAY4;
                state <= GET_FIRST;
            end else if (state == GET_FIRST) begin
                verb <= verb + (data_from_bram >>> 1) + (data_from_bram1 >>> 2);
                addr <= writeAddr - DELAY2;
                addr1 <= writeAddr - DELAY5;
                state <= GET_SECOND;
            end else if (state == GET_SECOND) begin
                state <= GET_THIRD;
                verb <= verb + (data_from_bram >>> 1) + (data_from_bram1 >>> 2);
                addr1 <= writeAddr - DELAY6;
                addr <= writeAddr - DELAY3;
            end else if (state == GET_THIRD) begin
                verb <= verb + (data_from_bram >>> 1) + (data_from_bram1 >>> 2);
                state <= FINAL;
            end else if (state == FINAL) begin
                signal_out <= (verb >>> 2);
                ready_out <= 1'b1;
                state <= READY;
            end else state <= READY;
        end 
        
    end
endmodule
