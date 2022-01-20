`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:03:18 11/14/2021 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
	input [31:0] PC,
	input [31:0] branch,
	output reg [31:0] nextPC,
	input [3:0] NPCOP
    );

	parameter
	NORMAL = 0,
	BRANCH = 1,
	J = 2,
	JR = 3;
	
	always @(*) begin
		case(NPCOP)
			NORMAL:
				nextPC = PC + 4;
			BRANCH:
				nextPC = PC + 4 + (branch << 2);
			J:
				nextPC = {PC[31:28], branch[25:0], 2'b00};
			JR:
				nextPC = branch;
			default:
				nextPC = 32'dx;
		endcase
	end

endmodule
