`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2020 04:37:46 PM
// Design Name: 
// Module Name: chorus
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


module chorus(
    input chorus_on,
    input ready_in,
    input clk_in,
    input logic signed [11:0] signal_in,
    output logic signed [11:0] signal_out

    );
    localparam READY = 5'b00001;
    localparam PREP_FIRST = 5'b00010;
    localparam GET_FIRST = 5'b00100;
    localparam GET_SECOND = 5'b01000;
    localparam GET_THIRD = 5'b10000;
    
    parameter DELAY1 = 16'd100;
    parameter DELAY2 = 16'd200;
    parameter DELAY3 = 16'd50;
    parameter DELAY4 = 16'd400;
    parameter DELAY5 = 16'd300;
    parameter DELAY6 = 16'd500;
    
    logic [4:0] state;
    
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
    
     always_ff @(posedge clk_in) begin
        if (~chorus_on) begin
            if (ready_in) signal_out <= signal_in;
            firstEcho <= 0;
            secondEcho <= 0;
            thirdEcho <= 0;
            fourthEcho <= 0;
            fifthEcho <= 0;
            sixthEcho <= 0;
            state <= READY;
            addr <= 0;
            addr1 <= 0;
            writeAddr <= 0;
            wea <= 1'b1;
            
        end else begin
            if (state == READY && ready_in) begin
                state <= PREP_FIRST;
                wea <= 1'b1;
                data_to_bram <= signal_in;
                addr <= writeAddr;
                addr1 <= writeAddr;
                writeAddr <= writeAddr + 1'b1;
                signal_out <= signal_in + (firstEcho) + (secondEcho) + (thirdEcho) + (fourthEcho) + (fifthEcho) + (sixthEcho);
            end else if (state == PREP_FIRST) begin
                // prep to get first echo
                wea <= 1'b0;
                addr <= writeAddr - DELAY1;
                addr1 <= writeAddr - DELAY4;
                state <= GET_FIRST;
            end else if (state == GET_FIRST) begin
                firstEcho <= (data_from_bram >>> 1);
                fourthEcho <= (data_from_bram1 >>> 2);
                addr <= writeAddr - DELAY2;
                addr1 <= writeAddr - DELAY5;
                state <= GET_SECOND;
            end else if (state == GET_SECOND) begin
                state <= GET_THIRD;
                secondEcho <= (data_from_bram >>> 2);
                fifthEcho <= (data_from_bram1 >>> 1);
                addr1 <= writeAddr - DELAY6;
                addr <= writeAddr - DELAY3;
            end else if (state == GET_THIRD) begin
                thirdEcho <= (data_from_bram >>> 1);
                sixthEcho <= (data_from_bram1 >>> 2);
                state <= READY;
            end else state <= READY;
        end 
        
    end
endmodule
