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


module fir_tb(

    );
    logic clk,reset,ready;
    logic ena_l,ena_b,ena_h;
    logic lpf_done,bpf_done,hpf_done;
    logic signed [11:0] waveform;
    logic signed [11:0] x;
    logic signed [11:0] lpf_out;
    logic signed [11:0] bpf_out;
    logic signed [11:0] y;
    logic [7:0] sine_out;
    
    logic [5:0] count;
    logic [20:0] scount;
    
    integer fin,fout,code;
    
    initial begin
        fin = $fopen("fir31.waveform","r");
        fout = $fopen("fir31.output","w");
        if (fin == 0 || fout == 0) begin
          $display("can't open file...");
          $stop;
        end
        clk = 0;
        ena_l = 1;
        ena_b = 0;
        ena_h = 0;
        ready = 0;
        scount = 0;
        x = 0;
        reset = 1;
        y = 0;
        count = 0;
        #10
        reset = 0;
    end
    always #5 clk = ~clk;
    
    sine_generator my_sin(.clk_in(clk), .rst_in(reset), .step_in(ready), .amp_out(sine_out));
    lpf_fir my_lpf(.clk_in(clk), .rst_in(reset), .ena(ena_l), .ready_in(ready), .x_in(x), .y_out(lpf_out), .ready_out(lpf_done));
    bpf_fir my_bpf(.clk_in(clk), .rst_in(reset), .ena(ena_b), .ready_in(lpf_done), .x_in(lpf_out), .y_out(bpf_out), .ready_out(bpf_done));
    hpf_fir my_hpf(.clk_in(clk), .rst_in(reset), .ena(ena_h), .ready_in(bpf_done), .x_in(bpf_out), .y_out(y), .ready_out(hpf_done));
    
//    always @(posedge clk) begin
//        ready <= ~ready;
//        if (~ready) begin
//            x <= {1'b0, sine_out, 3'b0};
//        end    
//    end
//    always @(posedge clk) begin
//        if (count == 0) begin 
//            x <= x + 300;
//            ready <= 1;
//        end else begin
//            ready <= 0;
            
//        end
//        count <= count + 1;
//    end
    always @(posedge clk) begin
        if (count == 6'd63) begin
          // assert ready next cycle, read next sample from file
          ready <= 1;
          code = $fscanf(fin,"%d",waveform);
          x <= waveform << 4;
          scount <= scount + 1;
          // if we reach the end of the input file, we're done
          if (code != 1) begin
            $fclose(fout);
            $stop;
          end
        end
        else begin
          ready <= 0;
        end
        
        if (scount == 21'd60) begin
            ena_l <= 0;
            ena_b <= 1;
        end
        if (scount == 21'd120) begin
            ena_b <= 0;
            ena_h <= 1;
        end    
        count <= count+1;
        
      end
endmodule
