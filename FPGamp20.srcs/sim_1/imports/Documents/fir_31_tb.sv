`default_nettype none    // catch typos!
`timescale 1ns / 100ps 

// test fir31 module
// input samples are read from fir31.samples
// output samples are written to fir31.output
module fir31_test();
  logic clk,reset,ready;	// fir31 signals
  logic signed [11:0] x;
  logic signed [11:0] y;
  logic signed [11:0] trem_out;
  logic reverb_on;
  logic [20:0] scount;    // keep track of which sample we're at
  logic [5:0] cycle;      // wait 64 clocks between samples
  integer fin,fout,code;

  initial begin
    // open input/output files
    //CHANGE THESE TO ACTUAL FILE NAMES!YOU MUST DO THIS
    fin = $fopen("C:/Users/Allan Garcia/Documents/fir31.waveform","r");
    fout = $fopen("fir31.output","w");
    if (fin == 0 || fout == 0) begin
      $display("can't open file...");
      $stop;
    end

    // initialize state, assert reset for one clock cycle
    scount = 0;
    clk = 0;
    cycle = 0;
    ready = 0;
    x = 0;
    trem_out = 0;
    reset = 1;
    reverb_on = 0;
    #10
    reset = 0;
    reverb_on = 1;
  end

  // clk has 50% duty cycle, 10ns period
  always #5 clk = ~clk;

  always @(posedge clk) begin
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
      // starting with sample 32, record results in output file
      if (scount > 31) $fdisplay(fout,"%d",y);
      scount <= scount + 1;
    end

    cycle <= cycle+1;
  end

  tremolo dut(.clk_in(clk),.trem_on(1),.ready_in(ready), .rst_in(reset),
            .signal_in(x<<<4),.signal_out(trem_out));
            
  reverb rev (.reverb_on(reverb_on), .ready_in(ready), .clk_in(clk), 
        .signal_in(trem_out), .signal_out(y)); 

endmodule