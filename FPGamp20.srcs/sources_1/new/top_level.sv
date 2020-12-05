`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2020 07:03:45 PM
// Design Name: 
// Module Name: top_level
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


module top_level(
    input clk_100mhz,
    input [15:0] sw,
    input btnc, btnu, btnd, btnr, btnl,
    input vauxp3,
    input vauxn3,
    input vn_in,
    input vp_in,
    output logic [15:0] led,
    output logic aud_pwm,
    output logic aud_sd
);
    parameter SAMPLE_COUNT = 2082;//gets approximately (will generate audio at approx 48 kHz sample rate.
    
    logic [15:0] sample_counter;
    logic [15:0] adc_data;
    logic [11:0] sampled_adc_data;
    logic sample_trigger;
    logic adc_ready;
    logic enable;
    
    logic signed [23:0] filtered_adc_data;
    logic signed [11:0] input_data;
    logic signed [11:0] distortion_out;
    logic signed [11:0] trem_out;
    logic signed [11:0] reverb_out;
    logic [11:0] vol_out;
    logic pwm_val; //pwm signal (HI/LO)
    
    assign aud_sd = 1;
    assign led = sw; //just to look pretty 
    assign sample_trigger = (sample_counter == SAMPLE_COUNT);

    always_ff @(posedge clk_100mhz)begin
        if (sample_counter == SAMPLE_COUNT)begin
            sample_counter <= 16'b0;
        end else begin
            sample_counter <= sample_counter + 16'b1;
        end
        if (sample_trigger) begin
            sampled_adc_data <= {~adc_data[15],adc_data[14:4]}; //convert to signed. incoming data is offset binary
            //https://en.wikipedia.org/wiki/Offset_binary
        end
    end

    //ADC uncomment when activating!
    xadc_wiz_0 my_adc ( .dclk_in(clk_100mhz), .daddr_in(8'h13), //read from 0x13 for a
                        .vauxn3(vauxn3),.vauxp3(vauxp3),
                        .vp_in(1),.vn_in(1),
                        .di_in(16'b0),
                        .do_out(adc_data),.drdy_out(adc_ready),
                        .den_in(1), .dwe_in(0));
    
    fir31 lpf (.clk_in(clk_100mhz), .rst_in(btnd), .ready_in(sample_trigger), .x_in(sampled_adc_data), .y_out(filtered_adc_data));
    
    assign input_data = sw[3] ? (filtered_adc_data >>> 12) : sampled_adc_data;
 
    distortion distort (.clk_in(clk_100mhz), .dist_in(sw[0]), .ready_in(sample_trigger), 
        .audio_data(input_data), .output_data(distortion_out));
 
    tremolo trem (.trem_on(sw[1]), .ready_in(sample_trigger), .clk_in(clk_100mhz), .rst_in(btnd),
        .signal_in(distortion_out), .signal_out(trem_out));         
        
    reverb rev (.reverb_on(sw[2]), .ready_in(sample_trigger), .clk_in(clk_100mhz), 
        .signal_in(trem_out), .signal_out(reverb_out));                                                
                                                                                            
    volume_control vc (.vol_in(sw[15:13]),
                       .signal_in(reverb_out), .signal_out(vol_out));
    pwm (.clk_in(clk_100mhz), .rst_in(btnd), .level_in(vol_out), .pwm_out(pwm_val));
    assign aud_pwm = pwm_val?1'bZ:1'b0; 
    
endmodule
