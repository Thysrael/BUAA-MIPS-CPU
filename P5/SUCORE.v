`timescale 1ns / 1ps
`include "const.v"

module SUCORE
	(
		input [31:0] instr,
		output [4:0] A1,
		output reg [2:0] rsTuse,
		output [4:0] A2,
		output reg [2:0] rtTuse,
		output [4:0] A3,
		output reg [2:0] E_Tnew,
		output reg [2:0] M_Tnew
	);
	
	wire [6:0] order;
	
	BasicCORE basiccore
		(
			.instr(instr),
			.order(order),
			.A1(A1),
			.A2(A2),
			.A3(A3)
		);

	//rsTuse	
	always @(*)
		case(order)
			`addu, `subu, `ori, `lw, `sw : rsTuse = 1;
			`jr, `beq : rsTuse = 0;
			default : rsTuse = 0;
		endcase

	//rtTuse	
	always @(*)
		case(order)
			`sw : rtTuse = 2;
			`addu, `subu : rtTuse = 1;
			`beq : rtTuse = 0;
			default : rtTuse = 0;
		endcase
	
	//Tnew
	always @(*)
		case(order)
			`lw : E_Tnew = 2;
			`addu, `subu, `ori : E_Tnew = 1;
			`lui, `jal : E_Tnew = 0;
			default : E_Tnew = 0;
		endcase
		
	always @(*)
		case(order)
			`lw : M_Tnew = 1;
			`addu, `subu, `ori, `lui, `jal : M_Tnew = 0;
			default : M_Tnew = 0;
		endcase
		
endmodule 