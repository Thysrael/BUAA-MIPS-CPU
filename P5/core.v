`timescale 1ns / 1ps
`include "const.v"

module CORE
	(
		input [31:0] instr,
		output reg [6:0] order
	);
	
	wire [5:0] opcode = instr[31:26];
	wire [5:0] funcode = instr[5:0];
	
	always @(*) begin
		case(opcode)
			0: 
				case(funcode)
					0: order = `nop;
					8: order = `jr;
					33: order = `addu;
					35: order = `subu;
					default : order = `nop;
				endcase

			2: order = `j;
			3: order = `jal;
			4: order = `beq;
			13: order = `ori;
			15: order = `lui;
			35: order = `lw;
			43: order = `sw;
			default : order = `nop;
		endcase
	end

endmodule 