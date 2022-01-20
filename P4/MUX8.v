`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:22:35 11/14/2021 
// Design Name: 
// Module Name:    MUX16 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MUX8
	#(parameter WIDTH=32) 
	(
	output reg [WIDTH - 1:0] out, 
	input [2:0] sel,
	input [WIDTH - 1:0] in0,
	input [WIDTH - 1:0] in1,
	input [WIDTH - 1:0] in2,
	input [WIDTH - 1:0] in3,
	input [WIDTH - 1:0] in4,
	input [WIDTH - 1:0] in5,
	input [WIDTH - 1:0] in6,
	input [WIDTH - 1:0] in7
    );

	always @(*) begin
		case(sel)
			0: out = in0;
			1: out = in1;
			2: out = in2;
			3: out = in3;
			4: out = in4;
			5: out = in5;
			6: out = in6;
			7: out = in7;
		endcase
	end

endmodule
