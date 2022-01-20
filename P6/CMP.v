`timescale 1ns / 1ps

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
				CMPOut = ($signed(num1) > $signed(num2));
			LT:
				CMPOut = ($signed(num1) < $signed(num2));
			NE:
				CMPOut = ($signed(num1) != $signed(num2));
			GE:
				CMPOut = ($signed(num1) >= $signed(num2));
			LE:
				CMPOut = ($signed(num1) <= $signed(num2));
			EQZ:
				CMPOut = ($signed(num1) == $signed(32'd0));
			GTZ:
				CMPOut = ($signed(num1) > $signed(32'd0));
			LTZ:
				CMPOut = ($signed(num1) < $signed(32'd0));
			NEZ:
				CMPOut = ($signed(num1) != $signed(32'd0));
			GEZ:
				CMPOut = ($signed(num1) >= $signed(32'd0));
			LEZ:
				CMPOut = ($signed(num1) <= $signed(32'd0));
			default:
				CMPOut = 1'dx;
		endcase
	end
	
endmodule
