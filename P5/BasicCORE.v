`timescale 1ns / 1ps
`include "const.v"

module BasicCORE
	(
		input [31:0] instr,
		output [6:0] order,
		output reg [4:0] A1,
		output reg [4:0] A2,
		output reg [4:0] A3
	);
	
	wire [5:0] opcode = instr[31:26];
	wire [5:0] funcode = instr[5:0];
	wire [4:0] rs, rt, rd;
	assign rs = instr[25:21];
	assign rt = instr[20:16];
	assign rd = instr[15:11];
	
	CORE core
		(
			.instr(instr),
			.order(order)
		);
	
	always @(*)
		case(order)
			`addu, `subu, `ori, `lw, `sw, `beq, `jr : A1 = rs;
			default : A1 = 0;
		endcase
	
	always @(*)
		case(order)
			`sw, `addu, `subu, `beq : A2 = rt;
			default : A2 = 0;
		endcase
	
	always @(*)
		case(order)
			`addu, `subu : A3 = rd;
			`jal : A3 = 5'd31;
			`ori, `lw, `lui : A3 = rt;
			default : A3 = 0;
		endcase	

endmodule 