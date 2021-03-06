//Volume Control
module volume_control (input [2:0] vol_in, input signed [11:0] signal_in, output logic signed[11:0] signal_out);
    logic [2:0] shift;
    assign shift = 3'd7 - vol_in;
    assign signal_out = signal_in>>>shift;
endmodule