`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2020 07:55:47 PM
// Design Name: 
// Module Name: coeffs31
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

module lpf_coeffs31(
  input  [4:0] index_in,
  output logic signed [10:0] coeff_out
);
  logic signed [10:0] coeff;
  assign coeff_out = coeff;
  // tools will turn this into a 31x10 ROM
  always_comb begin
    case (index_in)
5'd0:	coeff = 11'sd0;
5'd1:	coeff = 11'sd0;
5'd2:	coeff = 11'sd0;
5'd3:	coeff = 11'sd1;
5'd4:	coeff = 11'sd3;
5'd5:	coeff = 11'sd6;
5'd6:	coeff = 11'sd10;
5'd7:	coeff = 11'sd17;
5'd8:	coeff = 11'sd26;
5'd9:	coeff = 11'sd37;
5'd10:	coeff = 11'sd49;
5'd11:	coeff = 11'sd63;
5'd12:	coeff = 11'sd75;
5'd13:	coeff = 11'sd86;
5'd14:	coeff = 11'sd92;
5'd15:	coeff = 11'sd95;
5'd16:	coeff = 11'sd92;
5'd17:	coeff = 11'sd86;
5'd18:	coeff = 11'sd75;
5'd19:	coeff = 11'sd63;
5'd20:	coeff = 11'sd49;
5'd21:	coeff = 11'sd37;
5'd22:	coeff = 11'sd26;
5'd23:	coeff = 11'sd17;
5'd24:	coeff = 11'sd10;
5'd25:	coeff = 11'sd6;
5'd26:	coeff = 11'sd3;
5'd27:	coeff = 11'sd1;
5'd28:	coeff = 11'sd0;
5'd29:	coeff = 11'sd0;
5'd30:	coeff = 11'sd0;


      default: coeff = 11'hXXX;
    endcase
  end
endmodule

module bpf_coeffs31(
  input  [4:0] index_in,
  output logic signed [10:0] coeff_out
);
  logic signed [10:0] coeff;
  assign coeff_out = coeff;
  // tools will turn this into a 31x10 ROM
  always_comb begin
    case (index_in)
    
    5'd0:	coeff = 11'sd0;
5'd1:	coeff = 11'sd0;
5'd2:	coeff = 11'sd1;
5'd3:	coeff = 11'sd2;
5'd4:	coeff = 11'sd2;
5'd5:	coeff = -11'sd2;
5'd6:	coeff = -11'sd13;
5'd7:	coeff = -11'sd32;
5'd8:	coeff = -11'sd55;
5'd9:	coeff = -11'sd70;
5'd10:	coeff = -11'sd66;
5'd11:	coeff = -11'sd32;
5'd12:	coeff = 11'sd29;
5'd13:	coeff = 11'sd101;
5'd14:	coeff = 11'sd159;
5'd15:	coeff = 11'sd182;
5'd16:	coeff = 11'sd159;
5'd17:	coeff = 11'sd101;
5'd18:	coeff = 11'sd29;
5'd19:	coeff = -11'sd32;
5'd20:	coeff = -11'sd66;
5'd21:	coeff = -11'sd70;
5'd22:	coeff = -11'sd55;
5'd23:	coeff = -11'sd32;
5'd24:	coeff = -11'sd13;
5'd25:	coeff = -11'sd2;
5'd26:	coeff = 11'sd2;
5'd27:	coeff = 11'sd2;
5'd28:	coeff = 11'sd1;
5'd29:	coeff = 11'sd0;
5'd30:	coeff = 11'sd0;


        default: coeff = 11'hXXX;
    endcase
  end
endmodule

module hpf_coeffs31(
  input  [4:0] index_in,
  output logic signed [10:0] coeff_out
);
  logic signed [10:0] coeff;
  assign coeff_out = coeff;
  // tools will turn this into a 31x10 ROM
  always_comb begin
    case (index_in)
    5'd0:	coeff = 11'sd0;
5'd1:	coeff = 11'sd0;
5'd2:	coeff = 11'sd0;
5'd3:	coeff = 11'sd0;
5'd4:	coeff = 11'sd1;
5'd5:	coeff = 11'sd3;
5'd6:	coeff = 11'sd4;
5'd7:	coeff = 11'sd5;
5'd8:	coeff = 11'sd2;
5'd9:	coeff = -11'sd7;
5'd10:	coeff = -11'sd26;
5'd11:	coeff = -11'sd54;
5'd12:	coeff = -11'sd87;
5'd13:	coeff = -11'sd120;
5'd14:	coeff = -11'sd145;
5'd15:	coeff = 11'sd870;
5'd16:	coeff = -11'sd145;
5'd17:	coeff = -11'sd120;
5'd18:	coeff = -11'sd87;
5'd19:	coeff = -11'sd54;
5'd20:	coeff = -11'sd26;
5'd21:	coeff = -11'sd7;
5'd22:	coeff = 11'sd2;
5'd23:	coeff = 11'sd5;
5'd24:	coeff = 11'sd4;
5'd25:	coeff = 11'sd3;
5'd26:	coeff = 11'sd1;
5'd27:	coeff = 11'sd0;
5'd28:	coeff = 11'sd0;
5'd29:	coeff = 11'sd0;
5'd30:	coeff = 11'sd0;

      default: coeff = 11'hXXX;
    endcase
  end
endmodule