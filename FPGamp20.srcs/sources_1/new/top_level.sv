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
    output logic[3:0] vga_r,
    output logic[3:0] vga_b,
    output logic[3:0] vga_g,
    output logic vga_hs,
    output logic vga_vs,
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
    logic signed [11:0] chorus_out;
    logic signed [11:0] reverb_out;
    logic signed [11:0] vibrato_out;
    logic dist_done;
    logic trem_done;
    logic chorus_done;
    logic reverb_done;
    logic vibrato_done;
    logic [11:0] vol_out;
    logic pwm_val; //pwm signal (HI/LO)
    
    // fft variables
    logic [15:0] scaled_adc_data;
    logic [15:0] fft_data;
    logic       fft_ready;
    logic       fft_valid;
    logic       fft_last;
    logic [9:0] fft_data_counter;
    
    logic fft_out_ready;
    logic fft_out_valid;
    logic fft_out_last;
    logic [31:0] fft_out_data;
    
    logic sqsum_valid;
    logic sqsum_last;
    logic sqsum_ready;
    logic [31:0] sqsum_data;
    
    logic fifo_valid;
    logic fifo_last;
    logic fifo_ready;
    logic [31:0] fifo_data;
    
    logic [23:0] sqrt_data;
    logic sqrt_valid;
    logic sqrt_last;
    
    logic pixel_clk;
    logic [1:0] my_fft_count;
    
    vga_clk myvga (.clk_in1(clk_100mhz), .clk_out1(pixel_clk));
    
    assign aud_sd = 1;
    assign led = sw; //just to look pretty 
    assign sample_trigger = (sample_counter == SAMPLE_COUNT);

    always_ff @(posedge clk_100mhz)begin
        if (sample_counter == SAMPLE_COUNT)begin
            sample_counter <= 16'b0;
            my_fft_count <= my_fft_count + 2'b1;
        end else begin
            sample_counter <= sample_counter + 16'b1;
        end
        if (sample_trigger) begin
            sampled_adc_data <= {~adc_data[15],adc_data[14:4]}; //convert to signed. incoming data is offset binary
//            scaled_adc_data <= 16*adc_data;
            //https://en.wikipedia.org/wiki/Offset_binary
            if (fft_ready && my_fft_count == 0)begin
                fft_data_counter <= fft_data_counter +1;
                fft_last <= fft_data_counter==1023;
                fft_valid <= 1'b1;
                // if sw[12] on, fft on effects signal, else on input signal
                fft_data <= sw[12] ? {reverb_out, 4'b0} : {~adc_data[15],adc_data[14:0]}; //set the FFT DATA here!
            end
        end else begin
            fft_data <= 0;
            fft_last <= 0;
            fft_valid <= 0;
        end
    end

    //ADC uncomment when activating!
    xadc_wiz_0 my_adc ( .dclk_in(clk_100mhz), .daddr_in(8'h13), //read from 0x13 for a
                        .vauxn3(vauxn3),.vauxp3(vauxp3),
                        .vp_in(1),.vn_in(1),
                        .di_in(16'b0),
                        .do_out(adc_data),.drdy_out(adc_ready),
                        .den_in(1), .dwe_in(0));
    
    //FFT module:
    //CONFIGURATION:
    //1 channel
    //transform length: 1024
    //target clock frequency: 100 MHz
    //target Data throughput: 50 Msps
    //Auto-select architecture
    //IMPLEMENTATION:
    //Fixed Point, Scaled, Truncation
    //MAKE SURE TO SET NATURAL ORDER FOR OUTPUT ORDERING
    //Input Data Width, Phase Factor Width: Both 16 bits
    //Result uses 12 DSP48 Slices and 6 Block RAMs (under Impl Details)                    
    xfft_0 my_fft (.aclk(clk_100mhz), .s_axis_data_tdata(fft_data), 
                    .s_axis_data_tvalid(fft_valid),
                    .s_axis_data_tlast(fft_last), .s_axis_data_tready(fft_ready),
                    .s_axis_config_tdata(0), 
                     .s_axis_config_tvalid(0),
                     .s_axis_config_tready(),
                    .m_axis_data_tdata(fft_out_data), .m_axis_data_tvalid(fft_out_valid),
                    .m_axis_data_tlast(fft_out_last), .m_axis_data_tready(fft_out_ready));
                    
    //for debugging commented out, make this whatever size,detail you want:
    //ila_0 myila (.clk(clk_100mhz), .probe0(fifo_data), .probe1(sqrt_data), .probe2(sqsum_data), .probe3(fft_out_data));
    
    //custom module (was written with a Vivado AXI-Streaming Wizard so format looks inhuman
    //this is because it was a template I customized.
    square_and_sum_v1_0 mysq(.s00_axis_aclk(clk_100mhz), .s00_axis_aresetn(1'b1),
                            .s00_axis_tready(fft_out_ready),
                            .s00_axis_tdata(fft_out_data),.s00_axis_tlast(fft_out_last),
                            .s00_axis_tvalid(fft_out_valid),.m00_axis_aclk(clk_100mhz),
                            .m00_axis_aresetn(1'b1),. m00_axis_tvalid(sqsum_valid),
                            .m00_axis_tdata(sqsum_data),.m00_axis_tlast(sqsum_last),
                            .m00_axis_tready(sqsum_ready));
                            
    //Didn't really need this fifo but put it in for because I felt like it and for practice:
    //This is an AXI4-Stream Data FIFO
    //FIFO Depth: 1024
    //No packet mode, no async clock, 2 sycn stages for clock domain crossing
    //no aclken conversion
    //TDATA Width: 4 bytes
    //Enable TSTRB: No...isn't needed
    //Enable TKEEP: No...isn't needed
    //Enable TLAST: Yes...use this for frame alignment
    //TID Width, TDEST Width, and TUSER width: all 0
    axis_data_fifo_0 myfifo (.s_axis_aclk(clk_100mhz), .s_axis_aresetn(1'b1),
                             .s_axis_tvalid(sqsum_valid), .s_axis_tready(sqsum_ready),
                             .s_axis_tdata(sqsum_data), .s_axis_tlast(sqsum_last),
                             .m_axis_tvalid(fifo_valid), .m_axis_tdata(fifo_data),
                             .m_axis_tready(fifo_ready), .m_axis_tlast(fifo_last));    
                             
     //AXI4-STREAMING Square Root Calculator:
    //CONFIGUATION OPTIONS:
    // Functional Selection: Square Root
    //Architec Config: Parallel (can't change anyways)
    //Pipelining: Max
    //Data Format: UnsignedInteger
    //Phase Format: Radians, the way God intended.
    //Input Width: 32
    //Output Width: 17
    //Round Mode: Truncate
    //0 on the others, and no scale compensation
    //AXI4 STREAM OPTIONS:
    //Has TLAST!!! need to propagate that
    //Don't need a TUSER
    //Flow Control: Blocking
    //optimize Goal: Performance
    //leave other things unchecked.
    cordic_0 mysqrt (.aclk(clk_100mhz), .s_axis_cartesian_tdata(fifo_data),
                     .s_axis_cartesian_tvalid(fifo_valid), .s_axis_cartesian_tlast(fifo_last),
                     .s_axis_cartesian_tready(fifo_ready),.m_axis_dout_tdata(sqrt_data),
                     .m_axis_dout_tvalid(sqrt_valid), .m_axis_dout_tlast(sqrt_last));
    
    logic [9:0] addr_count;
    logic [9:0] draw_addr;
    logic [31:0] amp_out;
    logic [10:0] hcount;
    logic [9:0] vcount;
    logic       vsync;
    logic       hsync;
    logic       blanking;
    logic [11:0] rgb;
    
    always_ff @(posedge clk_100mhz)begin
        if (sqrt_valid)begin
            if (sqrt_last)begin
                addr_count <= 'd1023; //allign
            end else begin
                addr_count <= addr_count + 1'b1;
            end
        end
    
    end 
    
    //Two Port BRAM: The FFT pipeline files values inot this and the VGA side of things
    //reads the values out as needed!  Separate clocks on both sides so we don't need to
    //worry about clock domain crossing!! (at least not directly)
    //BRAM Generator (v. 8.4)
    //BASIC:
    //Interface Type: Native
    //Memory Type: True Dual Port RAM (leave common clock unticked...since using100 and 65 MHz)
    //leave ECC as is
    //leave Write enable as is (unchecked Byte Write Enabe)
    //Algorithm Options: Minimum Area (not too important anyways)
    //PORT A OPTIONS:
    //Write Width: 32
    //Read Width: 32
    //Write Depth: 1024
    //Read Depth: 1024
    //Operating Mode; Write First (not too important here)
    //Enable Port Type: Use ENA Pin
    //Keep Primitives Output Register checked
    //leave other stuff unchecked
    //PORT B OPTIONS:
    //Should mimic Port A (and should auto-inheret most anyways)
    //leave other tabs as is. the summary tab should report one 36K BRAM being used
    value_bram mvb (.addra(addr_count+3), .clka(clk_100mhz), .dina({8'b0,sqrt_data}),
                    .douta(), .ena(1'b1), .wea(sqrt_valid),.dinb(0),
                    .addrb(draw_addr), .clkb(pixel_clk), .doutb(amp_out),
                    .web(1'b0), .enb(1'b1));     
                    
                    
    //draw bargraphs from amp_out extracted (scale with switches)                
    always_ff @(posedge pixel_clk)begin
//        if (!blanking)begin //time to draw!
//            rgb <= 12'b0011_0000_0000;
//        end
        draw_addr <= hcount/2;
        if ((amp_out>>sw[10:7])>=768-vcount)begin
            rgb <= 12'b1111_0000_0000;
        end else begin
            rgb <= 12'b0000_0000_0000;
        end

    end                     
    xvga myyvga (.vclock_in(pixel_clk),.hcount_out(hcount),  
                .vcount_out(vcount),.vsync_out(vsync), .hsync_out(hsync),
                 .blank_out(blanking));               
                        
    assign vga_r = ~blanking ? rgb[11:8]: 0;
    assign vga_g = ~blanking ? rgb[7:4] : 0;
    assign vga_b = ~blanking ? rgb[3:0] : 0;
    
    assign vga_hs = ~hsync;
    assign vga_vs = ~vsync;
    
    fir31 lpf (.clk_in(clk_100mhz), .rst_in(btnd), .ready_in(sample_trigger), .x_in(sampled_adc_data), .y_out(filtered_adc_data));
    
    assign input_data = sw[4] ? (filtered_adc_data >>> 12) : sampled_adc_data;
 
    distortion distort (.clk_in(clk_100mhz), .dist_in(sw[0]), .ready_in(sample_trigger), 
        .audio_data(input_data), .output_data(distortion_out));
        
    vibrato vib (.vibrato_on(sw[5]), .ready_in(sample_trigger), .clk_in(clk_100mhz), .rst_in(btnd),
        .signal_in(distortion_out), .signal_out(vibrato_out), .ready_out(vibrato_done));
 
    tremolo trem (.trem_on(sw[1]), .ready_in(vibrato_done), .clk_in(clk_100mhz), .rst_in(btnd),
        .signal_in(vibrato_out), .signal_out(trem_out), .flange_on(sw[6]), .ready_out(trem_done));         
        
    chorus chor (.chorus_on(sw[2]), .ready_in(trem_done), .clk_in(clk_100mhz), 
        .signal_in(trem_out),.ready_out(chorus_done), .signal_out(chorus_out));
    
    reverb rev (.reverb_on(sw[3]), .ready_in(chorus_done), .clk_in(clk_100mhz), 
        .signal_in(chorus_out), .signal_out(reverb_out), .ready_out(reverb_done));                                                
                                                                                            
    volume_control vc (.vol_in(sw[15:13]),
                       .signal_in(reverb_out), .signal_out(vol_out));
    pwm (.clk_in(clk_100mhz), .rst_in(btnd), .level_in(vol_out), .pwm_out(pwm_val));
    assign aud_pwm = pwm_val?1'bZ:1'b0; 
    
    ila_0 myila(.clk(clk_100mhz), .probe0(input_data), .probe1(distortion_out), .probe2(trem_out), .probe3(filtered_adc_data>>>12));
    
endmodule
