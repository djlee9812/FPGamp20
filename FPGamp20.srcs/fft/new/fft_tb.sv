`timescale 1ns / 1ps
module fft_tb();
    
    logic clk_100mhz;
    logic signed [11:0] x;
    logic signed [11:0] y;

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
    
    logic [31:0] ifft_data;
    logic ifft_out_ready;
    logic ifft_out_valid;
    logic ifft_out_last;
    logic [31:0] ifft_out_data;
    
    logic [5:0] cycle;
    logic [20:0] scount;
    logic ready;
    logic [1:0] my_fft_count;
    
    integer fin,fout,code;
    
    initial begin
        fin = $fopen("fir31.waveform","r");
        fout = $fopen("fir31.output","w");
        if (fin == 0 || fout == 0) begin
          $display("can't open file...");
          $stop;
        end
        clk_100mhz = 0;
        cycle = 0;
        ready = 0;
        x = 0;
        scount = 0;
        my_fft_count = 0;
        scaled_adc_data = 0;
        fft_data = 0;
        fft_valid = 0;
        fft_last = 0;
        fft_data_counter = 0;
        ifft_data = 0;
        fft_out_ready = 0;
        ifft_out_ready = 0;
    end
    always #5 clk_100mhz = ~clk_100mhz;
    
    always @(posedge clk_100mhz) begin
        if (cycle == 6'd63) begin
          // assert ready next cycle, read next sample from file
          ready <= 1;
          code = $fscanf(fin,"%d",x);
          // if we reach the end of the input file, we're done
          if (code != 1) begin
            $fclose(fout);
            $stop;
          end
        end
        else begin
          ready <= 0;
        end
    
        if (ready) begin
//            scaled_adc_data <= 16*adc_data;
            //https://en.wikipedia.org/wiki/Offset_binary
            if (fft_ready && my_fft_count == 0)begin
                fft_data_counter <= fft_data_counter +1;
                fft_last <= fft_data_counter==1023;
                fft_valid <= 1'b1;
                // if sw[12] on, fft on effects signal, else on input signal
                fft_data <= x <<< 4; //set the FFT DATA here!
            end
            if (ifft_ready && my_fft_count == 0) begin
                ifft_data <= fft_out_data;
            end
          // starting with sample 32, record results in output file
          if (scount > 31) $fdisplay(fout,"%d",y);
          scount <= scount + 1;
        end else begin
            fft_data <= 0;
            fft_last <= 0;
            fft_valid <= 0;
        end
    
        cycle <= cycle+1;
        
      end

    xfft_0 my_fft (.aclk(clk_100mhz), .s_axis_data_tdata(fft_data), 
                    .s_axis_data_tvalid(fft_valid),
                    .s_axis_data_tlast(fft_last), .s_axis_data_tready(fft_ready),
                    .s_axis_config_tdata(1), 
                     .s_axis_config_tvalid(0),
                     .s_axis_config_tready(),
                    .m_axis_data_tdata(fft_out_data), .m_axis_data_tvalid(fft_out_valid),
                    .m_axis_data_tlast(fft_out_last), .m_axis_data_tready(fft_out_ready));
                    
    logic real_fft = fft_out_data[31:16];
    logic real_ifft = ifft_out_data[31:16];
                    
    xfft_0 my_ifft (.aclk(clk_100mhz), .s_axis_data_tdata(ifft_data), 
                    .s_axis_data_tvalid(fft_out_valid),
                    .s_axis_data_tlast(fft_out_last), .s_axis_data_tready(ifft_ready),
                    .s_axis_config_tdata(0), 
                     .s_axis_config_tvalid(0),
                     .s_axis_config_tready(),
                    .m_axis_data_tdata(ifft_out_data), .m_axis_data_tvalid(ifft_out_valid),
                    .m_axis_data_tlast(ifft_out_last), .m_axis_data_tready(ifft_out_ready));

endmodule