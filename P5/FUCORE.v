`timescale 1ns / 1ps
`include "const.v"

module FUCORE
	(
		input [31:0] instr,
		input CMPOut,
		output [4:0] A1,
		output [4:0] A2,
		output [4:0] A3,
		output reg [2:0] FWSrcSel
	);
	
	parameter
	PC = 0,
	ALUOut = 1,
	EXTOut = 2,
	DMOut = 3;
	
	wire [6:0] order;
	
	BasicCORE basiccore
		(
			.instr(instr),
			.order(order),
			.A1(A1),
			.A2(A2),
			.A3(A3)
		);
	
	always @(*)
		case(order)
			`jal : FWSrcSel = PC;
			`addu, `subu, `ori : FWSrcSel = ALUOut;
			`lui : FWSrcSel = EXTOut;
			`lw : FWSrcSel = DMOut;
			default : FWSrcSel = PC;
		endcase
	
endmodule 