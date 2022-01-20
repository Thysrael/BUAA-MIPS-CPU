`timescale 1ns / 1ps

module NPC
	(
		input [31:0] PC,
		input [31:0] Jump,
		output reg [31:0] nextPC,
		input [3:0] NPCOP
	);
	
	parameter
	NORMAL = 0,
	BRANCH = 1,
	JIMM = 2,
	JREG = 3;
	
	always @(*) begin
		case(NPCOP)
			NORMAL: nextPC = PC + 4;
			BRANCH: nextPC = PC + 4 + {Jump[29:0], 2'd0};
			JIMM: nextPC = {PC[31:28], Jump[25:0], 2'd0};
			JREG: nextPC = Jump;
			default: nextPC = PC + 4;
		endcase
	end
	
endmodule 