`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:48:40 11/14/2021 
// Design Name: 
// Module Name:    EXT 
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
module EXT(
	input [25:0] EXTIn,
	output reg [31:0] EXTOut,
	input [3:0] EXTOP
    );
	
	parameter
	ZE16 = 0,
	SE16 = 1,
	ZE26 = 2;
	
	always @(*) begin
		case(EXTOP)
			ZE16:
				EXTOut = {{16{1'd0}}, EXTIn[15:0]};
			SE16:
				EXTOut = {{16{EXTIn[15]}}, EXTIn[15:0]};
			ZE26:
				EXTOut = {{6{1'd0}}, EXTIn};
			default:
				EXTOut = 32'dx;
		endcase
	end

endmodule
