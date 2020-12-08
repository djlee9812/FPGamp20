module lpf_fir(
  input  clk_in,rst_in,ready_in,ena,
  input signed [11:0] x_in,
  output logic signed [11:0] y_out,
  output logic ready_out
);
    logic signed [11:0] sample [31:0];
    logic signed [10:0] coeff;
    // 5 bit for keeping track of up to 31
    logic [4:0] offset;
    logic [4:0] index;
    logic counting;
    
    logic signed [23:0] accumulator;
    logic signed [23:0] to_add;
    
    lpf_coeffs31 my_coeff (.index_in(index), .coeff_out(coeff));
    // for now just pass data through
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            counting <= 0;
            y_out <= 0;
            offset <= 0;
            ready_out <= 0;
            for (integer i = 0; i < 32; i++) begin
                sample[i] = 0;
            end
        // if ready, set sample, reset index/accum, increment offset
        end
        if (~ena) begin
            if (ready_in) begin
                ready_out <= 1; 
                y_out <= x_in;
            end else begin
                ready_out <= 0;
            end
        end 
        // reset counters, y_out, offset, sample
        else if (ready_in) begin
            offset <= offset + 5'b1;
            sample[offset+1] <= x_in;
            index <= 5'b0;
            accumulator <= 0;
            counting <= 1'b1;
            to_add <= 0;
            ready_out <= 0;
        // computing fir convolution
        end else if (counting && index <= 30) begin
            to_add <= coeff * sample[offset-index];
            accumulator <= accumulator + to_add;
            index <= index + 5'b1;
        // if all 0 to 30 are calculated, set y_out and stop counting
        end else if (index == 31) begin
            y_out <= (accumulator + to_add) >>> 12;
            ready_out <= 1;
            counting <= 0;  
            index <= 0;
        end
        if (ready_out) begin
            ready_out <= 0;
        end
    end
endmodule

module bpf_fir(
  input  clk_in,rst_in,ready_in,ena,
  input signed [11:0] x_in,
  output logic signed [11:0] y_out,
  output logic ready_out
);
    logic signed [11:0] sample [31:0];
    logic signed [10:0] coeff;
    // 5 bit for keeping track of up to 31
    logic [4:0] offset;
    logic [4:0] index;
    logic counting;
    
    logic signed [23:0] accumulator;
    logic signed [23:0] to_add;
    
    bpf_coeffs31 my_coeff (.index_in(index), .coeff_out(coeff));
    // for now just pass data through
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            counting <= 0;
            y_out <= 0;
            offset <= 0;
            ready_out <= 0;
            for (integer i = 0; i < 32; i++) begin
                sample[i] = 0;
            end
        // if ready, set sample, reset index/accum, increment offset
        end
        if (~ena) begin
           if (ready_in) begin
                ready_out <= 1; 
                y_out <= x_in;
            end else begin
                ready_out <= 0;
            end
        // if ready, set sample, reset index/accum, increment offset
        end else if (ready_in) begin
            offset <= offset + 5'b1;
            sample[offset+1] <= x_in;
            index <= 5'b0;
            accumulator <= 0;
            counting <= 1'b1;
            to_add <= 0;
            ready_out <= 0;
        // computing fir convolution
        end else if (counting && index <= 30) begin
            to_add <= coeff * sample[offset-index];
            accumulator <= accumulator + to_add;
            index <= index + 5'b1;
        // if all 0 to 30 are calculated, set y_out and stop counting
        end else if (index == 31) begin
            y_out <= (accumulator + to_add)>>>12;
            counting <= 0;  
            index <= 0;
            ready_out <= 1;
        end
        if (ready_out) begin
            ready_out <= 0;
        end
    end
endmodule

module hpf_fir(
  input  clk_in,rst_in,ready_in,ena,
  input signed [11:0] x_in,
  output logic signed [11:0] y_out,
  output logic ready_out
);
    logic signed [11:0] sample [31:0];
    logic signed [10:0] coeff;
    // 5 bit for keeping track of up to 31
    logic [4:0] offset;
    logic [4:0] index;
    logic counting;
    
    logic signed [23:0] accumulator;
    logic signed [23:0] to_add;
    
    hpf_coeffs31 my_coeff (.index_in(index), .coeff_out(coeff));
    // for now just pass data through
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            counting <= 0;
            y_out <= 0;
            offset <= 0;
            ready_out <= 0;
            for (integer i = 0; i < 32; i++) begin
                sample[i] = 0;
            end
        // if ready, set sample, reset index/accum, increment offset
        end
        if (~ena) begin
           if (ready_in) begin
                ready_out <= 1; 
                y_out <= x_in;
            end else begin
                ready_out <= 0;
            end        
        // if ready, set sample, reset index/accum, increment offset
        end else if (ready_in) begin
            offset <= offset + 5'b1;
            sample[offset+1] <= x_in;
            index <= 5'b0;
            accumulator <= 0;
            counting <= 1'b1;
            to_add <= 0;
            ready_out <= 0;
        // computing fir convolution
        end else if (counting && index <= 30) begin
            to_add <= coeff * sample[offset-index];
            accumulator <= accumulator + to_add;
            index <= index + 5'b1;
        // if all 0 to 30 are calculated, set y_out and stop counting
        end else if (index == 31) begin
            y_out <= accumulator + to_add;
            ready_out <= 1;
            counting <= 0;  
            index <= 0;
        end
        if (ready_out) begin
            ready_out <= 0;
        end
    end
endmodule