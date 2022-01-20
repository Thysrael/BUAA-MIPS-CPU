`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:10:49 11/14/2021 
// Design Name: 
// Module Name:    CMP 
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
module CMP(
	input [31:0] num1,
	input [31:0] num2,
	output reg CMPOut,
	input [3:0] CMPOP
    );

	parameter
	EQ = 0,
	G = 1,
	LT = 2,
	NE = 3,
	GE = 4,
	LE = 5,
	EQZ = 6,
	GTZ = 7,
	LTZ = 8,
	NEZ = 9,
	GEZ = 10,
	LEZ = 11;
	
	always @(*) begin
		case(CMPOP)
			EQ:
				CMPOut = (num1 == num2);
			G:
				CMPOut = (num1 > num2);
			LT:
				CMPOut = (num1 < num2);
			NE:
				CMPOut = (num1 != num2);
			GE:
				CMPOut = (num1 >= num2);
			LE:
				CMPOut = (num1 <= num2);
			EQZ:
				CMPOut = (num1 == 32'd0);
			GTZ:
				CMPOut = (num1 > 32'd0);
			LTZ:
				CMPOut = (num1 <= 32'd0);
			NEZ:
				CMPOut = (num1 != 32'd0);
			GEZ:
				CMPOut = (num1 >= 32'd0);
			LEZ:
				CMPOut = (num1 <= 32'd0);
			default:
				CMPOut = 1'dx;
		endcase
	end
	
endmodule
